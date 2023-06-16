SELECT * FROM GPA

--Create Grade_Point
ALTER TABLE GPA
ADD Grade_Point DECIMAL (4,2)

UPDATE GPA 
SET Grade_Point = CASE
	WHEN Credit_Hours = 3 THEN 
	CASE
	WHEN TotalMarks >=85 THEN 4.00
	WHEN TotalMarks >=75 THEN 3.75
	WHEN TotalMarks >=66 THEN 3.50
	WHEN TotalMarks >=60 THEN 3.00
	WHEN TotalMarks >=55 THEN 2.50
	WHEN TotalMarks >=50 THEN 2.00
	ELSE 0.00
	END
	WHEN Credit_Hours = 2 THEN 
	CASE
	WHEN TotalMarks >=42 THEN 4.00
	WHEN TotalMarks >=37 THEN 3.75
	WHEN TotalMarks >=33 THEN 3.50
	WHEN TotalMarks >=30 THEN 3.00
	WHEN TotalMarks >=27 THEN 2.50
	WHEN TotalMarks >=25 THEN 2.00
	ELSE 0.00 
	END
	WHEN Credit_Hours = 1 THEN
	CASE
	WHEN TotalMarks >=42 THEN 4.00
	WHEN TotalMarks >=37 THEN 3.75
	WHEN TotalMarks >=33 THEN 3.50
	WHEN TotalMarks >=30 THEN 3.00
	WHEN TotalMarks >=27 THEN 2.50
	WHEN TotalMarks >=25 THEN 2.00
	ELSE 0.00 
	END
	ELSE 0.00
END

--Create Grade
ALTER TABLE GPA
ADD Grade VARCHAR(50)

UPDATE GPA
SET Grade = Case
	WHEN Grade_Point = 4.00 THEN 'A+'
	WHEN Grade_Point = 3.75 THEN 'A'
	WHEN Grade_Point = 3.50 THEN 'B+'
	WHEN Grade_Point = 3.00 THEN 'B'
	WHEN Grade_Point = 2.50 THEN 'C+'
	WHEN Grade_Point = 2.00 THEN 'C'
	ELSE 'F'
	END

--Create Percentage
ALTER TABLE GPA
ADD Percentage DECIMAL(5,2)
UPDATE GPA
SET Percentage = ((TotalMarks * 100)/Total_Marks)

--Create Quality Point
ALTER TABLE GPA
ADD QP DECIMAL(4,2)
UPDATE GPA
SET QP = (Grade_Point * Credit_Hours)

--Create Relative_Grade, Relative_Grade_Point, Relative_QP

ALTER TABLE GPA
ADD Relative_Grade VARCHAR(50), Relative_Grade_Point DECIMAL(4,2), Relative_QP DECIMAL(4,2);
GO
UPDATE GPA
SET Relative_Grade =
    CASE
        WHEN Percentage >= Mean + (1 * Std_Value) THEN 'A+'
        WHEN Percentage >= Mean + (0.666 * Std_Value) THEN 'A'
        WHEN Percentage >= Mean + (0.333 * Std_Value) THEN 'B+'
        WHEN Percentage >= Mean THEN 'B'
        WHEN Percentage >= Mean - (0.333 * Std_Value) THEN 'C+'
        WHEN Percentage >= Mean - (0.666 * Std_Value) THEN 'C'
        ELSE 'F'
    END,
    Relative_Grade_Point =
    CASE
        WHEN Percentage >= Mean + (1 * Std_Value) THEN 4.00
        WHEN Percentage >= Mean + (0.666 * Std_Value) THEN 3.75
        WHEN Percentage >= Mean + (0.333 * Std_Value) THEN 3.50
        WHEN Percentage >= Mean THEN 3.00
        WHEN Percentage >= Mean - (0.333 * Std_Value) THEN 2.50
        WHEN Percentage >= Mean - (0.666 * Std_Value) THEN 2.00
        ELSE 0.00
    END,
    Relative_QP =
    (CASE
        WHEN Percentage >= Mean + (1 * Std_Value) THEN 4.00
        WHEN Percentage >= Mean + (0.666 * Std_Value) THEN 3.75
        WHEN Percentage >= Mean + (0.333 * Std_Value) THEN 3.50
        WHEN Percentage >= Mean THEN 3.00
        WHEN Percentage >= Mean - (0.333* Std_Value) THEN 2.50
        WHEN Percentage >= Mean - (0.666 * Std_Value) THEN 2.00
        ELSE 0.00
    END * Credit_Hours)
