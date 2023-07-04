CREATE OR ALTER PROCEDURE AutoServicesSchema.spAccordion_Upsert
-- EXEC AutoServicesSchema.spAccordion_Upsert
    @AccordionId INT = NULL,
    @Question NVARCHAR(200),
    @Answer NVARCHAR(400),
    @IsInHomePage BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @AccordionId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.Accordion
                        SET Question = @Question,
                            Answer = @Answer,
                            IsInHomePage = @IsInHomePage
                        WHERE AccordionId = @AccordionId;
                END
            ELSE
                BEGIN
                    INSERT INTO AutoServicesSchema.Accordion (Question, Answer, IsInHomePage)
                        VALUES (@Question, @Answer, @IsInHomePage); 
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spAccordion_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating an accordion. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spAccordion_GetAllInHomePage
-- EXEC AutoServicesSchema.spAccordion_GetAllInHomePage
AS
BEGIN
    BEGIN TRY

        SELECT *
            FROM AutoServicesSchema.Accordion
            WHERE IsInHomePage = 1;

    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spAccordion_GetAllInHomePage', GETDATE());

        THROW 50003, 'An error occurred while retrieving accordion in home page. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spAccordion_GetAll
-- EXEC AutoServicesSchema.spAccordion_GetAll
AS
BEGIN
    BEGIN TRY

        SELECT *
            FROM AutoServicesSchema.Accordion;

    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spAccordion_GetAll', GETDATE());

        THROW 50003, 'An error occurred while retrieving all Accordions content. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spAccordion_Delete
-- EXEC AutoServicesSchema.spAccordion_Delete
@AccordionId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.Accordion
                WHERE AccordionId = @AccordionId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spAccordion_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting an accordion row. Please try again or contact support.', 1;
    END CATCH;
END;
GO