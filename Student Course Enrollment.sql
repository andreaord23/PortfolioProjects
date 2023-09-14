/* 
Student Course Enrollment

Demonstrates how to design and create tables, views, and stored procedures

*/

-- Create Tables -- 

CREATE TABLE Courses (
[CourseID] int NOT NULL Identity (1,1)
,[CourseName] nVarchar(100) NOT NULL
,[CourseStartDate] date NULL
,[CourseEndDate] date NULL
,[CourseStartTime] time NULL
,[CourseEndTime] time NULL
,[CourseDaysOfWeek] nVarchar(1) NULL
,[CourseCurrentPrice] money NULL
);

CREATE TABLE Students (
[StudentID] int Identity (101,1) NOT NULL
,[StudentNumber] nvarchar(100) NOT NULL
,[StudentFirstName] nVarchar(100) NOT NULL
,[StudentLastName] nVarchar(100) NOT NULL
,[Email] nVarchar(100) NOT NULL
,[PhoneNumber] nVarchar(12) NULL
,[StreetAddress] nVarchar(100) NULL
,[City] nVarchar(100) NULL
,[State] nVarchar(2) NULL
,[ZipCode] int NULL
);
go

CREATE TABLE CourseEnrollment (
[EnrollmentID] int Identity (10001,1) NOT NULL 
,[StudentID] int NOT NULL
,[CourseID] int NOT NULL
,[EnrollmentDate] date NOT NULL
,[CourseFeePaid] money NOT NULL
);
go


-- Add Constraints (Module 02) -- 
Begin --Courses
	ALTER TABLE Courses
	Add Constraint pkCourses
	Primary Key (CourseID);

	Alter Table Courses
 	Add Constraint dfCourseStartDate
  	Default GetDate() For CourseStartDate;

	Alter Table Courses
 	Add Constraint dfCourseEndDate
  	Default GetDate() For CourseEndDate;


End
go

