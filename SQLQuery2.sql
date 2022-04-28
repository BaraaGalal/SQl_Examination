create database Examination
--create db with file groups
ON

( 
	NAME = Examination1, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Examination1.mdf',
	SIZE = 4MB
),
( 
	NAME = Examination2, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Examination2.ndf',
	SIZE = 3MB
),
FILEGROUP SECONDARY_fg 
( 
	NAME = Examination3,
	FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Examination3.ndf',
	SIZE = 1
),
( 
	NAME = Examination4,
	FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Examination4.ndf',
	SIZE = 1MB
)
LOG ON 
( 
	NAME = ExaminationLog1,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\ExaminationLog1.ldf', 
	SIZE = 1MB
);


select q_content
from Question_Content 
where cor_id = 1

select q_content
from Question_Content 
where cor_id = 2



-------------------------- see if Instructor have the same corse --------------------------------------------
Alter proc Instructor_Select_Exam_Proc(@ins_id int)
As
begin
	Select Distinct I.Name
	From Exam, Instructors I
	Where cor_id = @ins_id
end

exec Instructor_Select_Exam_Proc 1

-------------------------------------------------------------------------------------------------------------

-------------------------------- Add New MSQ --------------------------------------------------------
alter Proc NewQuestionsMSQ_Proc (@q_content nvarchar(MAX), @cor_id int, @op1 nvarchar(max),
								  @op2 nvarchar(max),@op3 nvarchar(max),@op4 nvarchar(max), @CorrectOption int)
as
begin 
	begin try 
		Insert Into Question_Content(q_content, cor_id, type) 
		Values(@q_content, @cor_id, 'msq')
		declare @q_id int
		set @q_id = scope_identity()

		Insert Into Question_Answer(q_id, answer)
		Values(@q_id, @op1)
		Insert Into Question_Answer(q_id, answer)
		Values(@q_id, @op2)
		Insert Into Question_Answer(q_id, answer)
		Values(@q_id, @op3)
		Insert Into Question_Answer(q_id, answer)
		Values(@q_id, @op4)

		declare @correctAnswer int
		set @correctAnswer = scope_identity() - 4 + @CorrectOption

		update Question_Content
		set op_answer = @correctAnswer
		where q_id = @q_id

		print 'New MSQ Questions Add'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch
end

exec NewQuestionsMSQ_Proc 'New MSQ Questions', 1, 'a', 'b', 'c', 'd', 2

-------------------------------------------------------------------------------------------------------------
---------------------------------------- add new True&False --------------------------------------------------------
Create Proc NewQuestionsTF_Proc (@q_content nvarchar(MAX), @cor_id int, @CorrectOption int)
as
begin 
	begin try 
		Insert Into Question_Content(q_content, cor_id, type) 
		Values(@q_content, @cor_id, 'true&false')
		declare @q_id int
		set @q_id = scope_identity()

		Insert Into Question_Answer(q_id, answer)
		Values(@q_id, 'True')
		Insert Into Question_Answer(q_id, answer)
		Values(@q_id, 'False')

		declare @correctAnswer int
		set @correctAnswer = scope_identity() - 2 + @CorrectOption

		update Question_Content
		set op_answer = @correctAnswer
		where q_id = @q_id

		print 'New true&false Questions Add'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch
end

exec NewQuestionsTF_Proc 'new true&false Q', 2, 2
--------------------------------------------------------------------------------------------------------------

--------------------------------- Instructor Select student For Exam -----------------------------------------  
alter proc InstructorSelectStudent_Proc(@ins_id int, @st_id int, @ex_id int)
as
begin
	select distinct I.Name, S.Name, E.type
	from Exam E, Instructors I, Instructors_Students_Exam ISE, Students S
	where I.ins_id = @ins_id and S.st_id = @st_id and E.ex_id = @ex_id
end

exec InstructorSelectStudent_Proc 1, 1, 2

------------------------------------- delete Questions--------------------------------------------------------
alter proc deleteQuestions_proc (@ins_id int, @ex_id int, @q_id int)
as
begin
	begin try
		if((@ins_id in (select distinct ins_id from Exam where @ex_id = ex_id))
		and ((select q_id from Question_Content where @q_id = q_id and q_id = @q_id) >0))
			begin
				delete 
				from Instructors_Question_Exam
				where q_id =  @q_id
				print 'Questions is delete'
			end
			else
			print 'u cant delete this Questions'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch

