CREATE OR ALTER PROCEDURE AutoServicesSchema.spBlog_Upsert
-- EXEC AutoServicesSchema.spBlog_Upsert
    @BlogId INT = NULL,
    @ImageUrl NVARCHAR(100),
    @Title NVARCHAR(100),
    @Summary NVARCHAR(250),
    @Content NVARCHAR(MAX),
    @Author NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @BlogId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.Blog
                        SET ImageUrl = @ImageUrl,
                            Title = @Title,
                            Summary = @Summary,
                            Content = @Content,
                            Author = @Author
                        WHERE BlogId = @BlogId;
                END
            ELSE
                BEGIN
                    INSERT INTO AutoServicesSchema.Blog (ImageUrl, Title, Summary, Content, CreatedAt, Author)
                        VALUES (@ImageUrl, @Title, @Summary, @Content, GETDATE(), @Author); 
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spBlog_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating a blog. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spBlog_GetLatest
-- EXEC AutoServicesSchema.spBlog_GetLatest
AS
BEGIN
    BEGIN TRY

        SELECT TOP 2 *
            FROM AutoServicesSchema.Blog
            ORDER BY CreatedAt DESC;

    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spBlog_GetLatest', GETDATE());

        THROW 50003, 'An error occurred while retrieving latest 2 blogs. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spBlog_GetAll
-- EXEC AutoServicesSchema.spBlog_GetAll
AS
BEGIN
    BEGIN TRY

        SELECT *
            FROM AutoServicesSchema.Blog;

    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spBlog_GetAll', GETDATE());

        THROW 50003, 'An error occurred while retrieving all blogs. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spBlog_Delete
-- EXEC AutoServicesSchema.spBlog_Delete
@BlogId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.Blog
                WHERE BlogId = @BlogId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spBlog_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting a blog. Please try again or contact support.', 1;
    END CATCH;
END;
GO