USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSections_Upsert
    @SectionId INT = NULL,
    @SectionTitle NVARCHAR(50),
    @MaxNumber INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @IsSectionExist INT;

        SELECT @IsSectionExist = COUNT(*) FROM AutoServicesSchema.Sections AS Sections
            WHERE Sections.SectionTitle = @SectionTitle;

        IF @SectionId IS NULL
        BEGIN
            IF @IsSectionExist = 0
                BEGIN
                    INSERT INTO AutoServicesSchema.Sections (SectionTitle, MaxNumber)
                    VALUES (@SectionTitle, @MaxNumber);
                END
            ELSE
                BEGIN;
                    DECLARE @ErrorMessage NVARCHAR(100)
                    SET @ErrorMessage = 'Section "' + @SectionTitle +'" already exists in the database.';
                    THROW 50001, @ErrorMessage, 1;
                END
        END
        ELSE
        BEGIN
            UPDATE AutoServicesSchema.Sections
            SET SectionTitle = @SectionTitle,
                MaxNumber = @MaxNumber
            WHERE SectionId = @SectionId;
        END

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spSections_Upsert', GETDATE());

        THROW 50004, 'An error occurred while creating/updating a section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSections_GetAll
AS
BEGIN
    SELECT * FROM AutoServicesSchema.Sections;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSections_Delete
    @SectionId INT
AS
BEGIN
    -- Delete associated records from SectionsConfig table
    DELETE FROM AutoServicesSchema.SectionsConfig WHERE SectionId = @SectionId;

    -- Empty the table of the section
    DELETE FROM AutoServicesSchema.Sections WHERE SectionId = @SectionId;
END;
GO