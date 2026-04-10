param(
    [Parameter(Mandatory=$true)][string]$Server,
    [Parameter(Mandatory=$true)][string]$Database,
    [Parameter(Mandatory=$true)][PSCredential]$Credential,
    [string]$RepoRoot = ".",
    [switch]$CleanupOrphans
)

$ErrorActionPreference = "Stop"

Import-Module SqlServer -ErrorAction Stop

function Normalize-DbIdentifier {
    param([string]$Identifier)

    if ([string]::IsNullOrWhiteSpace($Identifier)) {
        return $Identifier
    }

    return $Identifier.Replace("[", "").Replace("]", "").Trim().ToLowerInvariant()
}

function Add-ManagedObject {
    param(
        [System.Collections.Generic.HashSet[string]]$Managed,
        [string]$SchemaName,
        [string]$ObjectName,
        [string]$TypeCode
    )

    $schemaNormalized = Normalize-DbIdentifier $SchemaName
    $objectNormalized = Normalize-DbIdentifier $ObjectName

    if ([string]::IsNullOrWhiteSpace($schemaNormalized) -or [string]::IsNullOrWhiteSpace($objectNormalized)) {
        return
    }

    [void]$Managed.Add("$schemaNormalized.$objectNormalized|$TypeCode")
}

function Get-ManagedObjectsFromSource {
    param([string]$Root)

    $managed = New-Object 'System.Collections.Generic.HashSet[string]'
    $dbRoot = Join-Path $Root "db"

    if (-not (Test-Path $dbRoot)) {
        return $managed
    }

    $sqlFiles = Get-ChildItem -Path $dbRoot -Recurse -Filter "*.sql"
    foreach ($file in $sqlFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        $procMatches = [regex]::Matches($content, "(?im)CREATE\s+OR\s+ALTER\s+PROCEDURE\s+([\[\]\w]+)\.([\[\]\w]+)")
        foreach ($m in $procMatches) {
            Add-ManagedObject -Managed $managed -SchemaName $m.Groups[1].Value -ObjectName $m.Groups[2].Value -TypeCode "P"
        }

        $viewMatches = [regex]::Matches($content, "(?im)CREATE\s+OR\s+ALTER\s+VIEW\s+([\[\]\w]+)\.([\[\]\w]+)")
        foreach ($m in $viewMatches) {
            Add-ManagedObject -Managed $managed -SchemaName $m.Groups[1].Value -ObjectName $m.Groups[2].Value -TypeCode "V"
        }

        $tableMatchesFromObjectId = [regex]::Matches($content, "(?im)OBJECT_ID\s*\(\s*'([^']+)'\s*,\s*'U'\s*\)")
        foreach ($m in $tableMatchesFromObjectId) {
            $parts = $m.Groups[1].Value.Split('.')
            if ($parts.Length -eq 2) {
                Add-ManagedObject -Managed $managed -SchemaName $parts[0] -ObjectName $parts[1] -TypeCode "U"
            }
        }

        $tableMatchesFromCreate = [regex]::Matches($content, "(?im)CREATE\s+TABLE\s+([\[\]\w]+)\.([\[\]\w]+)")
        foreach ($m in $tableMatchesFromCreate) {
            Add-ManagedObject -Managed $managed -SchemaName $m.Groups[1].Value -ObjectName $m.Groups[2].Value -TypeCode "U"
        }
    }

    return $managed
}

$orderedFolders = @(
    "db/schema",
    "db/tables",
    "db/indexes",
    "db/views",
    "db/stored_procedures"
)

Write-Host "Deploying DB artifacts to $Server / $Database"

foreach ($folder in $orderedFolders) {
    $fullPath = Join-Path $RepoRoot $folder
    if (-not (Test-Path $fullPath)) {
        continue
    }

    $scripts = Get-ChildItem -Path $fullPath -Filter "*.sql" | Sort-Object Name
    foreach ($script in $scripts) {
        Write-Host "Applying $($script.FullName)"
        Invoke-Sqlcmd `
            -ServerInstance $Server `
            -Database $Database `
            -Credential $credential `
            -InputFile $script.FullName `
            -TrustServerCertificate

        $escapedPath = $script.FullName.Replace("'", "''")
        $escapedUser = $Credential.UserName.Replace("'", "''")
        $logSql = @"
IF OBJECT_ID('ctl.DeployHistory', 'U') IS NOT NULL
BEGIN
    INSERT INTO ctl.DeployHistory (ScriptPath, DeployedBy)
    VALUES (N'$escapedPath', N'$escapedUser');
END
"@

        Invoke-Sqlcmd `
            -ServerInstance $Server `
            -Database $Database `
            -Credential $credential `
            -Query $logSql `
            -TrustServerCertificate
    }
}

if ($CleanupOrphans) {
    Write-Host "CleanupOrphans is enabled. Detecting DB objects not present in source control..."

    $managedObjects = Get-ManagedObjectsFromSource -Root $RepoRoot

    $existingObjectsQuery = @"
SELECT
    s.name AS SchemaName,
    o.name AS ObjectName,
    o.type AS TypeCode
FROM sys.objects o
INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.type IN ('U', 'V', 'P')
  AND s.name NOT IN ('sys', 'INFORMATION_SCHEMA', 'temp')
"@

    $existingObjects = Invoke-Sqlcmd `
        -ServerInstance $Server `
        -Database $Database `
        -Credential $credential `
        -Query $existingObjectsQuery `
        -TrustServerCertificate

    $orphans = @()
    foreach ($obj in $existingObjects) {
        $key = "$(Normalize-DbIdentifier $obj.SchemaName).$(Normalize-DbIdentifier $obj.ObjectName)|$($obj.TypeCode)"
        if (-not $managedObjects.Contains($key)) {
            $orphans += $obj
        }
    }

    if ($orphans.Count -eq 0) {
        Write-Host "No orphan objects found."
    } else {
        # Drop views/procs before tables to reduce dependency errors.
        $dropOrder = @('V', 'P', 'U')
        foreach ($typeCode in $dropOrder) {
            $toDrop = $orphans | Where-Object { $_.TypeCode -eq $typeCode }
            foreach ($obj in $toDrop) {
                $schemaName = $obj.SchemaName
                $objectName = $obj.ObjectName

                if ($schemaName.ToLowerInvariant() -eq 'temp') {
                    continue
                }

                $dropVerb = switch ($typeCode) {
                    'U' { 'TABLE' }
                    'V' { 'VIEW' }
                    'P' { 'PROCEDURE' }
                    default { '' }
                }

                if ([string]::IsNullOrWhiteSpace($dropVerb)) {
                    continue
                }

                $dropQuery = "DROP $dropVerb [$schemaName].[$objectName];"
                Write-Host "Dropping orphan $dropVerb [$schemaName].[$objectName]"

                Invoke-Sqlcmd `
                    -ServerInstance $Server `
                    -Database $Database `
                    -Credential $credential `
                    -Query $dropQuery `
                    -TrustServerCertificate
            }
        }
    }
}

Write-Host "DB deployment completed successfully."
