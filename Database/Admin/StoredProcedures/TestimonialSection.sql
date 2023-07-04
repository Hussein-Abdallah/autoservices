USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTestimonialSection_Upsert
    -- EXEC AutoServicesSchema.spTestimonialSection_Upsert
    @TestimonialSectionId INT = NULL,
    @SectionId INT,
    @IsActive BIT = 0,
    @Title NVARCHAR(100) = NULL,
    @Subtitle NVARCHAR(200) = Null
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            IF @TestimonialSectionId IS NULL
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

                    INSERT INTO AutoServicesSchema.TestimonialSection (ContainerId, Title, Subtitle)
                    VALUES (@sc_ContainerId, @Title, @Subtitle);
                END
                ELSE
                BEGIN
                    UPDATE AutoServicesSchema.TestimonialSection
                    SET Title = @Title,
                        Subtitle = @Subtitle
                    WHERE TestimonialSectionId = @TestimonialSectionId;
                END
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spTestimonialSection_Upsert', GETDATE());

        THROW 50003, @ErrorMessage, 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTestimonialSection_Delete
-- EXEC AutoServicesSchema.spTestimonialSection_Delete
@TestimonialSectionId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @DeletedOrderSequence INT;
            DECLARE @ContainerId INT;

            SELECT @DeletedOrderSequence = SectionsConfig.OrderSequence,
                @ContainerId = TestimonialSection.ContainerId
                FROM AutoServicesSchema.SectionsConfig AS SectionsConfig
                    JOIN AutoServicesSchema.TestimonialSection AS TestimonialSection
                        ON SectionsConfig.ContainerId = TestimonialSection.ContainerId
                WHERE TestimonialSection.TestimonialSectionId = @TestimonialSectionId;

            DELETE FROM AutoServicesSchema.Testimonies
                WHERE TestimonialSectionId = @TestimonialSectionId;

            Delete FROM AutoServicesSchema.TestimonialSection
                WHERE TestimonialSectionId = @TestimonialSectionId;

            EXEC AutoServicesSchema.spSectionsConfig_Delete @ContainerId = @ContainerId;

            EXEC AutoServicesSchema.spSectionsConfig_AdjustSequenceOrder @DeletedOrderSequence;

            COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        DECLARE @ErrorMessage NVARCHAR(200) = ERROR_MESSAGE();
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (@ErrorMessage, ERROR_NUMBER(), 'AutoServicesSchema.spTestimonialSection_Delete', GETDATE());

        THROW 50004, @ErrorMessage, 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTestimonies_Upsert
-- EXEC AutoServicesSchema.spTestimonies_Upsert
    @TestimonyId INT = NULL,
    @TestimonialSectionId INT = NULL,
    @Content NVARCHAR(300),
    @ClientName NVARCHAR(100),
    @ImageUrl NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @TestimonyId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.Testimonies
                        SET Content = @Content,
                            ClientName = @ClientName,
                            ImageUrl = @ImageUrl
                        WHERE TestimonyId = @TestimonyId 
                            AND TestimonialSectionId = @TestimonialSectionId;
                END
            ELSE
                BEGIN
                    IF @TestimonialSectionId IS NOT NULL
                        BEGIN
                            INSERT INTO AutoServicesSchema.Testimonies (TestimonialSectionId, Content, ClientName, ImageUrl)
                                VALUES (@TestimonialSectionId, @Content, @ClientName, @ImageUrl); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Testimonial section doesn''t exist. Create a Testimonial section before adding a testimony',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTestimonies_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating a Testimony. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTestimonies_GetAll
-- EXEC AutoServicesSchema.spTestimonies_GetAll
@TestimonialSectionId INT
AS
BEGIN
    BEGIN TRY
        SELECT Content, ClientName, ImageUrl
            FROM AutoServicesSchema.Testimonies
            WHERE TestimonialSectionId = @TestimonialSectionId;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTestimonies_GetAll', GETDATE());

        THROW 50003, 'An error occurred while retrieving all testimonies. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spTestimonies_Delete
-- EXEC AutoServicesSchema.spTestimonies_Delete
@TestimonyId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.Testimonies
                WHERE TestimonyId = @TestimonyId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spTestimonies_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting a testimony. Please try again or contact support.', 1;
    END CATCH;
END;
GO