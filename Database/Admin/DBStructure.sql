CREATE DATABASE AutoServicesDb
GO

USE AutoServicesDb
GO

CREATE SCHEMA AutoServicesSchema
GO

CREATE TABLE AutoServicesSchema.Sections (
    SectionId INT IDENTITY(1,1) PRIMARY KEY,
    SectionTitle NVARCHAR(50),
    MaxNumber INT
);
GO

CREATE TABLE AutoServicesSchema.SectionsConfig(
    ContainerId INT IDENTITY(1,1) PRIMARY KEY,
    SectionId INT,
    OrderSequence INT,
    IsActive BIT DEFAULT 0,
    IsInNavigation BIT DEFAULT 0,
    FOREIGN KEY (SectionId) REFERENCES AutoServicesSchema.Sections (SectionId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.Icons(
    IconId INT IDENTITY(1,1) PRIMARY KEY,
    IconName NVARCHAR(100)
);
GO

CREATE TABLE AutoServicesSchema.TopBar (
    TopBarId INT DEFAULT 1,
    Announcement NVARCHAR(100),
    CtaActive BIT,
    ButtonLabel NVARCHAR(50),
    ButtonLink NVARCHAR(100),
    IsActive BIT DEFAULT 0,
);
GO

CREATE TABLE AutoServicesSchema.Header(
    HeaderId INT IDENTITY(1,1) PRIMARY KEY,
    LogoImage NVARCHAR(100),
    LogoTitle NVARCHAR(100),
    IsNavigationActive BIT
);
GO

CREATE TABLE AutoServicesSchema.HeroSection (
    HeroSectionId INT IDENTITY(1, 1) PRIMARY KEY,
    ContainerId INT,
    Title NVARCHAR(100),
    Subtitle NVARCHAR(200),
    CtaActive BIT,
    ButtonLabel NVARCHAR(50),
    ButtonLink NVARCHAR(100),
    ImageUrl NVARCHAR(100),
    TextAlignment NVARCHAR(5),
    FOREIGN KEY (ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.ServiceSection(
    ServiceSectionId INT IDENTITY(1,1) PRIMARY KEY,
    ContainerId INT,
    Title NVARCHAR(100),
    Subtitle NVARCHAR(200),
    FOREIGN KEY(ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.ServiceCard(
    CardId INT IDENTITY(1,1) PRIMARY KEY,
    ServiceSectionId INT,
    IconId INT,
    Price DECIMAL(6,2),
    Title NVARCHAR(50),
    Summary NVARCHAR(150),
    FOREIGN KEY(ServiceSectionId) REFERENCES AutoServicesSchema.ServiceSection(ServiceSectionId) ON DELETE CASCADE,
    FOREIGN KEY (IconId) REFERENCES AutoServicesSchema.Icons(IconId)
);
GO

CREATE TABLE AutoServicesSchema.TextWithImage (
    TextWithImageId INT IDENTITY(1, 1) PRIMARY KEY,
    ContainerId INT,
    Title NVARCHAR(100),
    Subtitle NVARCHAR(200),
    Content NVARCHAR(600),
    CtaActive BIT,
    ButtonLabel NVARCHAR(50),
    ButtonLink NVARCHAR(100),
    ImageUrl NVARCHAR(100),
    ImageAlignment NVARCHAR(5),
    FOREIGN KEY (ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.StepsSection(
    StepsSectionId INT IDENTITY(1,1) PRIMARY KEY,
    ContainerId INT,
    Title NVARCHAR(100),
    Subtitle NVARCHAR(100),
    FOREIGN KEY (ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.WorkSteps(
    WorkStepId INT IDENTITY(1,1) PRIMARY KEY,
    StepsSectionId INT,
    IconId INT,
    Title NVARCHAR(100),
    Summary NVARCHAR(250),
    FOREIGN KEY (StepsSectionId) REFERENCES AutoServicesSchema.StepsSection(StepsSectionId) ON DELETE CASCADE,
    FOREIGN KEY (IconId) REFERENCES AutoServicesSchema.Icons(IconId)
);
GO

CREATE TABLE AutoServicesSchema.Banner (
    BannerId INT IDENTITY(1,1) PRIMARY KEY,
    ContainerId INT, 
    ImageUrl NVARCHAR(100),
    Summary NVARCHAR(100),
    CallToActionActive BIT,
    ButtonLabel NVARCHAR(50),
    ButtonLink NVARCHAR(100),
    FOREIGN KEY(ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.MobileApp(
    MobileAppId INT IDENTITY(1,1) PRIMARY KEY,
    ContainerId INT,
    Title NVARCHAR(100),
    Subtitle NVARCHAR(200),
    AppDescription NVARCHAR(500),
    AndroidUrl NVARCHAR(200),
    AppleUrl NVARCHAR(200),
    FOREIGN KEY (ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.CounterCard(
    CounterCardId INT IDENTITY(1,1) PRIMARY Key,
    MobileAppId INT,
    IconId INT,
    Total INT,
    Title NVARCHAR(100),
    FOREIGN KEY (MobileAppId) REFERENCES AutoServicesSchema.MobileApp(MobileAppId) ON DELETE CASCADE,
    FOREIGN KEY (IconId) REFERENCES AutoServicesSchema.Icons(IconId)
);
GO

CREATE TABLE AutoServicesSchema.TestimonialSection(
    TestimonialSectionId INT IDENTITY(1,1) PRIMARY KEY,
    ContainerId INT,
    Title NVARCHAR(100),
    Subtitle NVARCHAR(100),
    FOREIGN KEY (ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.Testimonies(
    TestimonyId INT IDENTITY(1,1) PRIMARY KEY,
    TestimonialSectionId INT,
    Content NVARCHAR(300),
    ClientName NVARCHAR(100),
    ImageUrl NVARCHAR(100),
    FOREIGN KEY (TestimonialSectionId) REFERENCES AutoServicesSchema.TestimonialSection(TestimonialSectionId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.InformationSection(
    InformationSectionId INT IDENTITY(1,1) PRIMARY KEY,
    ContainerId INT,
    IsAccordionActive BIT,
    IsBlogActive BIT,
    FOREIGN KEY (ContainerId) REFERENCES AutoServicesSchema.SectionsConfig(ContainerId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.Accordion(
    AccordionId INT IDENTITY(1,1) PRIMARY KEY,
    InformationSectionId INT,
    Question NVARCHAR(200),
    Answer NVARCHAR(400),
    FOREIGN KEY (InformationSectionId) REFERENCES AutoServicesSchema.InformationSection(InformationSectionId) ON DELETE CASCADE
);
GO

CREATE TABLE AutoServicesSchema.Blog(
    BlogId INT IDENTITY(1,1) PRIMARY KEY,
    InformationSectionId INT,
    ImageUrl NVARCHAR(100),
    Title NVARCHAR(100),
    Summary NVARCHAR(250),
    Content NVARCHAR(MAX),
    CreatedAt DATETIME,
    Author NVARCHAR(100),
    FOREIGN KEY (InformationSectionId) REFERENCES AutoServicesSchema.InformationSection(InformationSectionId)
);
GO

CREATE TABLE AutoServicesSchema.Footer(
    FooterId INT IDENTITY(1,1) PRIMARY KEY,
    IsAboutActive BIT,
    AboutTitle NVARCHAR(100),
    AboutSummary NVARCHAR(300),
    IsFooterNavigationActive BIT,
    NavigationTitle NVARCHAR(50),
    IsSupportLinksActive BIT,
    SupportLinksTitle NVARCHAR(50),
    IsContactInfoActive BIT,
    ContactTitle NVARCHAR(100),
    Email NVARCHAR(100),
    Telephone NVARCHAR(15),
    WorkingHours NVARCHAR(50),
    IsNewsletterActive BIT,
    CopyrightMessage NVARCHAR(150)
);
GO

CREATE TABLE AutoServicesSchema.SupportLinks(
    SupportLinkId INT IDENTITY(1,1) PRIMARY KEY,
    FooterId INT,
    Title NVARCHAR(50),
    LinkUrl NVARCHAR(100),
    FOREIGN KEY (FooterId) REFERENCES AutoServicesSchema.Footer(FooterId)
);
GO

CREATE TABLE AutoServicesSchema.Newsletter(
    id INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(100)
);
GO

CREATE TABLE AutoServicesSchema.ErrorLog (
    ErrorLogId INT IDENTITY(1, 1) PRIMARY KEY,
    ErrorMessage NVARCHAR(MAX),
    ErrorNumber INT,
    ProcedureName NVARCHAR(255),
    LogTimestamp DATETIME
);
GO