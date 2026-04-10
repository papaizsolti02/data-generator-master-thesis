IF OBJECT_ID('ctl.DeployHistory', 'U') IS NULL
BEGIN
    CREATE TABLE ctl.DeployHistory (
        DeployHistoryId INT IDENTITY(1,1) PRIMARY KEY,
        ScriptPath NVARCHAR(300) NOT NULL,
        DeployedAt DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
        DeployedBy NVARCHAR(128) NULL
    );
END
GO

IF OBJECT_ID('ctl.PipelineRun', 'U') IS NULL
BEGIN
    CREATE TABLE ctl.PipelineRun (
        PipelineRunId BIGINT IDENTITY(1,1) PRIMARY KEY,
        BatchId NVARCHAR(64) NOT NULL,
        EnvironmentName NVARCHAR(16) NOT NULL,
        StartedAt DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
        FinishedAt DATETIME2(3) NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'STARTED'
    );
END
GO
