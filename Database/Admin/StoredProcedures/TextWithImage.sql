USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTextWithImage_Upsert
-- EXEC AutoServicesSchema.spTextWithImage_Upsert @SectionId
    @TextWithImageId INT = NULL,
    @SectionId INT,
    @IsActive BIT = 0,
    @Title NVARCHAR(100) = NULL,
    @Subtitle NVARCHAR(200) = NULL,
    @Content NVARCHAR(600) = NULL,
    @CtaActive BIT = 0,
    @ButtonLabel NVARCHAR(50) = NULL,
    @ButtonLink NVARCHAR(100) = NULL,
    @ImageUrl NVARCHAR(100) = NULL,
    @ImageAlignment NVARCHAR(5) = 'left'
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @TextWithImageId IS NULL
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

            INSERT INTO AutoServicesSchema.TextWithImage (ContainerId, Title, Subtitle, Content, CtaActive, ButtonLabel, ButtonLink, ImageUrl, ImageAlignment)
            VALUES (@sc_ContainerId, @Title, @Subtitle, @Content, @CtaActive, @ButtonLabel, @ButtonLink, @ImageUrl, @ImageAlignment);
        END
        ELSE
        BEGIN
            UPDATE AutoServicesSchema.TextWithImage
            SET Title = @Title,
                Subtitle = @Subtitle,
                CtaActive = @CtaActive,
                ButtonLabel = @ButtonLabel,
                ButtonLink = @ButtonLink,
                ImageUrl = @ImageUrl,
                ImageAlignment = @ImageAlignment
            WHERE TextWithImageId = @TextWithImageId;
        END;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTextWithImage_Upsert', GETDATE());

        THROW 50003, 'An error occurred while creating/updating the "Text with image" section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTextWithImage_Delete
-- EXEC AutoServicesSchema.spTextWithImage_Delete
@TextWithImageId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get the OrderSequence of the banner being deleted
        DECLARE @DeletedOrderSequence INT;
        DECLARE @ContainerId INT;

        SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
            @ContainerId = TextWithImage.ContainerId
            FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                JOIN AutoServicesSchema.TextWithImage AS TextWithImage
                    ON SectionsConfig.ContainerId = TextWithImage.ContainerId
            WHERE TextWithImage.TextWithImageId = @TextWithImageId;

        -- Delete the banner from Banner table
        DELETE FROM AutoServicesSchema.TextWithImage
        WHERE TextWithImageId = @TextWithImageId;

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
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTextWithImage_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting the "Text with image" section. Please try again or contact support.', 1;
    END CATCH;
END;
GO