CREATE OR ALTER PROCEDURE stg.sp_Transform_Users_Raw
    @BatchId NVARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM stg.Users_Clean WHERE BatchId = @BatchId;

    INSERT INTO stg.Users_Clean (
        UserID,
        FirstName,
        LastName,
        FullName,
        EmailNormalized,
        UsernameNormalized,
        DateOfBirth,
        RegistrationDate,
        CountryNormalized,
        CityNormalized,
        GenderNormalized,
        AccountCreatedVia,
        ReferralSource,
        SubscriptionTier,
        BillingCycle,
        PaymentMethod,
        AutoRenew,
        MarketingConsent,
        PreferredLanguage,
        ContentLanguage,
        PlanAddons,
        TenureDays,
        HashDiff,
        BatchId
    )
    SELECT
        r.UserID,
        TRIM(ISNULL(r.FirstName, '')),
        TRIM(ISNULL(r.LastName, '')),
        CONCAT(TRIM(ISNULL(r.FirstName, '')), ' ', TRIM(ISNULL(r.LastName, ''))),
        LOWER(TRIM(ISNULL(r.Email, ''))),
        LOWER(TRIM(ISNULL(r.Username, ''))),
        r.DateOfBirth,
        r.RegistrationDate,
        UPPER(TRIM(r.Country)),
        TRIM(r.City),
        UPPER(TRIM(r.Gender)),
        TRIM(r.AccountCreatedVia),
        TRIM(r.ReferralSource),
        TRIM(r.SubscriptionTier),
        TRIM(r.BillingCycle),
        TRIM(r.PaymentMethod),
        r.AutoRenew,
        r.MarketingConsent,
        LOWER(TRIM(r.PreferredLanguage)),
        LOWER(TRIM(r.ContentLanguage)),
        TRIM(r.PlanAddons),
        r.TenureDays,
        HASHBYTES(
            'SHA2_256',
            CONCAT(
                TRIM(ISNULL(r.FirstName, '')), '|',
                TRIM(ISNULL(r.LastName, '')), '|',
                LOWER(TRIM(ISNULL(r.Email, ''))), '|',
                LOWER(TRIM(ISNULL(r.Username, ''))), '|',
                TRIM(ISNULL(r.Country, '')), '|',
                TRIM(ISNULL(r.City, '')), '|',
                TRIM(ISNULL(r.SubscriptionTier, '')), '|',
                TRIM(ISNULL(r.BillingCycle, '')), '|',
                TRIM(ISNULL(r.PaymentMethod, '')), '|',
                TRIM(ISNULL(r.PreferredLanguage, '')), '|',
                TRIM(ISNULL(r.ContentLanguage, '')), '|',
                TRIM(ISNULL(r.PlanAddons, ''))
            )
        ),
        @BatchId
    FROM stg.Users_Raw r
    WHERE r.BatchId = @BatchId;
END
GO
