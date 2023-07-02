USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spBanner_Upsert
-- EXEC AutoServicesSchema.spBanner_Create
@BannerId INT = NULL,
@SectionId INT,
@IsActive BIT = 0,
@ImageUrl NVARCHAR(100) = Null,
@Content NVARCHAR(100) = Null,
@CtaActive BIT = 0,
@ButtonLabel NVARCHAR(50) = NULL,
@ButtonLink NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @BannerId IS NULL
        BEGIN
            DECLARE @sc_ErrorMessage NVARCHAR(200);
            DECLARE @sc_ContainerId INT;

            EXEC AutoServicesSchema.spSectionsConfig_InsertSection
                @sc_SectionId = @SectionId,
                @sc_IsActive = @IsActive,
                @sc_ContainerId = @sc_ContainerId OUTPUT,
                @sc_ErrorMessage = @sc_ErrorMessage OUTPUT;

            IF @sc_ErrorMessage IS NOT NULL
            BEGIN
                ROLLBACK;
                THROW 50002, @sc_ErrorMessage, 1;
            END;

            INSERT INTO AutoServicesSchema.Banner (ContainerId, ImageUrl, Content, CtaActive, ButtonLabel, ButtonLink)
            VALUES (@sc_ContainerId, @ImageUrl, @Content, @CtaActive, @ButtonLabel, @ButtonLink);
        END
        ELSE
        BEGIN
            UPDATE AutoServicesSchema.Banner
            SET ImageUrl = @ImageUrl,
                Content = @Content,
                CtaActive = @CtaActive,
                ButtonLabel = @ButtonLabel,
                ButtonLink = @ButtonLink
            WHERE BannerId = @BannerId;
        END

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spBanner_Upsert', GETDATE());

        THROW 50003, 'An error occurred while creating/updating the banner. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spBanner_Delete
-- EXEC AutoServicesSchema.spBanner_Delete
@BannerId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get the OrderSequence of the banner being deleted
        DECLARE @DeletedOrderSequence INT;
        DECLARE @ContainerId INT;

        SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
            @ContainerId = Banner.ContainerId
            FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                JOIN AutoServicesSchema.Banner AS Banner
                    ON SectionsConfig.ContainerId = Banner.ContainerId
            WHERE Banner.BannerId = @BannerId;

        -- Delete the banner from Banner table
        DELETE FROM AutoServicesSchema.Banner
        WHERE BannerId = @BannerId;

        -- Delete the record from SectionsConfig
        EXEC AutoServicesSchema.spSectionsConfig_Delete @ContainerId = @ContainerId;

        -- Adjust the sequence order for remaining banners
        EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder @DeletedOrderSequence;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spBanner_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting the banner. Please try again or contact support.', 1;
    END CATCH;
END;
GO