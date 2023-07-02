-- Add a check constraint for ImageAlignment to restrict values to 'left' or 'right' in TextWithImage table
ALTER TABLE AutoServicesSchema.TextWithImage
ADD CONSTRAINT CK_TextWithImage_ImageAlignment
CHECK (ImageAlignment IN ('left', 'right'));
GO

-- Add a check constraint for ImageAlignment to restrict values to 'left', 'right', or 'center' in HeroSection table
ALTER TABLE AutoServicesSchema.HeroSection
ADD CONSTRAINT CK_HeroSection_TextAlignment
CHECK (TextAlignment IN ('left', 'right', 'center'));
GO

