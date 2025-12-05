/*
============================================================================================================================
Student Management System 

This script creates database, schema, tables, procedures, views, triggers, functions and to seed 300 sample students

Usage:
 1. Open SSMS and connect to your SQL Server instance.
 2. Open this file (SMS.sql).
 3. Select the entire file and click Execute (or press F5).

============================================================================================================================
*/

-- ---------------------------
-- Safe DB reset header
-- ---------------------------
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET IMPLICIT_TRANSACTIONS OFF;

IF @@TRANCOUNT > 0
    ROLLBACK TRAN;
GO

USE master;
GO

DECLARE @dbname SYSNAME = N'StudentManagementDB';
DECLARE @killlist NVARCHAR(MAX) = N'';

SELECT @killlist = @killlist + 'KILL ' + CONVERT(varchar(10), session_id) + ';'
FROM sys.dm_exec_sessions s
WHERE s.database_id = DB_ID(@dbname)
  AND s.session_id <> @@SPID;

IF LEN(@killlist) > 0
BEGIN
    PRINT 'Killing sessions connected to ' + @dbname + '...';
    EXEC sp_executesql @killlist;
    WAITFOR DELAY '00:00:01';
END
ELSE
    PRINT 'No other sessions found for ' + @dbname + '.';

IF DB_ID(@dbname) IS NOT NULL
BEGIN
    PRINT 'Setting SINGLE_USER and dropping database...';
    ALTER DATABASE StudentManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE StudentManagementDB;
    PRINT 'Dropped StudentManagementDB';
END
ELSE
    PRINT 'StudentManagementDB does not exist — creating new one.';
GO

CREATE DATABASE StudentManagementDB;
PRINT 'Database StudentManagementDB created.';
GO

USE StudentManagementDB;
GO

-- ---------------------------
-- Create schema and tables
-- ---------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'acad')
    EXEC('CREATE SCHEMA acad');
GO

-- Drop objects if exist (safe for reruns)
IF OBJECT_ID('acad.ChangeLog') IS NOT NULL DROP TABLE acad.ChangeLog;
IF OBJECT_ID('acad.Attendance') IS NOT NULL DROP TABLE acad.Attendance;
IF OBJECT_ID('acad.Enrollments') IS NOT NULL DROP TABLE acad.Enrollments;
IF OBJECT_ID('acad.Instructors') IS NOT NULL DROP TABLE acad.Instructors;
IF OBJECT_ID('acad.Students') IS NOT NULL DROP TABLE acad.Students;
IF OBJECT_ID('acad.Courses') IS NOT NULL DROP TABLE acad.Courses;
IF OBJECT_ID('acad.Departments') IS NOT NULL DROP TABLE acad.Departments;
GO

CREATE TABLE acad.Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DeptCode VARCHAR(10) NOT NULL UNIQUE,
    DeptName VARCHAR(100) NOT NULL,
    CreatedOn DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE acad.Courses (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode VARCHAR(20) NOT NULL UNIQUE,
    CourseName VARCHAR(150) NOT NULL,
    DepartmentID INT NOT NULL,
    DurationMonths INT NOT NULL CHECK (DurationMonths > 0),
    CreatedOn DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Courses_Departments FOREIGN KEY (DepartmentID)
        REFERENCES acad.Departments(DepartmentID) ON DELETE NO ACTION
);
GO

