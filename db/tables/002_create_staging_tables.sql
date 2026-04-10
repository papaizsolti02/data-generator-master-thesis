IF OBJECT_ID('stg.Users_Raw', 'U') IS NULL
BEGIN
    CREATE TABLE stg.Users_Raw (
        UserID BIGINT NOT NULL,
        FirstName NVARCHAR(120) NULL,
        LastName NVARCHAR(120) NULL,
        Email NVARCHAR(320) NULL,
        Username NVARCHAR(120) NULL,
        DateOfBirth DATE NULL,
        RegistrationDate DATE NULL,
        Country NVARCHAR(100) NULL,
        City NVARCHAR(120) NULL,
        Gender NVARCHAR(20) NULL,
        AccountCreatedVia NVARCHAR(40) NULL,
        ReferralSource NVARCHAR(40) NULL,
        SubscriptionTier NVARCHAR(40) NULL,
        BillingCycle NVARCHAR(40) NULL,
        PaymentMethod NVARCHAR(40) NULL,
        AutoRenew BIT NULL,
        MarketingConsent BIT NULL,
        PreferredLanguage NVARCHAR(10) NULL,
        ContentLanguage NVARCHAR(10) NULL,
        PlanAddons NVARCHAR(100) NULL,
        TenureDays INT NULL,
        SnapshotDate DATE NULL,
        DayNumber INT NULL,
        BatchId NVARCHAR(64) NULL,
        IngestedAt DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF OBJECT_ID('stg.Users_Clean', 'U') IS NULL
BEGIN
    CREATE TABLE stg.Users_Clean (
        UserID BIGINT NOT NULL,
        FirstName NVARCHAR(120) NOT NULL,
        LastName NVARCHAR(120) NOT NULL,
        FullName NVARCHAR(260) NOT NULL,
        EmailNormalized NVARCHAR(320) NOT NULL,
        UsernameNormalized NVARCHAR(120) NOT NULL,
        DateOfBirth DATE NULL,
        RegistrationDate DATE NULL,
        CountryNormalized NVARCHAR(100) NULL,
        CityNormalized NVARCHAR(120) NULL,
        GenderNormalized NVARCHAR(20) NULL,
        AccountCreatedVia NVARCHAR(40) NULL,
        ReferralSource NVARCHAR(40) NULL,
        SubscriptionTier NVARCHAR(40) NULL,
        BillingCycle NVARCHAR(40) NULL,
        PaymentMethod NVARCHAR(40) NULL,
        AutoRenew BIT NULL,
        MarketingConsent BIT NULL,
        PreferredLanguage NVARCHAR(10) NULL,
        ContentLanguage NVARCHAR(10) NULL,
        PlanAddons NVARCHAR(100) NULL,
        TenureDays INT NULL,
        HashDiff VARBINARY(32) NULL,
        BatchId NVARCHAR(64) NULL,
        ProcessedAt DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Users_Clean PRIMARY KEY CLUSTERED (UserID)
    );
END
GO
