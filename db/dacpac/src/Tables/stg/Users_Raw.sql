CREATE TABLE [stg].[Users_Raw]
(
    [UserID] BIGINT NOT NULL,
    [FirstName] NVARCHAR(120) NULL,
    [LastName] NVARCHAR(120) NULL,
    [Email] NVARCHAR(320) NULL,
    [Username] NVARCHAR(120) NULL,
    [DateOfBirth] DATE NULL,
    [RegistrationDate] DATE NULL,
    [Country] NVARCHAR(100) NULL,
    [City] NVARCHAR(120) NULL,
    [Gender] NVARCHAR(20) NULL,
    [AccountCreatedVia] NVARCHAR(40) NULL,
    [ReferralSource] NVARCHAR(40) NULL,
    [SubscriptionTier] NVARCHAR(40) NULL,
    [BillingCycle] NVARCHAR(40) NULL,
    [PaymentMethod] NVARCHAR(40) NULL,
    [AutoRenew] BIT NULL,
    [MarketingConsent] BIT NULL,
    [PreferredLanguage] NVARCHAR(10) NULL,
    [ContentLanguage] NVARCHAR(10) NULL,
    [PlanAddons] NVARCHAR(100) NULL,
    [TenureDays] INT NULL,
    [SnapshotDate] DATE NULL,
    [DayNumber] INT NULL,
    [BatchId] NVARCHAR(64) NULL,
    [IngestedAt] DATETIME2(3) NOT NULL CONSTRAINT [DF_Users_Raw_IngestedAt] DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX [IX_Users_Raw_UserID_BatchId]
    ON [stg].[Users_Raw] ([UserID], [BatchId]);
GO