CREATE TABLE acad.Students (
    StudentID INT IDENTITY(1000,1) PRIMARY KEY,
    RollNo VARCHAR(20) NOT NULL UNIQUE,
    FirstName VARCHAR(60) NOT NULL,
    LastName VARCHAR(60) NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M','F','O')) NOT NULL DEFAULT 'O',
    Email VARCHAR(150) NULL,
    Mobile VARCHAR(20) NULL,
    Address NVARCHAR(250) NULL,
    City VARCHAR(100) NULL,
    State VARCHAR(100) NULL,
    Country VARCHAR(100) DEFAULT 'India',
    EnrollmentDate DATE DEFAULT CAST(SYSDATETIME() AS DATE),
    IsActive BIT DEFAULT 1,
    CreatedOn DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_Students_Name ON acad.Students(LastName, FirstName);
GO

CREATE TABLE acad.Enrollments (
    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    AcademicYear VARCHAR(9) NOT NULL, -- e.g. 2024-25
    EnrolledOn DATETIME2 DEFAULT SYSUTCDATETIME(),
    Status VARCHAR(20) NOT NULL DEFAULT 'Enrolled', -- Enrolled, Completed, Dropped
    Grade VARCHAR(5) NULL,
    CONSTRAINT UQ_Enroll_Student_Course_Year UNIQUE (StudentID, CourseID, AcademicYear),
    CONSTRAINT FK_Enroll_Student FOREIGN KEY (StudentID) REFERENCES acad.Students(StudentID) ON DELETE CASCADE,
    CONSTRAINT FK_Enroll_Course FOREIGN KEY (CourseID) REFERENCES acad.Courses(CourseID) ON DELETE NO ACTION
);
GO

CREATE TABLE acad.Instructors (
    InstructorID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(150) NOT NULL,
    Email VARCHAR(150) NULL,
    Mobile VARCHAR(20) NULL,
    DepartmentID INT NULL,
    CreatedOn DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Instructors_Department FOREIGN KEY (DepartmentID) REFERENCES acad.Departments(DepartmentID)
);
GO

CREATE TABLE acad.Attendance (
    AttendanceID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status CHAR(1) CHECK (Status IN ('P','A','L')) NOT NULL, -- P=Present, A=Absent, L=Leave
    Remarks VARCHAR(200) NULL,
    CONSTRAINT FK_Att_Student FOREIGN KEY (StudentID) REFERENCES acad.Students(StudentID) ON DELETE CASCADE,
    CONSTRAINT FK_Att_Course FOREIGN KEY (CourseID) REFERENCES acad.Courses(CourseID) ON DELETE CASCADE
);
GO

CREATE TABLE acad.ChangeLog (
    ChangeID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TableName SYSNAME NOT NULL,
    KeyValue NVARCHAR(200) NOT NULL,
    ActionType VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    ChangedBy SYSNAME NULL,
    ChangedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    Details NVARCHAR(MAX) NULL
);
GO

-- ---------------------------
-- Seed Departments & Courses
-- ---------------------------

PRINT 'Seeding Departments and Courses...';
BEGIN TRAN;
BEGIN TRY
    DELETE FROM acad.Attendance;
    DELETE FROM acad.Enrollments;
    DELETE FROM acad.ChangeLog;
    DELETE FROM acad.Instructors;
    DELETE FROM acad.Courses;
    DELETE FROM acad.Departments;

    INSERT INTO acad.Departments (DeptCode, DeptName)
    VALUES
      ('CSE','Computer Science & Engineering'),
      ('ECE','Electronics & Communication'),
      ('ME','Mechanical Engineering'),
      ('IT','Information Technology'),
      ('MBA','Master of Business Administration');

    INSERT INTO acad.Courses (CourseCode, CourseName, DepartmentID, DurationMonths)
    VALUES
      ('BTECH-CSE','B.Tech - Computer Science', (SELECT DepartmentID FROM acad.Departments WHERE DeptCode='CSE'), 48),
      ('BTECH-ECE','B.Tech - Electronics & Comm', (SELECT DepartmentID FROM acad.Departments WHERE DeptCode='ECE'), 48),
      ('BTECH-ME','B.Tech - Mechanical', (SELECT DepartmentID FROM acad.Departments WHERE DeptCode='ME'), 48),
      ('BCA-IT','BCA - Information Technology', (SELECT DepartmentID FROM acad.Departments WHERE DeptCode='IT'), 36),
      ('MBA-FS','MBA - Finance', (SELECT DepartmentID FROM acad.Departments WHERE DeptCode='MBA'), 24),
      ('MBA-HR','MBA - HR', (SELECT DepartmentID FROM acad.Departments WHERE DeptCode='MBA'), 24);

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    THROW;
END CATCH;
GO

-- ---------------------------
-- Stored Procedures
-- ---------------------------

-- 1. Create Stored Procedure spAddStudent

IF OBJECT_ID('acad.spAddStudent') IS NOT NULL DROP PROCEDURE acad.spAddStudent;
GO
CREATE PROCEDURE acad.spAddStudent
    @RollNo VARCHAR(20),
    @FirstName VARCHAR(60),
    @LastName VARCHAR(60) = NULL,
    @DOB DATE,
    @Gender CHAR(1) = 'O',
    @Email VARCHAR(150) = NULL,
    @Mobile VARCHAR(20) = NULL,
    @City VARCHAR(100) = NULL,
    @State VARCHAR(100) = NULL,
    @Country VARCHAR(100) = 'India',
    @NewStudentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO acad.Students (RollNo, FirstName, LastName, DateOfBirth, Gender, Email, Mobile, City, State, Country)
        VALUES (@RollNo, @FirstName, @LastName, @DOB, @Gender, @Email, @Mobile, @City, @State, @Country);

        SET @NewStudentID = SCOPE_IDENTITY();

        INSERT INTO acad.ChangeLog (TableName, KeyValue, ActionType, ChangedBy, Details)
        VALUES ('acad.Students', CAST(@NewStudentID AS NVARCHAR(50)), 'INSERT', SYSTEM_USER, CONCAT('Added student ', @FirstName, ' ', ISNULL(@LastName,'')));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- 2. Create Stored Procedure spEnrollStudent

IF OBJECT_ID('acad.spEnrollStudent') IS NOT NULL DROP PROCEDURE acad.spEnrollStudent;
GO
CREATE PROCEDURE acad.spEnrollStudent
    @StudentID INT,
    @CourseID INT,
    @AcademicYear VARCHAR(9) -- e.g. '2024-25'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM acad.Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 51000, 'Student not found or inactive.', 1;

        IF NOT EXISTS (SELECT 1 FROM acad.Courses WHERE CourseID = @CourseID)
            THROW 51001, 'Course not found.', 1;

        INSERT INTO acad.Enrollments (StudentID, CourseID, AcademicYear)
        VALUES (@StudentID, @CourseID, @AcademicYear);

        INSERT INTO acad.ChangeLog (TableName, KeyValue, ActionType, ChangedBy, Details)
        VALUES ('acad.Enrollments', CONCAT(@StudentID, '|', @CourseID, '|', @AcademicYear), 'INSERT', SYSTEM_USER, 'Enrollment created.');

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        IF ERROR_NUMBER() = 2627 -- unique violation
            THROW 51002, 'Student already enrolled for this course & year.', 1;
        ELSE
            THROW;
    END CATCH
END;
GO

-- 3. Create Stored Procedure spUpdateStudent

IF OBJECT_ID('acad.spUpdateStudent') IS NOT NULL DROP PROCEDURE acad.spUpdateStudent;
GO
CREATE PROCEDURE acad.spUpdateStudent
    @StudentID INT,
    @FirstName VARCHAR(60) = NULL,
    @LastName VARCHAR(60) = NULL,
    @Email VARCHAR(150) = NULL,
    @Mobile VARCHAR(20) = NULL,
    @City VARCHAR(100) = NULL,
    @State VARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM acad.Students WHERE StudentID = @StudentID)
            THROW 52000, 'Student not found.', 1;

        UPDATE acad.Students
        SET
            FirstName = COALESCE(@FirstName, FirstName),
            LastName = COALESCE(@LastName, LastName),
            Email = COALESCE(@Email, Email),
            Mobile = COALESCE(@Mobile, Mobile),
            City = COALESCE(@City, City),
            State = COALESCE(@State, State),
            IsActive = COALESCE(@IsActive, IsActive),
            CreatedOn = CreatedOn -- no change, placeholder
        WHERE StudentID = @StudentID;

        INSERT INTO acad.ChangeLog (TableName, KeyValue, ActionType, ChangedBy, Details)
        VALUES ('acad.Students', CAST(@StudentID AS NVARCHAR(50)), 'UPDATE', SYSTEM_USER, CONCAT('Updated student ', @StudentID));

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- Create function fnCalculateAge

