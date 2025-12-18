-- Update duration column from INT to VARCHAR to support format like "2 year 5 months"
ALTER TABLE ug_em_allotment_details
ALTER COLUMN duration TYPE VARCHAR(50);
