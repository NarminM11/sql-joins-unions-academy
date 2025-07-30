CREATE TABLE Posts (
    Id INT PRIMARY KEY,            
    Name NVARCHAR(20) NOT NULL     
);
--------------------------------------------
CREATE TABLE Teachers (
    Id INT PRIMARY KEY,                     
    Name NVARCHAR(15) NOT NULL,             
    Code CHAR(10) NOT NULL,                 
    IdPost INT NOT NULL,                    
    Tel CHAR(7) NOT NULL,                   
    Salary INT NOT NULL,                    
    Rise NUMERIC(6,2) NOT NULL,             
    HireDate DATETIME NOT NULL,             
    CONSTRAINT FK_Teachers_Posts FOREIGN KEY (IdPost) REFERENCES Posts(Id)
);
--------------------------------------------
--2. Delete the "POSTS" table
ALTER TABLE Teachers
DROP CONSTRAINT FK_Teachers_Posts;

DROP table posts
--------------------------------------------
--3. In the "TEACHERS" table, delete the "IdPost" column
ALTER TABLE Teachers
DROP COLUMN IdPost;
--------------------------------------------
--4. For the "HireDate" column, create a limit: the date of hiring must be at least 01/01/1990
ALTER TABLE Teachers
ADD CONSTRAINT CK_HireDate CHECK (HireDate >= '1990-01-01');
--------------------------------------------
-- 5. Create a unique constraint for the "Code" column
ALTER TABLE Teachers
ADD CONSTRAINT UQ_Teachers_Code UNIQUE (Code);
--------------------------------------------
-- 6. Change the data type In the Salary field from INTEGER to NUMERIC (6,2)
ALTER TABLE Teachers
ALTER COLUMN Salary NUMERIC(6,2);
--------------------------------------------
-- 7. Add to the table "TEACHERS" the following restriction: the salary should not be less than
-- 1000, but also should not Exceed 5000
ALTER TABLE Teachers
ADD CONSTRAINT CK_SalaryRange CHECK (Salary BETWEEN 1000 AND 5000);
--------------------------------------------
-- 8. Rename Tel column to Phone
EXEC sp_rename 'Teachers.Tel', 'Phone', 'COLUMN';
--------------------------------------------
-- 9. Change the data type in the Phone field from CHAR (7) to CHAR (11)
ALTER TABLE Teachers
ALTER COLUMN Phone CHAR(11);
--------------------------------------------
-- 10. Create again the "POSTS" table
CREATE TABLE Posts (
    Id INT PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL
);
--------------------------------------------
-- 11. For the Name field of the "POSTS" table, you must set a limit on the position (professor,
-- assistant professor, teacher or assistant)
ALTER TABLE Posts
ADD CONSTRAINT CK_Posts_Name CHECK (
    Name IN ('professor', 'assistant professor', 'teacher', 'assistant')
);
--------------------------------------------
-- 12. For the Name field of the "TEACHERS" table, specify a restriction in which to prohibit the
-- presence of figures in the teacher's surname

--surname field olmadigi ucun evvelce elave edirik sonra restriction qoyuruq
ALTER TABLE Teachers
ADD Surname NVARCHAR(30);

ALTER TABLE Teachers
ADD CONSTRAINT CK_Teachers_Name_NoDigits CHECK (
    Name NOT LIKE '%[0-9]%'
);
--------------------------------------------
-- 13. Add the IdPost (int) column to the "TEACHERS" table
ALTER TABLE Teachers
ADD IdPost INT;
--------------------------------------------
-- 14. Associate the field IdPost table "TEACHERS" with the field Id of the table "POSTS"
ALTER TABLE Teachers
ADD CONSTRAINT FK_Teachers_Posts FOREIGN KEY (IdPost) REFERENCES Posts(Id);
--------------------------------------------
--15
INSERT INTO posts (Id, Name)
VALUES (1, N'Professor ');
INSERT INTO posts (Id, Name)
VALUES (2, N'Docent ');
INSERT INTO posts (Id, Name)
VALUES (3, N'Teacher');
INSERT INTO posts (Id, Name)
VALUES (4, N'Assistant ');
--------------------------------------------
--15 cont
INSERT INTO Teachers (Id, Name, Surname, Code, IdPost, Phone, Salary, Rise, HireDate)
VALUES (1, N'Sidorov', N'Ivan', '0123456789', 1, '12345678901', 1070, 470, '1992-09-01');

INSERT INTO Teachers (Id, Name, Surname, Code, IdPost, Phone, Salary, Rise, HireDate)
VALUES (2, N'Ramishevsky', N'Oleg', '4567890123', 3, '45678901234', 1110, 370, '1998-09-09');

INSERT INTO Teachers (Id, Name, Surname, Code, IdPost, Phone, Salary, Rise, HireDate)
VALUES (3, N'Horenko', N'Andrey', '1234567890', 3, NULL, 2000, 230, '2001-10-10');

INSERT INTO Teachers (Id, Name, Surname, Code, IdPost, Phone, Salary, Rise, HireDate)
VALUES (4, N'Vibrovsky', N'Dmitriy', '2345678901', 4, NULL, 4000, 170, '2003-09-01');

-- Code NULL verə bilmərik, UNIQUE və NOT NULL constraint var. Unikal və dolu dəyər təyin edək.
INSERT INTO Teachers (Id, Name, Surname, Code, IdPost, Phone, Salary, Rise, HireDate)
VALUES (5, N'Voropaev', N'Nikolay', '3456789012', 4, '33344455566', 1500, 150, '2002-09-02');

INSERT INTO Teachers (Id, Name, Surname, Code, IdPost, Phone, Salary, Rise, HireDate)
VALUES (6, N'Kuzintsev', N'Vladimir', '5678901234', 3, '45678901234', 3000, 270, '1991-01-01');

--------------------------------------------
--16
-- 16.1. All job titles
CREATE VIEW vw_AllJobTitles AS
SELECT Name AS JobTitle
FROM Posts;
--------------------------------------------
-- 16.2. All the names of teachers
CREATE VIEW vw_AllTeacherNames AS
SELECT Name
FROM Teachers;
--------------------------------------------
-- 16.3. The identifier, the name of the teacher, his position, the general s / n (sort by s \ n)
CREATE VIEW vw_TeachersSalaryInfo AS
SELECT 
    tr.Id,
    tr.Name,
    p.Name AS Position,
    tr.Salary
FROM Teachers tr
LEFT JOIN Posts p ON tr.IdPost = p.Id;
--------------------------------------------
-- 16.4. Identification number, surname, telephone number (only those who have a phone number)
CREATE VIEW vw_TeachersWithPhone AS
SELECT 
    Id,
    Surname,
    Phone
FROM Teachers
WHERE Phone IS NOT NULL;
--------------------------------------------
-- 16.5. Surname, position, date of admission in the format [dd/mm/yy]
CREATE VIEW vw_TeachersAdmissionDateShort AS
SELECT
    tr.Surname,
    p.Name AS Position,
    CONVERT(VARCHAR(8), tr.HireDate, 3) AS AdmissionDate 
FROM Teachers tr
LEFT JOIN Posts p ON tr.IdPost = p.Id;
--------------------------------------------
-- 16.6. Surname, position, date of receipt in the format [dd month_text yyyy]
CREATE VIEW vw_TeachersDate AS
SELECT
    tr.Surname,
    p.Name AS Position,
    FORMAT(tr.HireDate, 'dd MMMM yyyy', 'en-US') AS Teachers_Date
FROM Teachers tr
LEFT JOIN Posts p ON tr.IdPost = p.Id;