IF OBJECT_ID('acad.fnCalculateAge', 'FN') IS NOT NULL
    DROP FUNCTION acad.fnCalculateAge;
GO
CREATE FUNCTION acad.fnCalculateAge(@dob DATE)
RETURNS INT
AS
BEGIN
    DECLARE @age INT;
    IF @dob IS NULL
        RETURN NULL;
    SELECT @age = DATEDIFF(YEAR, @dob, GETDATE()) - CASE WHEN (MONTH(@dob) > MONTH(GETDATE())) OR (MONTH(@dob) = MONTH(GETDATE()) AND DAY(@dob) > DAY(GETDATE())) THEN 1 ELSE 0 END;
    RETURN @age;
END;
GO

-- Create Trigger trg_Students_Audit

IF OBJECT_ID('acad.trg_Students_Audit', 'TR') IS NOT NULL
    DROP TRIGGER acad.trg_Students_Audit;
GO
CREATE TRIGGER acad.trg_Students_Audit
ON acad.Students
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- For inserted rows: log INSERTS
    INSERT INTO acad.ChangeLog (TableName, KeyValue, ActionType, ChangedBy, Details)
    SELECT 'acad.Students', CAST(i.StudentID AS NVARCHAR(50)),
           CASE WHEN u.StudentID IS NULL THEN 'INSERT' ELSE 'UPDATE' END,
           SYSTEM_USER,
           CONCAT('Student ', CAST(i.StudentID AS NVARCHAR(50)), ' - ', LEFT(ISNULL(i.FirstName,''),50), ' ', LEFT(ISNULL(i.LastName,''),50))
    FROM inserted i
    LEFT JOIN deleted d ON i.StudentID = d.StudentID
    LEFT JOIN inserted u ON i.StudentID = u.StudentID; -- aliasing for clarity

    -- Optionally, you can capture more details (before/after) by joining deleted and inserted
END;
GO

-- Create View vwStudentEnrollments

