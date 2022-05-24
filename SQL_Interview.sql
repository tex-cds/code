-- Interview Assignment 1: Find the email activity rank for each user. Email activity rank is defined by the total number of emails sent. The user with the highest number of emails sent will have a rank of 1, and so on. Output the user, total emails, and their activity rank. Order records by the total emails in descending order. Sort users with the same number of emails in alphabetical order.
--             In your rankings, return a unique value (i.e., a unique rank) even if multiple users have the same number of emails.

-- Create CTE to combine to_user and from_user fields, and to derive a count of all emails for all users
with total_emails AS(
SELECT from_user AS user, count(*) AS email_count
FROM google_gmail_emails
GROUP BY from_user
UNION
SELECT to_user AS user, count(*) AS email_count
FROM google_gmail_emails
GROUP BY to_user
)

SELECT *, 
ROW_NUMBER() OVER(ORDER BY email_count DESC, user ASC) AS ranking
FROM total_emails




-- Interview Assignment 2: Find the titles of workers that earn the highest salary. Output the highest-paid title or multiple titles that share the highest salary.

SELECT worker_title FROM worker w
INNER JOIN title t ON t.worker_ref_id = w.worker_id
WHERE salary = (SELECT max(salary) FROM worker)



-- Real World Example 1: Create a data check to be displayed on the UI alongside existing results that shows categories which are not in use

INSERT INTO data_check (name, description, sql, flag_external, flag_internal, notify, short_name, resolution)
VALUES (903, 'Returns products that are linked to a category that is no longer in use', 'CALL data_check_903', 0, 1, 0, 'Products with Inactive Category', 'Add at least one category from the current data set against the products');

CREATE TABLE dc_results_903 (id INT, product VARCHAR(100), category VARCHAR(100));

CREATE PROCEDURE data_check_903
BEGIN

TRUNCATE TABLE dc_results_903;

INSERT INTO dc_results_903 
SELECT id, p.name, c.name FROM product p
INNER JOIN product_category pc USING(product_id)
INNER JOIN category c ON c.category_id = pc.category_id
WHERE c.enabled = 0;

UPDATE data_check SET updated_datetime = NOW() WHERE `name` = 903;



-- Real World Example 2: this is a small part of a larger project where distance was calculated to the nearest station using PostGIS functions for geospatial transformation

SELECT * FROM 
(SELECT st_distance(
             st_transform(st_geomfromtext('POINT($longitude $latitude)', 4326), 27700), cds.boundary_table.geom
                   ) AS metres_to_station,
distinctname AS station_name,
'train'::text AS station_classification
FROM cds.boundary_table
WHERE function ILIKE '%train station%'
AND distinctname IS NOT NULL
ORDER BY metres_to_station ASC
LIMIT 1) AS trainStation