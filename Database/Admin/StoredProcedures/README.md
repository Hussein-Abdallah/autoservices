## List of Stored Procedures per table
  ### Sections
   we need to create all the sections and the maximum number of each section allowed inside the **Sections** Table so that the web admin can modify the layout and content.

  ```sql
    EXEC AutoServicesSchema.spSections_Upsert @SectionTitle = 'Banner', @MaxNumber = 3;
    GO
  ```

  - [Sections](./Sections.sql)
  - [SectionsConfig](./SectionsConfig.sql)
  - [Banner](./Banner.sql)

  ### Standalone Sections
  - [Top Bar](./TopBar.sql)
  - [Header]()
  - [Footer]()