end
exec deleteQuestions_proc 1, 1, 1


--------------------------------- add new exam ------------------------------------------------------
Create Proc AddNewExam(@cor_id int, @ex_id int)
as
begin
	begin try 
		insert into Exam(cor_id, ex_id)
		values(@cor_id, @ex_id)
		print 'new Exam Added'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch
end

exec AddNewExam 2, 6

-------------------------------- new course -------------------------------------------------------------

Alter Proc NewCourse_proc(@cor_id int)
as
begin
	begin try
		Insert Into Course(cor_id)
		Values(@cor_id)
		print 'New Course'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch
end

NewCourse_proc 4


------------------------------------ new instructor------------------------------------------------------------
Alter Proc Newins_proc(@ins_id int, @name nvarchar(50))
as
begin
	begin try
		Insert Into Instructors(ins_id, Name)
		Values(@ins_id, @name)
		print 'New Instructor'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch
end

Newins_proc 4, mohamed

--------------------------------- Assing new Instructor to course ------------------------------------
alter Proc NewInstructor_proc(@ins_id int, @cor_id int)
as
begin
	begin try
		Insert Into Course_Instructors (ins_id, cor_id)
		Values(@ins_id, @cor_id)
		print 'New Instructor'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch
end

exec NewInstructor_proc 4,4

-------------------------------------------------------------------------------------------------------------

-------------------------------------- Enroll Student -------------------------------------------------------

create proc EnrollStudent_proc (@cor_id int, @st_id int)
as
begin

	begin try
		insert into Course_Students(cor_id, st_id)
		Values (@cor_id, @st_id)
		print 'Enroll Done'
	end try
	begin catch
		print ERROR_MESSAGE()
	end catch

end

exec EnrollStudent_proc 2, 6

-------------------------------------------------------------------------------------------------------------

-------------------------------------- all Students Degrees with the Exam ------------------------------------------------
create proc StudentDegree_Proc (@ex_id int)
as
begin 
	select S.Name, SUM(EQ.degree) as [Total Degree]
	from Students S, Instructors_Question_Exam EQ, Student_Question_Exam SA, Question_Content QC
	where S.st_id = SA.st_id and @ex_id = SA.ex_id and QC.q_id = EQ.q_id 
		and QC.op_answer = SA.id_student_answer
	group by S.Name
end

exec StudentDegree_Proc 2

--------------------------------------------------------------------------------------------------------------

------------------------------------- Show Specific Student Degree --------------------------------------------------------
alter proc StudentDegreeInExam_Proc (@ex_id int, @st_id int)
as
begin 
	select S.Name, SUM(EQ.degree) as [Total Degree]
	from Students S, Instructors_Question_Exam EQ, Student_Question_Exam SA, Question_Content QC
	where S.st_id = @st_id and @ex_id = SA.ex_id and QC.q_id = EQ.q_id 
		and QC.op_answer = SA.id_student_answer and SA.st_id =  @st_id and @ex_id = EQ.ins_id
	group by S.Name
end

exec StudentDegreeInExam_Proc 1, 1

----------------------------------------------------------------------------------------------------------------

-------------------------------- View To Show All of Exams -------------------------------------------
Create View ShowExams_View
as
(
	select * from Exam	
)

select * from ShowExams_View

----------------------------------------------------------------------------------------------------------

---------------------------------- View Show Corese Exam ---------------------------------------------------------  
Create View ShowCoreseExam_View
as
(
	select C.cor_name, E.type 
	from Course C, Exam E
	where C.cor_id = E.cor_id
)

select * from ShowCoreseExam_View

----------------------------------------------------------------------------------------------------------

---------------------------------- View Show Question and The Correct Answer ---------------------------------------------------------  
alter View ShowQuestion_View
as
(
	select Q.q_content, O.op_answer, O.answer
	from Question_Content Q, Question_Answer O
	where Q.op_answer = O.op_answer 
)

 select * from ShowQuestion_View
--------------------------------------- Trigger ----------------------------------------------------------
create trigger trgPreventDeleteExam
on Exam
instead of delete
as
begin
	print 'You can not delete from this table'
end

delete 
from Exam
where ex_id = 3
-------------------------------------------------------------------------------------------------------

---------------------------------------- Error Handling ----------------------------------------
sp_addmessage 50017, 16, 'you don"t have any authority on this Questions'

select * from sys.messages