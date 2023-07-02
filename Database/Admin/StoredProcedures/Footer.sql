USE AutoServicesDb;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spFooter_Upsert
-- EXEC AutoServicesSchema.spHeader_Upsert
@FooterId INT = NULL,
@IsAboutActive BIT = 1,
@AboutTitle NVARCHAR(100) = NULL,
@AboutSummary NVARCHAR(300) = NULL,
@IsFooterNavigationActive BIT = 1,
@NavigationTitle NVARCHAR(50) = NULL,
@IsSupportLinksActive BIT = 1,
@SupportLinksTitle NVARCHAR(50) = NULL,
@IsContactInfoActive BIT = 1,
@ContactTitle NVARCHAR(100) = NULL,
@Email NVARCHAR(100) = NULL,
@Telephone NVARCHAR(15) = NULL,
@WorkingHours NVARCHAR(50) = NULL,
@IsNewsletterActive BIT = 1,
@CopyrightMessage NVARCHAR(150) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @FooterId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.Footer
                        SET IsAboutActive = @IsAboutActive,
                            AboutTitle = @AboutTitle,
                            AboutSummary = @AboutSummary,
                            IsFooterNavigationActive = @IsFooterNavigationActive,
                            NavigationTitle = @NavigationTitle,
                            IsSupportLinksActive = @IsSupportLinksActive,
                            SupportLinksTitle = @SupportLinksTitle,
                            IsContactInfoActive = @IsContactInfoActive,
                            ContactTitle = @ContactTitle,
                            Email = @Email,
                            Telephone = @Telephone,
                            WorkingHours = @WorkingHours,
                            IsNewsletterActive = @IsNewsletterActive,
                            CopyrightMessage = @CopyrightMessage
                        WHERE FooterId = @FooterId;
                END
            ELSE
                BEGIN
                    DECLARE @numberOfRows INT;
                    SELECT @numberOfRows = COUNT(*) FROM AutoServicesSchema.Footer;

                    IF @numberOfRows = 0
                        BEGIN
                            INSERT INTO AutoServicesSchema.Footer (IsAboutActive,
                                AboutTitle,
                                AboutSummary,
                                IsFooterNavigationActive,
                                NavigationTitle,
                                IsSupportLinksActive,
                                SupportLinksTitle,
                                IsContactInfoActive,
                                ContactTitle,
                                Email,
                                Telephone,
                                WorkingHours,
                                IsNewsletterActive,
                                CopyrightMessage)
                            VALUES (
                                @IsAboutActive,
                                @AboutTitle,
                                @AboutSummary,
                                @IsFooterNavigationActive,
                                @NavigationTitle,
                                @IsSupportLinksActive,
                                @SupportLinksTitle,
                                @IsContactInfoActive,
                                @ContactTitle,
                                @Email,
                                @Telephone,
                                @WorkingHours,
                                @IsNewsletterActive,
                                @CopyrightMessage
                            ); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Footer section already exist. You can only create 1 Footer section',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spFooter_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating the Footer section. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spFooter_GetInfo
-- EXEC AutoServicesSchema.spFooter_GetInfo
AS
BEGIN
    BEGIN TRY
        SELECT IsAboutActive,
            AboutTitle,
            AboutSummary,
            IsFooterNavigationActive,
            NavigationTitle,
            IsSupportLinksActive,
            SupportLinksTitle,
            IsContactInfoActive,
            ContactTitle,
            Email,
            Telephone,
            WorkingHours,
            IsNewsletterActive,
            CopyrightMessage
        FROM AutoServicesSchema.Footer;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spFooter_GetInfo', GETDATE());

        THROW 50003, 'An error occurred while retrieving Footer section information. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spFooter_Delete
-- EXEC AutoServicesSchema.spFooter_Delete
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.SupportLinks;
            
            DELETE FROM AutoServicesSchema.Footer;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spFooter_Delete', GETDATE());

        THROW 50004, 'An error occurred while deleting Footer data. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSupportLinks_Upsert
-- EXEC AutoServicesSchema.spSupportLinks_Upsert
    @SupportLinkId INT = NULL,
    @FooterId INT = NULL,
    @Title NVARCHAR(50) = NULL,
    @LinkUrl NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @SupportLinkId IS NOT NULL
                BEGIN
                    UPDATE AutoServicesSchema.SupportLinks
                        SET Title = @Title,
                            LinkUrl = @LinkUrl
                        WHERE SupportLinkId = @SupportLinkId;
                END
            ELSE
                BEGIN
                    IF @FooterId IS NOT NULL
                        BEGIN
                            INSERT INTO AutoServicesSchema.SupportLinks (FooterId, Title, LinkUrl)
                                VALUES (@FooterId, @Title, @LinkUrl); 
                        END
                    ELSE
                        BEGIN;
                            THROW 50001, 'Footer section doesn''t exist. Create a footer section before adding a support link',1;
                        END
                END            
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
            VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spSupportLinks_Upsert', GETDATE());

        THROW 50002, 'An error occurred while creating or updating a Support Link. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSupportLinks_GetInfo
-- EXEC AutoServicesSchema.spSupportLinks_GetInfo
AS
BEGIN
    BEGIN TRY
        SELECT SupportLinkId, Title, LinkUrl
        FROM AutoServicesSchema.SupportLinks;
    END TRY
    BEGIN CATCH
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spSupportLinks_GetInfo', GETDATE());

        THROW 50003, 'An error occurred while retrieving the support links. Please try again or contact support.', 1;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE AutoServicesSchema.spSupportLinks_DeleteLink
-- EXEC AutoServicesSchema.spSupportLinks_DeleteLink
@SupportLinkId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DELETE FROM AutoServicesSchema.SupportLinks
                WHERE SupportLinkId = @SupportLinkId;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        
        INSERT INTO AutoServicesSchema.ErrorLog (ErrorMessage, ErrorNumber, ProcedureName, LogTimestamp)
        VALUES (ERROR_MESSAGE(), ERROR_NUMBER(), 'AutoServicesSchema.spSupportLinks_DeleteLink', GETDATE());

        THROW 50004, 'An error occurred while deleting a support link. Please try again or contact support.', 1;
    END CATCH;
END;
GO

