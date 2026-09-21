-- University Course Management System (MySQL 8.0+)

DROP DATABASE IF EXISTS UniversityDB;
CREATE DATABASE UniversityDB;
USE UniversityDB;

-- Tables

CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Students (
    StudentID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    BirthDate DATE NOT NULL,
    EnrollmentDate DATE NOT NULL
);

CREATE TABLE Instructors (
    InstructorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    Salary DECIMAL(10,2),  -- needed for Query 8
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Courses (
    CourseID INT AUTO_INCREMENT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    Credits INT NOT NULL CHECK (Credits > 0),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Enrollments (
    EnrollmentID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE,
    UNIQUE (StudentID, CourseID)
);

-- Sample data

INSERT INTO Departments VALUES
(1, 'Computer Science'),
(2, 'Mathematics');

INSERT INTO Students VALUES
(1, 'John', 'Doe', 'john.doe@email.com', '2000-01-15', '2022-08-01'),
(2, 'Jane', 'Smith', 'jane.smith@email.com', '1999-05-25', '2021-08-01');

INSERT INTO Instructors VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@univ.com', 1, 85000.00),
(2, 'Bob', 'Lee', 'bob.lee@univ.com', 2, 78000.00);

INSERT INTO Courses VALUES
(101, 'Introduction to SQL', 1, 3),
(102, 'Data Structures', 2, 4);

INSERT INTO Enrollments VALUES
(1, 1, 101, '2022-08-01'),
(2, 2, 102, '2021-08-01');


-- Query 1: CRUD operations

-- create
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES (3, 'Physics');

INSERT INTO Students (StudentID, FirstName, LastName, Email, BirthDate, EnrollmentDate)
VALUES (99, 'Test', 'Student', 'test.student@email.com', '2001-04-12', '2023-08-20');

INSERT INTO Instructors (InstructorID, FirstName, LastName, Email, DepartmentID, Salary)
VALUES (99, 'Carol', 'White', 'carol.white@univ.com', 3, 72000.00);

INSERT INTO Courses (CourseID, CourseName, DepartmentID, Credits)
VALUES (999, 'Database Systems', 1, 3);

INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, EnrollmentDate)
VALUES (99, 99, 999, '2023-08-20');

-- read
SELECT * FROM Departments;
SELECT * FROM Students;
SELECT * FROM Instructors;
SELECT * FROM Courses;
SELECT * FROM Enrollments;

-- update
UPDATE Departments SET DepartmentName = 'Applied Physics' WHERE DepartmentID = 3;
UPDATE Students SET Email = 'test.student@university.edu' WHERE StudentID = 99;
UPDATE Instructors SET Salary = 75000.00 WHERE InstructorID = 99;
UPDATE Courses SET Credits = 4 WHERE CourseID = 999;
UPDATE Enrollments SET EnrollmentDate = '2023-08-25' WHERE EnrollmentID = 99;

-- delete (child tables first)
DELETE FROM Enrollments WHERE EnrollmentID = 99;
DELETE FROM Courses WHERE CourseID = 999;
DELETE FROM Instructors WHERE InstructorID = 99;
DELETE FROM Students WHERE StudentID = 99;
DELETE FROM Departments WHERE DepartmentID = 3;


-- Query 2: students who enrolled after 2022
SELECT * FROM Students
WHERE EnrollmentDate > '2022-12-31';

-- Query 3: courses offered by Mathematics department (limit 5)
SELECT c.CourseID, c.CourseName, c.Credits
FROM Courses c
JOIN Departments d ON c.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Mathematics'
LIMIT 5;

-- Query 4: students per course, only courses with more than 5 students
SELECT c.CourseID, c.CourseName, COUNT(e.StudentID) AS StudentCount
FROM Courses c
JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
HAVING COUNT(e.StudentID) > 5;

-- Query 5: students enrolled in both Introduction to SQL and Data Structures
SELECT s.StudentID, s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName IN ('Introduction to SQL', 'Data Structures')
GROUP BY s.StudentID, s.FirstName, s.LastName
HAVING COUNT(DISTINCT c.CourseID) = 2;

-- Query 6: students enrolled in either of the two courses
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName, c.CourseName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName IN ('Introduction to SQL', 'Data Structures');

-- Query 7: average credits of all courses
SELECT AVG(Credits) AS AvgCredits FROM Courses;

-- Query 8: max salary of instructors in Computer Science
SELECT MAX(i.Salary) AS MaxSalary
FROM Instructors i
JOIN Departments d ON i.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Computer Science';

-- Query 9: number of students enrolled in each department
SELECT d.DepartmentName, COUNT(DISTINCT e.StudentID) AS StudentCount
FROM Departments d
LEFT JOIN Courses c ON d.DepartmentID = c.DepartmentID
LEFT JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY d.DepartmentID, d.DepartmentName;

-- Query 10: INNER JOIN - students and their courses
SELECT s.StudentID, s.FirstName, s.LastName, c.CourseID, c.CourseName
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN Courses c ON e.CourseID = c.CourseID;

-- Query 11: LEFT JOIN - all students and their courses, if any
SELECT s.StudentID, s.FirstName, s.LastName, c.CourseID, c.CourseName
FROM Students s
LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
LEFT JOIN Courses c ON e.CourseID = c.CourseID;

-- Query 12: subquery - students in courses that have more than 10 students
SELECT StudentID, FirstName, LastName
FROM Students
WHERE StudentID IN (
    SELECT StudentID FROM Enrollments
    WHERE CourseID IN (
        SELECT CourseID FROM Enrollments
        GROUP BY CourseID
        HAVING COUNT(*) > 10
    )
);

-- Query 13: year from EnrollmentDate
SELECT StudentID, FirstName, LastName, YEAR(EnrollmentDate) AS EnrollmentYear
FROM Students;

-- Query 14: instructor full name
SELECT InstructorID, CONCAT(FirstName, ' ', LastName) AS InstructorName
FROM Instructors;

-- Query 15: running total of students enrolled in courses
SELECT EnrollmentDate,
       COUNT(*) AS StudentsEnrolled,
       SUM(COUNT(*)) OVER (ORDER BY EnrollmentDate) AS RunningTotal
FROM Enrollments
GROUP BY EnrollmentDate;

-- Query 16: label students as Senior or Junior
SELECT StudentID, FirstName, LastName, EnrollmentDate,
       CASE
           WHEN EnrollmentDate < DATE_SUB(CURDATE(), INTERVAL 4 YEAR) THEN 'Senior'
           ELSE 'Junior'
       END AS StudentLevel
FROM Students;