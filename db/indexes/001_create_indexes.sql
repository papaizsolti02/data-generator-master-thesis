IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Users_Raw_UserID_BatchId'
      AND object_id = OBJECT_ID('stg.Users_Raw')
)
BEGIN
    CREATE INDEX IX_Users_Raw_UserID_BatchId
        ON stg.Users_Raw (UserID, BatchId);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_DimUser_UserID_IsCurrent'
      AND object_id = OBJECT_ID('dw.DimUser')
)
BEGIN
    CREATE INDEX IX_DimUser_UserID_IsCurrent
        ON dw.DimUser (UserID, IsCurrent)
        INCLUDE (HashDiff, EffectiveFrom, EffectiveTo);
END
GO
