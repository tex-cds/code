## Code Snippets ✂️

Here on the ReadMe you can find some quick coding challenges I've completed and small samples of SQL/Python that I use often or just find helpful/interesting.<br><br>
Be sure to check out the files above, packed with SQL and Python goodness.<br>

---

### Typical Interview Challenges 🤔

#### SQL

Assignment 1:<br><br>
Find the email activity rank for each user. Email activity rank is defined by the total number of emails sent. The user with the highest number of emails sent will have a rank of 1, and so on. Output the user, total emails, and their activity rank. 
<br><br> Order records by the total emails in descending order. Sort users with the same number of emails in alphabetical order. In your rankings, return a unique value (i.e., a unique rank) even if multiple users have the same number of emails.
<br><br>
```
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

-- Use ROW_NUMBER to provide unique rank figure, dependent on ORDER BY clause in OVER clause

SELECT *, 
ROW_NUMBER() OVER(ORDER BY email_count DESC, user ASC) AS ranking
FROM total_emails
```
<br><br>

#### Python

Assignment 1:<br><br>
Write a query that calculates the difference between the highest salaries found in the marketing and engineering departments. Output just the absolute difference in salaries.
<br><br>
```
import pandas as pd

salary_diff = 0

df = pd.merge(db_employee, db_dept, how='inner', left_on='department_id', right_on='id')

marketing_max_salary = df[df['department']=='marketing']['salary'].max()
engineering_max_salary = df[df['department']=='engineering']['salary'].max()

salary_diff = abs(marketing_max_salary - engineering_max_salary)

print(salary_diff)
```
<br><br>

---

### My Favorite Day-to-Day Python for DevOps 🐍

Problem: There are a large amount of folders with DAT files that need to be compiled in a list and passed to a proprietary parser
<br>
Solution: Use the below to generate the list of DAT files and display the final count
```
import glob

targetPattern = r"C:\MAIN\001\Data Sets\*.dat"
paths = glob.glob(targetPattern) 

print(paths)
print(len(paths))
```
<br>
Problem: File paths have been sourced from the DB but you need to check their validity
<br>
Solution: Use the below to print a list of file paths that are incorrect/do not exist

```
import os.path
from os import path

list = [a, b, c]

print("\nPaths that do not exist:\n")
for i in list:
    if str(path.exists(i)) == "False":
        print(i)
```
<br><br>

---
### Geospatial Data and PostGIS 🌐

Not only does the below transform the geometry of 2 long/lat points, then calculate the distance to to a given boundary line, but Postgres' nifty ILIKE slips in a casual case-insensitive pattern matching...sometimes it's the little things that make it all the better.

```
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
```

