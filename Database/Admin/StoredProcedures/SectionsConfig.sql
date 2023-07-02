USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSectionsConfig_Delete
-- EXEC AutoServicesSchema.spDeleteFromSectionsConfig
@ContainerId INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM AutoServicesSchema.SectionsConfig
        WHERE ContainerId = @ContainerId;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spSectionsConfig_Delete', GETDATE());

        THROW 50001, 'An error occurred while deleting from SectionsConfig. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder
-- EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder
@DeletedOrderSequence INT
AS
BEGIN
    BEGIN TRY
        UPDATE AutoServicesSchema.SectionsConfig
        SET OrderSequence = OrderSequence - 1
        WHERE OrderSequence > @DeletedOrderSequence;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder', GETDATE());

        THROW 50002, 'An error occurred while adjusting sequence order. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSectionsConfig_CheckMaxSections
    @SectionId INT,
    @MaxSectionNumber INT,
    @ErrorMessage NVARCHAR(100) OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @CurrentSectionCount INT;

        SELECT @CurrentSectionCount = COUNT(*)
        FROM AutoServicesSchema.SectionsConfig
        WHERE SectionId = @SectionId;

        IF @CurrentSectionCount >= @MaxSectionNumber
        BEGIN
            SET @ErrorMessage = 'Cannot create additional sections. Maximum number of sections reached for the section type.';
        END
        ELSE
        BEGIN
            SET @ErrorMessage = NULL;
        END
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spCheckMaxSections', GETDATE());

        THROW 50001, 'An error occurred while checking the maximum number of sections. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSectionsConfig_InsertSection
    @sc_SectionId INT,
    @sc_IsActive BIT,
    @sc_ContainerId INT OUTPUT,
    @sc_ErrorMessage NVARCHAR(200) OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @MaxSectionNumber INT;

        SELECT @MaxSectionNumber = MaxNumber
        FROM AutoServicesSchema.Sections
        WHERE SectionId = @sc_SectionId;

        IF @MaxSectionNumber IS NULL
        BEGIN;
            THROW 50002, 'Section doesn''t exist.', 1;
        END

        EXEC AutoServicesSchema.spSectionsConfig_CheckMaxSections
            @SectionId = @sc_SectionId,
            @MaxSectionNumber = @MaxSectionNumber,
            @ErrorMessage = @sc_ErrorMessage OUTPUT;

        IF @sc_ErrorMessage IS NOT NULL
        BEGIN;
            THROW 50002, @sc_ErrorMessage, 1;
        END

        DECLARE @MaxOrderSequence INT;

        -- Get the maximum order sequence of all sections
        SELECT @MaxOrderSequence = ISNULL(MAX(OrderSequence), 0)
        FROM AutoServicesSchema.SectionsConfig;

        INSERT INTO AutoServicesSchema.SectionsConfig (SectionId, OrderSequence, IsActive)
        VALUES (@sc_SectionId, @MaxOrderSequence + 1, @sc_IsActive);

        SET @sc_ContainerId = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spSectionsConfig_InsertSection', GETDATE());

        THROW 50003, 'An error occurred while creating/updating the Hero Section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