Begin --Students
	
	ALTER TABLE Students
	Add Constraint pkStudentID
	Primary Key(StudentID);

	ALTER TABLE Students
	Add Constraint ukStudentNumber
	Unique(StudentNumber);

	ALTER TABLE Students
	Add Constraint ckEmail
	Check (Email like '%_@_%.__%');

	ALTER TABLE Students
	Add Constraint ukEmail
	Unique (Email);

	ALTER TABLE Students
	Add Constraint ukPhoneNumber
	Unique (PhoneNumber);

	ALTER TABLE Students
	Add Constraint ckPhoneNumber
	Check (PhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');

	ALTER TABLE Students
	Add Constraint ckZipCode
	Check (ZipCode like '[0-9][0-9][0-9][0-9][0-9]');

End
go

Begin
	ALTER TABLE CourseEnrollment
	Add Constraint pkEnrollmentID
	Primary Key (EnrollmentID);

	ALTER TABLE CourseEnrollment
	Add Constraint fkStudentID
	Foreign Key (StudentID) references Students(StudentID);

	ALTER TABLE CourseEnrollment
	Add Constraint fkCourseID
	Foreign Key (CourseID) references Courses(CourseID);

	Alter Table CourseEnrollment
 	Add Constraint dfEnrollmentDate
  	Default GetDate() For EnrollmentDate;
End
go

-- Add Views -- 

CREATE or ALTER VIEW vCourses 
With SchemaBinding
AS
	SELECT
	CourseID,
	CourseName,
	CourseStartDate,
	CourseEndDate,
	CourseStartTime,
	CourseEndTime,
	CourseDaysOfWeek,
	CourseCurrentPrice
	FROM dbo.Courses;
GO


CREATE or ALTER VIEW vStudents 
With SchemaBinding
AS 
	SELECT
	StudentID,
	StudentNumber,
	StudentFirstName,
	StudentLastName,
	Email,
	PhoneNumber,
	StreetAddress,
	City,
	State,
	ZipCode
	FROM dbo.Students;
GO


CREATE or ALTER View vCourseEnrollment 
With SchemaBinding
AS
	SELECT
	EnrollmentID,
	StudentID,
	CourseID,
	EnrollmentDate,
	CourseFeePaid
	FROM dbo.CourseEnrollment;
GO

CREATE or ALTER View vEarlyEnrollmentDiscount
With Schemabinding
AS
	SELECT TOP 10000
	vCE.StudentID,
	[StudentName] = vS.StudentLastName + ', ' + vS.StudentFirstName,
	EnrollmentDate,
	[EarlyEnrollmentDiscount] = IsNull(Case
								When EnrollmentDate > '2016-12-31' then 'No'
								When EnrollmentDate = '2016-12-31' then 'Yes'
								When EnrollmentDate < '2016-12-31' then 'Yes'
								End, 0)
	FROM dbo.vCourseEnrollment as vCE INNER JOIN dbo.vStudents as vS
	ON vCE.StudentID = vS.StudentID 
	Order by [EarlyEnrollmentDiscount] DESC, [StudentName] ASC
	;
go

CREATE or ALTER VIEW vCourseEnrollmentConfirmation
With Schemabinding
AS
	SELECT TOP 100000
	vC.CourseID,
	vC.CourseName,
	vS.StudentID,
	vCE.CourseFeePaid,
	[ConfirmationEmailedto] = vS.Email,
	[SentOn] = vCE.EnrollmentDate
	FROM dbo.vCourses as vC 
	INNER JOIN dbo.vCourseEnrollment as vCE 
	ON vC.CourseID = vCE.CourseID
	INNER JOIN dbo.vStudents as vS 
	ON vCE.StudentID = vS.StudentID
	Order by vS.StudentID ASC;
go

CREATE or ALTER VIEW vStudentsInterestedinJobs
With Schemabinding 
AS
	SELECT TOP 1000000
	[StudentName] = StudentLastName + ', ' + StudentFirstName,
	[SearchforJobsin] = City + ', ' + State,
	[SendJobListingsto] = Email
	FROM dbo.vStudents
	Order by [StudentName] ASC;
GO

--< Test Tables by adding Sample Data >--  

--Courses
Begin TRY
  Begin TRAN
	INSERT INTO Courses
	(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
	VALUES
	('SQL1 - Winter 2017', '2017-01-10', '2017-01-24', '06:00', '08:50', 'T', 399),
	('SQL2 - Winter 2017', '2017-01-31', '2017-02-14', '06:00', '08:50', 'T', 399)
  Commit TRAN
End TRY
Begin CATCH
  If @@TRANCount > 0 
  Begin
    Rollback TRANSACTION
  End
  Print 'Oops! Please check the data you are entering!'
  Print Error_Message()
End CATCH;
go


--Students
Begin TRY
  Begin TRAN
	INSERT INTO Students
	(StudentNumber, StudentFirstName, StudentLastName, Email, PhoneNumber, StreetAddress, City, State, ZipCode)
	VALUES
	('B-Smith-071', 'Bob', 'Smith', 'Bsmith@HipMail.com', '206-111-2222', '123 Main St', 'Seattle', 'WA', '98001'),
	('S-Jones-003', 'Sue', 'Jones', 'SueJones@YaYou.com', '206-231-4321', '333 1st Ave', 'Seattle', 'WA', '98001')
  Commit TRAN
End TRY
Begin CATCH
  If @@TRANCount > 0 
  Begin
    Rollback TRANSACTION
  End
  Print 'Oops! Please check the data you are entering!'
  Print Error_Message()
End CATCH;
go



--CourseEnrollment
Begin TRY
  Begin TRAN
	INSERT INTO CourseEnrollment
	(StudentID, CourseID, EnrollmentDate, CourseFeePaid)
	VALUES
	(101, 1, '2017-01-03', 399),
	(102, 1, '2016-12-14', 349),
	(101, 2, '2017-01-17', 399),
	(102, 2, '2016-12-14', 349)
  Commit TRAN
End TRY
Begin CATCH
  If @@TRANCount > 0 
  Begin
    Rollback TRANSACTION
  End
  Print 'Oops! Please check the data you are entering!'
  Print Error_Message()
End CATCH;
go

Select * from vCourses
Select * from vStudents
Select * from vCourseEnrollment
Select * from vEarlyEnrollmentDiscount
Select * from vCourseEnrollmentConfirmation;
go

--------- Add Stored Procedures -------

--pCourseCreation
Create or Alter Procedure pCourseCreation
(	
	@CourseName nvarchar(100)
	,@CourseStartDate date
	,@CourseEndDate date
	,@CourseStartTime time 
	,@CourseEndTime time 
	,@CourseDaysOfWeek nvarchar(100)
	,@CourseCurrentPrice money
	,@NewCourseID int Output
)
-- Author: AOrdonio
-- Desc: Processes Inserts for a new course
-- Change Log: When,Who,What
-- 2023-03-12, AOrdonio,Created Sproc.
AS
	Begin 
		Declare @RC int = 0
		Begin Try 
			Begin Transaction 
			--Transaction Code--
				INSERT INTO Courses
				(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
				VALUES
				(@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseDaysOfWeek, @CourseCurrentPrice);
			--Updated Table (after insertion)	
				SELECT * from vCourses
				Order by CourseID ASC;
			Commit Transaction 
			Set @RC = +1
			Set @NewCourseID = @@IDENTITY
		End Try 
		Begin Catch 
			Rollback Transaction 
			Print 'Oops! Please check the data you are entering!'
			Print Error_Message()
			Set @RC = -1
		End Catch 
		Return @RC;
	End;
GO

--pNewStudentRegistration

Create or Alter Procedure pNewStudentRegistration
(
	@StudentFirstName nvarchar(100)
	,@StudentLastName nvarchar(100)
	,@Email nvarchar(100)
	,@PhoneNumber nvarchar(12)
	,@StreetAddress nvarchar(100)
	,@City nvarchar(100)
	,@State nvarchar(2)
	,@ZipCode int
	,@NewStudentID int OUTPUT
	,@NewStudentNumber nvarchar(100) OUTPUT
)
-- Author: AOrdonio
-- Desc: Processes Inserts for a new Student
-- Change Log: When,Who,What
-- 2023-03-12, AOrdonio,Created Sproc.
AS
	Begin 
		Declare @RC int = 0
		Begin Try 
			Begin Transaction 
			--Transaction Code
				Set @NewStudentID = @@IDENTITY;
				Set @NewStudentNumber = ISNULL(CONCAT_WS('-', Substring(@StudentFirstName,1,4), @StudentLastName, Cast(@NewStudentID as nvarchar(100))), 1);
				INSERT INTO dbo.Students
				(StudentNumber,StudentFirstName, StudentLastName, Email, PhoneNumber, StreetAddress, City, State, ZipCode)
				VALUES
				(@NewStudentNumber, @StudentFirstName, @StudentLastName, @Email, @PhoneNumber, @StreetAddress, @City, @State, @ZipCode);
			--Updated table (after insertion)
				Select * from dbo.vStudents
				Order by StudentID ASC;
			Commit Transaction 
			Set @RC = +1
		End Try 
		Begin Catch 
			Rollback Transaction 
			Print 'Oops! Please check the data you are entering!'
			Print Error_Message()
			Set @RC = -1
		End Catch 
		Return @RC;
	End;
go


--pSQLTrack
Create or Alter Procedure pSQLTrack
-- Author: AOrdonio
-- Desc: Creates a progress report on who is on track for their SQL pathway
-- Change Log: When,Who,What
-- 2023-03-12, AOrdonio,Created Sproc.
AS
	Begin 
		Declare @RC int = 0
		Begin Try
			Begin Transaction 
			--Transaction Code
			
			SELECT TOP 10000
				S.StudentID,
				[StudentName] = [StudentLastName] + ',' + [StudentFirstName],
				CourseID,
				[EnrolledClasses] = IsNull(Case
											When CourseFeePaid > 0 then 'Yes'
											When CourseFeePaid = 0 then 'No'
											When CourseFeePaid = Null then 'No'
											End, 'No')
			FROM dbo.Students as S FULL OUTER JOIN dbo.vCourseEnrollment as CE
			ON S.StudentID = CE.StudentID
			Order by StudentID ASC;

			Commit Transaction
		End Try 
		Begin Catch 
			Rollback Transaction 
			Print 'Oops! Please check the data you are entering!'
			Print Error_Message()
			Set @RC = -1
		End Catch 
		Return @RC;
	End



-------- SET PERMISSIONS -------

--Role: dbo
Grant all on Courses to dbo;
Grant all on vCourses to dbo;

Grant all on Students to dbo;
Grant all on vStudents to dbo;

Grant all on CourseEnrollment to dbo;
Grant all on vCourseEnrollment to dbo;
go

--Role: Public

Deny all on Courses to Public;
Grant Select on vCourses to Public;

Deny all on Students to Public;
Grant all on vStudents to Public;

Deny all on CourseEnrollment to Public;
Grant all on vCourseEnrollment to Public;
go

--------< TEST SPROCS >----------

--Test pCourseCreation
Declare @Status int;
Declare @ClassID int = NULL
Execute @Status = pCourseCreation
	@CourseName = 'SQL3 - Spring 2017'
	,@CourseStartDate = '2017-02-21'
	,@CourseEndDate = '2017-03-14'
	,@CourseStartTime = '06:00'
	,@CourseEndTime = '08:50'
	,@CourseDaysOfWeek = 'T'
	,@CourseCurrentPrice = 399
	,@NewCourseID = @ClassId Output;
Select Case @Status
  When +1 Then 'Course creation was successful!'
  When -1 Then 'Course creation failed!'
  End as [Status];
Select @ClassID as [The new CourseID is];
go

--Test pStudentRegistration
Declare @Status int;
Declare @RegisteredStudentID int = null;
Declare @RegisteredStudentNumber nvarchar(100) = null;
Exec @Status = pNewStudentRegistration
	@StudentFirstName = 'Matthew'
	,@StudentLastName = 'Healy'
	,@Email = 'matty1975@dirtyhit.com'
	,@PhoneNumber = '206-122-1975'
	,@StreetAddress = '123 Ocean Blvd'
	,@City = 'Seattle'
	,@State = 'WA'
	,@ZipCode = 98101 
	,@NewStudentID = @RegisteredStudentID OUTPUT
	,@NewStudentNumber = @RegisteredStudentNumber OUTPUT
Select Case @Status
  When +1 Then 'Registration was successful!'
  When -1 Then 'Registration failed!'
  End as [Status];
Select 
	[NewStudentID] = @RegisteredStudentID 
	,[NewStudentNumber] = @RegisteredStudentNumber;
go

Exec pSQLTrack;
go

