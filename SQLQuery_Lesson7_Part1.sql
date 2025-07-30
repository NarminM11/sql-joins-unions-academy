-- Teachers table
CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);
INSERT INTO Teachers (Name, Surname) VALUES
('Edward', 'Hopper'),      
('Alex', 'Carmack'),       
('Linda', 'Smith'),        
('John', 'Brown'), 
('Anna', 'Taylor'),        
('Diana', 'Miller');   
select * from Teachers;    
-------------------------------------------------------------
-- Assistants
CREATE TABLE Assistants (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);
INSERT INTO Assistants (TeacherId) VALUES
(3), 
(4),
(5);
-------------------------------------------------------------
-- Curators
CREATE TABLE Curators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);
INSERT INTO Curators (TeacherId) VALUES
(1);
-------------------------------------------------------------
-- Deans
CREATE TABLE Deans (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);
INSERT INTO Deans (TeacherId) VALUES
(2);
select * from Deans;
-------------------------------------------------------------
-- Heads
CREATE TABLE Heads (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);
INSERT INTO Heads (TeacherId) VALUES
(6);
-------------------------------------------------------------
-- Faculties
CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    DeanId INT NOT NULL FOREIGN KEY REFERENCES Deans(Id)
);
INSERT INTO Faculties (Building, Name, DeanId) VALUES
(2, 'Engineering', 1);
-------------------------------------------------------------
-- Departments
CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    FacultyId INT NOT NULL FOREIGN KEY REFERENCES Faculties(Id),
    HeadId INT NOT NULL FOREIGN KEY REFERENCES Heads(Id)
);
INSERT INTO Departments (Building, Name, FacultyId, HeadId) VALUES
(4, 'Computer Engineering', 1, 1);
-------------------------------------------------------------
-- Groups
CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);
INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('F505', 5, 1);
-------------------------------------------------------------
-- GroupsCurators
CREATE TABLE GroupsCurators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CuratorId INT NOT NULL FOREIGN KEY REFERENCES Curators(Id),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id)
);
INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES (1, 1);

-------------------------------------------------------------
-- Subjects
CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
INSERT INTO Subjects (Name) VALUES
('Databases'),
('Algorithms'),
('Machine Learning');
-------------------------------------------------------------
-- LectureRooms
CREATE TABLE LectureRooms (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> '')
);
INSERT INTO LectureRooms (Building, Name) VALUES
(5, 'A311'), 
(4, 'A104'), 
(3, 'B101'); 
select * from LectureRooms
-------------------------------------------------------------
-- Lectures
CREATE TABLE Lectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);
INSERT INTO Lectures (SubjectId, TeacherId) VALUES
(1, 1), 
(2, 2), 
(3, 3); 
select * from Lectures

-------------------------------------------------------------
-- GroupsLectures
CREATE TABLE GroupsLectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id)
);
INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1);

-------------------------------------------------------------
-- Schedules
CREATE TABLE Schedules (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Class INT NOT NULL CHECK (Class BETWEEN 1 AND 8),
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    Week INT NOT NULL CHECK (Week BETWEEN 1 AND 52),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id),
    LectureRoomId INT NOT NULL FOREIGN KEY REFERENCES LectureRooms(Id)
);
INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId)
VALUES (1, 1, 1, 1, 2),
(2, 2, 1, 2, 3),
(3, 4, 1, 3, 4);

-------------------------------------------------------------------------
----------------------------QUERIES--------------------------------------
-- 1. Print names of the classrooms where the teacher "Edward Hopper" lectures.
select lr.NAME
from Teachers tr
JOIN Lectures lc ON tr.Id = lc.TeacherId
JOIN Schedules sc ON lc.Id = sc.LectureId
JOIN LectureRooms lr ON sc.LectureRoomId = lr.Id
WHERE tr.Name = 'Edward' AND tr.Surname = 'Hopper';
-------------------------------------------------------------------------
-- 2. Print names of the assistants who deliver lectures for the group "F505"
SELECT tr.Name, tr.Surname
FROM Assistants ast
JOIN Teachers tr ON ast.TeacherId = tr.Id
JOIN Lectures lc ON tr.Id = lc.TeacherId
JOIN GroupsLectures gl ON lc.Id = gl.LectureId
JOIN Groups gr ON gl.GroupId = gr.Id
WHERE gr.Name = 'F505';

-------------------------------------------------------------------------
-- 3. Print subjects taught by the teacher "Alex Carmack" for groups 
--of the 5th year.
SELECT sb.Name
FROM Teachers tr
JOIN Lectures lc ON tr.Id = lc.TeacherId
JOIN Subjects sb ON lc.SubjectId = sb.Id
JOIN GroupsLectures gl ON lc.Id = gl.LectureId
JOIN Groups gr ON GL.GroupId = gr.Id
WHERE tr.Name = 'Alex' AND tr.Surname = 'Carmack' AND gr.Year = 5;

-------------------------------------------------------------------------
-- 4. Print names of the teachers who do not deliver lectures on Mondays
SELECT tr.Name, tr.Surname
FROM Teachers tr
WHERE tr.Id NOT IN (
    SELECT DISTINCT lc.TeacherId
    FROM Lectures lc
    JOIN Schedules sh ON lc.Id = sh.LectureId
    WHERE sh.DayOfWeek = 1
);
-------------------------------------------------------------------------
-- 5. Print names of the classrooms, indicating their buildings, in
-- which there are no lectures on Wednesday of the second week
-- on the third double period
SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT sh.LectureRoomId
    FROM Schedules sh
    WHERE sh.DayOfWeek = 3 AND sh.Week = 2 AND sh.Class = 3
);
-------------------------------------------------------------------------
-- 6. Print full names of teachers of the Computer Science faculty,
-- who do not supervise groups of the Software Development de-
-- partment

-------------------------------------------------------------------------
-- 7. Print numbers of all buildings that are available in the tables
-- of faculties, departments, and classrooms
SELECT DISTINCT Building FROM Faculties
UNION
SELECT DISTINCT Building FROM Departments
UNION
SELECT DISTINCT Building FROM LectureRooms;

-------------------------------------------------------------------------
-- 8. Print full names of teachers in the following order: deans of
-- faculties, heads of departments, teachers, curators, assistants

-------------------------------------------------------------------------
-- 9. Print days of the week (without repetitions), in which there are
-- classes in the classrooms "A311" and "A104" of the building 6
SELECT sh.DayOfWeek
FROM Schedules sh
JOIN LectureRooms lr ON sh.LectureRoomId = lr.Id
WHERE lr.Building = 6 AND (lr.Name = 'A311' OR lr.Name = 'A104');
-------------------------------------------------------------------------