FROM GPA,
    (SELECT AVG(Percentage) AS Mean, STDEV(Percentage) AS Std_Value FROM GPA) AS Stats;

--GPA_Average for Absolute grading
SELECT SeatRollNo, (SUM(QP) / SUM(Credit_Hours)) AS Absolute_CGPA
FROM GPA
GROUP BY SeatRollNo
ORDER BY Absolute_CGPA DESC;

--GPA_Average for Reltive grading
SELECT SeatRollNo, SUM(Relative_QP) / SUM(Credit_Hours) AS Relative_CGPA
FROM GPA
GROUP BY SeatRollNo
ORDER BY Relative_CGPA desc;

--Count Grades of each subject
SELECT CourseTitle, Delivery_Format, Relative_Grade,
       COUNT(*) AS Count_Grade
FROM GPA 
GROUP BY CourseTitle, Delivery_Format,Relative_Grade 

SELECT CourseTitle, Delivery_Format, Grade , 
       COUNT(*) AS Count_Grade
FROM GPA 
GROUP BY CourseTitle, Delivery_Format,Grade,   

--List of students by Relative grade
SELECT CourseTitle, Delivery_Format,
       COUNT(*) AS Total,
       COUNT(*) - COUNT(CASE WHEN Relative_Grade = 'F' THEN 1 END) AS Pass,
       CAST((COUNT(*) - COUNT(CASE WHEN Relative_Grade = 'F' THEN 1 END)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS 'Pass%',
       COUNT(CASE WHEN Relative_Grade = 'A+' THEN 1 END) AS 'A+',
       CAST((COUNT(CASE WHEN Relative_Grade = 'A+' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'A+%',
       COUNT(CASE WHEN Relative_Grade = 'A' THEN 1 END) AS 'A',
       CAST((COUNT(CASE WHEN Relative_Grade = 'A' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'A%',
       COUNT(CASE WHEN Relative_Grade = 'B+' THEN 1 END) AS 'B+',
       CAST((COUNT(CASE WHEN Relative_Grade = 'B+' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'B+%',
       COUNT(CASE WHEN Relative_Grade = 'B' THEN 1 END) AS 'B',
       CAST((COUNT(CASE WHEN Relative_Grade = 'B' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'B%',
       COUNT(CASE WHEN Relative_Grade = 'C+' THEN 1 END) AS 'C+',
       CAST((COUNT(CASE WHEN Relative_Grade = 'C+' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'C+%',
       COUNT(CASE WHEN Relative_Grade = 'C' THEN 1 END) AS 'C',
       CAST((COUNT(CASE WHEN Relative_Grade = 'C' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'C%',
       COUNT(CASE WHEN Relative_Grade = 'F' THEN 1 END) AS 'F'
FROM GPA
GROUP BY CourseTitle, Delivery_Format;


--List of students by Absolute grade
SELECT CourseTitle, Delivery_Format,
       COUNT(*) AS Total,
       COUNT(*) - COUNT(CASE WHEN Grade = 'F' THEN 1 END) AS Pass,
       CAST((COUNT(*) - COUNT(CASE WHEN Grade = 'F' THEN 1 END)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS 'Pass%',
       COUNT(CASE WHEN Grade = 'A+' THEN 1 END) AS 'A+',
       CAST((COUNT(CASE WHEN Grade = 'A+' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'A+%',
       COUNT(CASE WHEN Grade = 'A' THEN 1 END) AS 'A',
       CAST((COUNT(CASE WHEN Grade = 'A' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'A%',
       COUNT(CASE WHEN Grade = 'B+' THEN 1 END) AS 'B+',
       CAST((COUNT(CASE WHEN Grade = 'B+' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'B+%',
       COUNT(CASE WHEN Grade = 'B' THEN 1 END) AS 'B',
       CAST((COUNT(CASE WHEN Grade = 'B' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'B%',
       COUNT(CASE WHEN Grade = 'C+' THEN 1 END) AS 'C+',
       CAST((COUNT(CASE WHEN Grade = 'C+' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'C+%',
       COUNT(CASE WHEN Grade = 'C' THEN 1 END) AS 'C',
       CAST((COUNT(CASE WHEN Grade = 'C' THEN 1 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS 'C%',
       COUNT(CASE WHEN Grade = 'F' THEN 1 END) AS 'F'
FROM GPA
GROUP BY CourseTitle, Delivery_Format;

