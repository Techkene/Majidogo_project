-- showing tables within the md_water_services database
SHOW TABLE STATUS;

-- Looking at one of the tables (location)
SELECT 
    *
FROM
    location
LIMIT 5;

-- Looking at the visits table 
SELECT 
    *
FROM
    visits
LIMIT 5;

-- Looking at water_source table
SELECT 
    *
FROM
    water_source
LIMIT 5;

-- Query for the unique types of water sources
SELECT DISTINCT
    type_of_water_source
FROM
    water_source;
    
-- Query that retrieves all records on visits with respect to time in queue not less than 500 times
SELECT 
    *
FROM
    visits
WHERE
    time_in_queue >= 500;
    
-- Query that shows certain source_id in water_source table as seen with a few of mine added
SELECT 
    *
FROM
    water_source
WHERE
    source_id IN ('AkRu05234224' , 'HaZa21742224',
        'AkKi00881224',
        'SoRu37635224',
        'SoRu36096224',
        'SoRu38776224',
        'HaRu19601224',
        'AkLu01628224',
        'SoRu35083224',
        'KiRu26095224');
        
-- Looking through the table to find the record for the quality of water sources ranging from 1 to 10 rating
SELECT DISTINCT
    subjective_quality_score, visit_count
FROM
    water_quality;
    
/*Query that finds records where subject_quality_score is 10 only looking for home taps,
and where the source was visited a second times (expected result is 218 rows) */

SELECT DISTINCT
    visits.record_id, visits.source_id
FROM
    visits
WHERE
    visits.record_id IN (SELECT 
            record_id
        FROM
            water_quality
        WHERE
            subjective_quality_score = 10 and visit_count = 2);

-- Record for contaminant few rows
SELECT 
    *
FROM
    well_pollution;

-- A query that checks if results is clean but the biological column is > 0.01
SELECT 
    *
FROM
    well_pollution
WHERE
    results = 'clean'
        AND biological > '0.01';
        
-- Query with incorrect description leading to wrong result placement (result should be 38 wrong descriptions aka rows)
SELECT DISTINCT
    *
FROM
    well_pollution
WHERE
    description LIKE 'clean_%';
    
-- Query that corrects the wrong descriptions and corresponding results
/* syntax for updating/correcting rows in column
update
 -- update well_pollution
 set
 -- change description to 'Bacteria: E. Coli'
 where
 -- where the description is 'Clean Bacteria: E. Coli' */
 
SET SQL_SAFE_UPDATES = 0;

UPDATE well_pollution 
SET 
    description = REPLACE(description,
        'Clean Bacteria: E. coli',
        'Bacteria: E. coli')
WHERE
    description LIKE '%Clean Bacteria: E. coli';
    
UPDATE well_pollution 
SET 
    description = REPLACE(description,
        'Clean Bacteria: Giardia Lamblia',
        'Bacteria: Giardia Lamblia')
WHERE
    description LIKE '%Clean Bacteria: Giardia Lamblia';
    
UPDATE well_pollution 
SET 
    results = CASE
        WHEN biological > 0.01 THEN 'Contaminated'
        ELSE 'Clean'
    END;
    
SET SQL_SAFE_UPDATES = 1;

/* I noticed that i kept getting safe mode errors while i was trying the update reserved word
	even when doing according to the assignment guide so i unchecked the safe mode
    using this syntax SET SQL_SAFE_UPDATES = 0; and to return it to the safe mode, i applied
    this syntax SET SQL_SAFE_UPDATES = 1;
*/

-- Query to check table to confirm corrections rightly made
SELECT 
    *
FROM
    well_pollution
WHERE
    description LIKE 'clean_%'
        OR (results = 'clean' AND biological > 0.01);