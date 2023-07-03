USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spStepsSection_Upsert
    -- EXEC AutoServicesSchema.spStepsSection_Upsert
    @StepsSectionId INT = NULL,
    @SectionId INT,
    @IsActive BIT = 0,
    @Title NVARCHAR(100) = NULL,
    @Subtitle NVARCHAR(200) = Null
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            IF @StepsSectionId IS NULL
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

                    INSERT INTO AutoServicesSchema.StepsSection (ContainerId, Title, Subtitle)
                    VALUES (@sc_ContainerId, @Title, @Subtitle);
                END
                ELSE
                BEGIN
                    UPDATE AutoServicesSchema.StepsSection
                    SET Title = @Title,
                        Subtitle = @Subtitle
                    WHERE StepsSectionId = @StepsSectionId;
                END
        COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spStepsSection_Upsert', GETDATE());

        THROW 50003, @ErrorMessage, 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spStepsSection_Delete
-- EXEC AutoServicesSchema.spStepsSection_Delete
@StepsSectionId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @DeletedOrderSequence INT;
            DECLARE @ContainerId INT;

            SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
                @ContainerId = StepsSection.ContainerId
                FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                    JOIN AutoServicesSchema.StepsSection AS StepsSection
                        ON SectionsConfig.ContainerId = StepsSection.ContainerId
                WHERE StepsSection.StepsSectionId = @StepsSectionId;

            DELETE FROM AutoServicesSchema.StepsSection
                WHERE StepsSectionId = @StepsSectionId;

            Delete FROM AutoServicesSchema.WorkSteps
                WHERE StepsSectionId = @StepsSectionId;

            EXEC AutoServicesSchema.spSectionsConfig_Delete @ContainerId = @ContainerId;

            EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder @DeletedOrderSequence;

            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spStepsSection_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting the Work Steps Section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spWorkSteps_Upsert
-- EXEC AutoServicesSchema.spWorkSteps_Upsert
    @WorkStepId INT = NULL,
    @StepsSectionId INT = NULL,
    @IconId INT,
    @Title NVARCHAR(100),
    @Summary NVARCHAR(300)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @WorkStepId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.WorkSteps
                        SET IconId = @IconId,
                            Title = @Title,
                            Summary = @Summary
                        WHERE WorkStepId = @WorkStepId 
                            AND StepsSectionId = @StepsSectionId;
                END
            ELSE
                BEGIN
                    IF @StepsSectionId IS NOT NULL
                        BEGIN
                            INSERT INTO AutoServicesSchema.WorkSteps (StepsSectionId, IconId, Title, Summary)
                                VALUES (@StepsSectionId, @IconId, @Title, @Summary); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Steps section doesn''t exist. Create a Steps section before adding a Work step',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spWorkSteps_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating a Work step. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spWorkSteps_GetAll
-- EXEC AutoServicesSchema.spWorkSteps_GetAll
@StepsSectionId INT
AS
BEGIN
    BEGIN TRY
        SELECT  WorkSteps.WorkStepId, WorkSteps.StepsSectionId, Icons.IconName, WorkSteps.Title, WorkSteps.Summary
            FROM AutoServicesSchema.WorkSteps AS WorkSteps
                JOIN AutoServicesSchema.Icons AS Icons
                    ON WorkSteps.IconId = Icons.IconId
            WHERE WorkSteps.StepsSectionId = @StepsSectionId;

    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spWorkSteps_GetAll', GETDATE());

        THROW 50003, 'An error occurred while retrieving all work steps card. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spWorkSteps_Delete
-- EXEC AutoServicesSchema.spWorkSteps_Delete
@WorkStepId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.WorkSteps
                WHERE WorkStepId = @WorkStepId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spWorkSteps_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting a Work step card. Please try again or contact support.', 1;
    END CATCH;
END;
GO