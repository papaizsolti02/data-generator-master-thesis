CREATE OR ALTER VIEW dw.vw_CurrentDimUser
AS
SELECT
    DimUserKey,
    UserID,
    FullName,
    EmailNormalized,
    UsernameNormalized,
    CountryNormalized,
    CityNormalized,
    SubscriptionTier,
    BillingCycle,
    PaymentMethod,
    PreferredLanguage,
    ContentLanguage,
    PlanAddons,
    EffectiveFrom,
    BatchId
FROM dw.DimUser
WHERE IsCurrent = 1;
GO