IF OBJECT_ID('acad.vwStudentEnrollments') IS NOT NULL DROP VIEW acad.vwStudentEnrollments;
GO
CREATE VIEW acad.vwStudentEnrollments
AS
SELECT
    s.StudentID,
    s.RollNo,
    CONCAT(s.FirstName, ' ', ISNULL(s.LastName, '')) AS StudentName,
    s.Email,
    s.Mobile,
    c.CourseCode,
    c.CourseName,
    d.DeptName,
    e.AcademicYear,
    e.Status,
    e.EnrolledOn
FROM acad.Enrollments e
JOIN acad.Students s ON s.StudentID = e.StudentID
JOIN acad.Courses c ON c.CourseID = e.CourseID
JOIN acad.Departments d ON d.DepartmentID = c.DepartmentID;
GO

-- ---------------------------
-- Seed sample students (300) and enrollments
-- ---------------------------

PRINT 'Generating sample students and enrollments...';
BEGIN TRY
    -- Perform safe deletes without wrapping in a single large transaction to avoid uncommittable states
    DELETE FROM acad.Attendance;
    DELETE FROM acad.Enrollments;
    DELETE FROM acad.Students;

    DECLARE @i INT = 1;
    DECLARE @max INT = 300;
    DECLARE @fn NVARCHAR(60), @ln NVARCHAR(60), @roll VARCHAR(20), @dob DATE, @gender CHAR(1), @city VARCHAR(50);
    DECLARE @email VARCHAR(150), @mobile VARCHAR(20);
    DECLARE @courseCount INT = (SELECT COUNT(*) FROM acad.Courses);
    DECLARE @courseID INT;
    DECLARE @studentID INT;
    DECLARE @year VARCHAR(9);

    WHILE @i <= @max
    BEGIN
        SET @fn = CONCAT('Student', RIGHT('000' + CAST(@i AS VARCHAR(3)),3));
        SET @ln = CONCAT('LN', RIGHT('000' + CAST(((@i % 50) + 1) AS VARCHAR(3)),3));
        SET @roll = CONCAT('R', FORMAT(@i,'0000'));
        SET @dob = DATEADD(DAY, - (365 * (18 + (@i % 5)) + (@i % 365)), CAST(GETDATE() AS DATE)); -- ages 18-22 approx
        SET @gender = CASE WHEN @i % 3 = 0 THEN 'F' WHEN @i % 3 = 1 THEN 'M' ELSE 'O' END;
        SET @city = CASE WHEN @i % 4 = 0 THEN 'Hyderabad' WHEN @i % 4 = 1 THEN 'Vijayawada' WHEN @i % 4 = 2 THEN 'Visakhapatnam' ELSE 'Warangal' END;
        SET @email = LOWER(CONCAT(@fn, '.', @i, '@example.edu'));
        SET @mobile = CONCAT('9', RIGHT('000000000' + CAST(700000000 + @i AS VARCHAR(9)),9));

        -- Insert student (each insert is its own transaction)
        INSERT INTO acad.Students (RollNo, FirstName, LastName, DateOfBirth, Gender, Email, Mobile, City, State, Country)
        VALUES (@roll, @fn, @ln, @dob, @gender, @email, @mobile, @city, 'Telangana', 'India');

        SET @studentID = SCOPE_IDENTITY();

        -- Enrollments: attempt inserts, ignore duplicates
        DECLARE @numEnroll INT = (ABS(CHECKSUM(NEWID())) % 2) + 1;
        DECLARE @j INT = 1;
        WHILE @j <= @numEnroll
        BEGIN
            SET @courseID = (ABS(CHECKSUM(NEWID())) % @courseCount) + 1;
            SET @year = CASE WHEN @i % 2 = 0 THEN '2024-25' ELSE '2025-26' END;
            BEGIN TRY
                INSERT INTO acad.Enrollments (StudentID, CourseID, AcademicYear, Status)
                VALUES (@studentID, @courseID, @year, 'Enrolled');
            END TRY
            BEGIN CATCH
                -- ignore duplicate enrollment attempts or harmless errors per student
            END CATCH;
            SET @j = @j + 1;
        END

        SET @i = @i + 1;
    END

    -- Optional: create some attendance data for a sample set
    INSERT INTO acad.Attendance (StudentID, CourseID, AttendanceDate, Status, Remarks)
    SELECT TOP(200) e.StudentID, e.CourseID, CAST(DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 30), GETDATE()) AS DATE), CASE WHEN ABS(CHECKSUM(NEWID())) % 10 < 8 THEN 'P' ELSE 'A' END, NULL
    FROM acad.Enrollments e
    ORDER BY NEWID();

    PRINT '300 students and sample enrollments created successfully.';
END TRY
BEGIN CATCH
    -- If any error happens, output useful info and rethrow
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrNum INT = ERROR_NUMBER();
    PRINT 'Error during sample generation: ' + COALESCE(@ErrMsg, N'');
    THROW;
END CATCH;
GO

PRINT 'Script execution completed. Run the example queries to verify data.';
GO
