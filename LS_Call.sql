USE [master]
GO
/****** Object:  Database [LS_Call_Plan_BOT]    Script Date: 9/13/2017 2:33:01 PM ******/
CREATE DATABASE [LS_Call_Plan_BOT]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LS_Call_Plan_BOT', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LS_Call_Plan_BOT.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'LS_Call_Plan_BOT_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LS_Call_Plan_BOT_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LS_Call_Plan_BOT].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET ARITHABORT OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET  DISABLE_BROKER 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET RECOVERY FULL 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET  MULTI_USER 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [LS_Call_Plan_BOT]
GO
/****** Object:  StoredProcedure [dbo].[CHATBOT_GETEMPLOYEEDETAILS]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Karan Kumar>
-- Create date: <28-Jun-2017>
-- Description:	<Get Chat Bot Employee Details By Rep ID>
-- =============================================
CREATE PROCEDURE [dbo].[CHATBOT_GETEMPLOYEEDETAILS] 
	-- Add the parameters for the stored procedure here
	@Rep_ID NVarchar(20)
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT * From ChatBot_Employee_Roster R WHERE R.Rep_ID=@Rep_ID;
END

GO
/****** Object:  StoredProcedure [dbo].[ChatBot_GetPhysicianAvailability]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Karan Kumar>
-- Create date: <30 Jun 2017>
-- Description:	<Get Available Physician,,>

-- =============================================
CREATE PROCEDURE [dbo].[ChatBot_GetPhysicianAvailability]
	-- Add the parameters for the stored procedure here
	@Rep_Id Varchar(10),  
	@Start_Time Varchar(10),
	@End_Time Varchar(10)
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT	PC.Customer_ID, PV.First_Name, 
	   PV.Last_Name,
	   PV.First_Name + ', ' + PV.Last_Name as Full_Name,
	   PV.Specialty,
      Case WHEN Min(CONVERT(Int,PC.Start_Time)) > 12 THEN
				Min(CONVERT(Int,PC.Start_Time))-12
			Else
				Min(CONVERT(Int,PC.Start_Time))
			END
		Start_Time,
      Case WHEN Max(CONVERT(int,PC.End_Time))>12 THEN
				(Max(CONVERT(int,PC.End_Time)))-12
		   Else
				Max(CONVERT(int,PC.End_Time))
		   END	
	   End_Time,
	   PV.Brand_X_TRx,
	   PV.Brand_Y_TRx, 
	   PV.Brand_Z_TRx
	   
 FROM	[dbo].[ChatBot_Physician_Calender] PC,
		[dbo].[ChatBot_Physician_Universe] PV,
		[dbo].[ChatBot_Employee_Roster] ER
 Where	PC.Customer_ID=PV.Customer_ID
		AND PV.Territory_Code=ER.Territory_Code
		AND ER.Rep_ID=@Rep_Id 
		And PC.Start_Time >= @Start_Time
		And PC.End_Time <=@End_Time
		And UPPER(PC.Status)='AVAILABLE'
  Group by 
  PC.Customer_ID ,PV.First_Name,
  PV.Last_Name,PV.Specialty,PV.Brand_X_TRx,
	   PV.Brand_Y_TRx, 
	   PV.Brand_Z_TRx
END

GO
/****** Object:  Table [dbo].[ChatBot_Call Activity]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Call Activity](
	[Customer_ID] [nvarchar](255) NULL,
	[First_Name] [nvarchar](255) NULL,
	[Last_Name] [nvarchar](255) NULL,
	[Specialty] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Zip] [nvarchar](255) NULL,
	[Territory_Code] [nvarchar](255) NULL,
	[Region_Code] [nvarchar](255) NULL,
	[Territory_Name] [nvarchar](255) NULL,
	[Region_Name] [nvarchar](255) NULL,
	[Target_Level] [nvarchar](255) NULL,
	[Call_ID] [nvarchar](255) NULL,
	[Call_Type] [nvarchar](255) NULL,
	[Sales_Direction_1] [nvarchar](255) NULL,
	[Sales_Direction_2] [nvarchar](255) NULL,
	[Sales_Direction_3] [nvarchar](255) NULL,
	[Sample_Quantity] [float] NULL,
	[Sampled_Product] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Employee_Roster]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Employee_Roster](
	[Rep_ID] [nvarchar](255) NULL,
	[First_Name] [nvarchar](255) NULL,
	[Last_Name] [nvarchar](255) NULL,
	[Territory_Code] [nvarchar](255) NULL,
	[Region_Code] [nvarchar](255) NULL,
	[Territory_Name] [nvarchar](255) NULL,
	[Region_Name] [nvarchar](255) NULL,
	[Start_Date] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Facebook_Connections]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Facebook_Connections](
	[Customer_ID] [nvarchar](255) NULL,
	[Common_Connections] [nvarchar](255) NULL,
	[Connection_HCP_Flag] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Facebook_Events_Attended]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Facebook_Events_Attended](
	[Customer_ID] [nvarchar](255) NULL,
	[Events_Attended] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Facebook_Groups]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Facebook_Groups](
	[Customer_ID] [nvarchar](255) NULL,
	[Facebook_Groups] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Facebook_Interest_Areas]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Facebook_Interest_Areas](
	[Customer_ID] [nvarchar](255) NULL,
	[Interests] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Facebook_Planned_Events]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Facebook_Planned_Events](
	[Customer_ID] [nvarchar](255) NULL,
	[Planned_Events] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Individual_Publications]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Individual_Publications](
	[Customer_ID] [nvarchar](255) NULL,
	[Individual_Publications] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Internal_Sponsored_Trials]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Internal_Sponsored_Trials](
	[Customer_ID] [nvarchar](255) NULL,
	[Internal_Sponsored_Trials] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Joint_Publications]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Joint_Publications](
	[Customer_ID] [nvarchar](255) NULL,
	[Joint_Publications] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_LinkedIn_Connections]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_LinkedIn_Connections](
	[Customer_ID] [nvarchar](255) NULL,
	[Common_Connections] [nvarchar](255) NULL,
	[Connection_HCP_Flag] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_LinkedIn_Education]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_LinkedIn_Education](
	[Customer_ID] [nvarchar](255) NULL,
	[Education_Institute] [nvarchar](255) NULL,
	[Degree] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_LinkedIn_Experience]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_LinkedIn_Experience](
	[Customer_ID] [nvarchar](255) NULL,
	[Experience (months)] [float] NULL,
	[Start_Date] [datetime] NULL,
	[End_Date] [datetime] NULL,
	[Office_Type] [nvarchar](255) NULL,
	[Office_Name] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_LinkedIn_Interest_Areas]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_LinkedIn_Interest_Areas](
	[Customer_ID] [nvarchar](255) NULL,
	[Interests] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Physician_Calender]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Physician_Calender](
	[Customer_ID] [nvarchar](255) NULL,
	[Start_Time] [float] NULL,
	[End_Time] [float] NULL,
	[Status] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Physician_Universe]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Physician_Universe](
	[Customer_ID] [nvarchar](255) NULL,
	[First_Name] [nvarchar](255) NULL,
	[Last_Name] [nvarchar](255) NULL,
	[Specialty] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Zip] [nvarchar](255) NULL,
	[Territory_Code] [nvarchar](255) NULL,
	[Region_Code] [nvarchar](255) NULL,
	[Territory_Name] [nvarchar](255) NULL,
	[Region_Name] [nvarchar](255) NULL,
	[Target_Flag] [nvarchar](255) NULL,
	[Target_Level] [nvarchar](255) NULL,
	[Brand_X_TRx] [float] NULL,
	[Brand_Y_TRx] [float] NULL,
	[Brand_Z_TRx] [float] NULL,
	[Customer_Valuation_Index] [float] NULL,
	[Customer_Rank] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_PTT_File]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_PTT_File](
	[Customer_ID] [nvarchar](255) NULL,
	[First_Name] [nvarchar](255) NULL,
	[Last_Name] [nvarchar](255) NULL,
	[Specialty] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Zip] [nvarchar](255) NULL,
	[Territory_Code] [nvarchar](255) NULL,
	[Region_Code] [nvarchar](255) NULL,
	[Territory_Name] [nvarchar](255) NULL,
	[Region_Name] [nvarchar](255) NULL,
	[Target_Level] [nvarchar](255) NULL,
	[CallFrequency] [float] NULL,
	[Sample_per_Call_P1] [float] NULL,
	[Sample_per_Call_P2] [float] NULL,
	[Sample_per_Call_P3] [float] NULL,
	[Sales_Direction_1] [nvarchar](255) NULL,
	[Sales_Direction_2] [nvarchar](255) NULL,
	[Sales_Direction_3] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChatBot_Third_Party_Trials]    Script Date: 9/13/2017 2:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatBot_Third_Party_Trials](
	[Customer_ID] [nvarchar](255) NULL,
	[Third_Party_Trials] [nvarchar](255) NULL
) ON [PRIMARY]

GO
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0001', N'Sample Only', NULL, NULL, NULL, 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0001', N'Sample Only', NULL, NULL, NULL, 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0001', N'Sample Only', NULL, NULL, NULL, 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0002', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0002', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0003', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0003', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0003', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'002', N'Chris', N'Evans', N'ALLERGY', N'3020 SCENIC HWY S', N'SNELLVILLE', N'GA', N'30039', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0004', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'002', N'Chris', N'Evans', N'ALLERGY', N'3020 SCENIC HWY S', N'SNELLVILLE', N'GA', N'30039', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0004', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'002', N'Chris', N'Evans', N'ALLERGY', N'3020 SCENIC HWY S', N'SNELLVILLE', N'GA', N'30039', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0005', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'002', N'Chris', N'Evans', N'ALLERGY', N'3020 SCENIC HWY S', N'SNELLVILLE', N'GA', N'30039', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0005', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'002', N'Chris', N'Evans', N'ALLERGY', N'3020 SCENIC HWY S', N'SNELLVILLE', N'GA', N'30039', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0006', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0007', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0007', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0007', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0008', N'Sample Only', NULL, NULL, NULL, 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0009', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0009', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0009', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0010', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 3, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0011', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 3, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0011', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 2, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0011', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 1, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0012', N'Sample Only', NULL, NULL, NULL, 2, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0012', N'Sample Only', NULL, NULL, NULL, 1, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0013', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 3, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0013', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 2, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0013', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 1, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0014', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 3, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0014', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 2, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', N'C0014', N'Detail and Sample', N'Brand_X', N'Brand_Y', N'Brand_Z', 1, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'006', N'Leo', N'Brown', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'12 MEDICAL DR NE', N'CARTERSVILLE', N'GA', N'30121', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', N'C0015', N'Detail and Sample', N'Brand_Y', N'Brand_Z', NULL, 3, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'006', N'Leo', N'Brown', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'12 MEDICAL DR NE', N'CARTERSVILLE', N'GA', N'30121', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', N'C0015', N'Detail and Sample', N'Brand_Y', N'Brand_Z', NULL, 1, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'006', N'Leo', N'Brown', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'12 MEDICAL DR NE', N'CARTERSVILLE', N'GA', N'30121', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', N'C0016', N'Sample Only', NULL, NULL, NULL, 3, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'006', N'Leo', N'Brown', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'12 MEDICAL DR NE', N'CARTERSVILLE', N'GA', N'30121', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', N'C0017', N'Detail and Sample', N'Brand_Y', N'Brand_Z', NULL, 3, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'006', N'Leo', N'Brown', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'12 MEDICAL DR NE', N'CARTERSVILLE', N'GA', N'30121', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', N'C0017', N'Detail and Sample', N'Brand_Y', N'Brand_Z', NULL, 1, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0018', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0018', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0018', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0019', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0019', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0020', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 3, N'Brand_Z')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0020', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 2, N'Brand_X')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', N'C0020', N'Detail and Sample', N'Brand_Z', N'Brand_X', N'Brand_Y', 1, N'Brand_Y')
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'011', N'Jen', N'Mendez', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Non-Target', N'C0021', N'Detail Only', N'Brand_Y', N'Brand_Z', NULL, NULL, NULL)
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'013', N'Jack', N'Snyder', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Non-Target', N'C0022', N'Detail Only', N'Brand_Y', N'Brand_X', NULL, NULL, NULL)
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'015', N'Serena', N'Smith', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Non-Target', N'C0023', N'Detail Only', N'Brand_X', N'Brand_Y', NULL, NULL, NULL)
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'015', N'Serena', N'Smith', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Non-Target', N'C0024', N'Detail Only', N'Brand_X', N'Brand_Y', NULL, NULL, NULL)
INSERT [dbo].[ChatBot_Call Activity] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [Call_ID], [Call_Type], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3], [Sample_Quantity], [Sampled_Product]) VALUES (N'014', N'Rob', N'Owen', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Non-Target', N'C0025', N'Detail and Sample', N'Brand_Z', NULL, NULL, 1, N'Brand_Z')
INSERT [dbo].[ChatBot_Employee_Roster] ([Rep_ID], [First_Name], [Last_Name], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Start_Date]) VALUES (N'R001', N'Adam', N'Hixon', N'10101', N'10100', N'Birmingham', N'NorthEast', CAST(N'2017-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Dr. Sam Fury', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Adam Sandler', N'N')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Dev Patel', N'N')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Dr. Nikita Romanov', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'002', N'Dr. Chris Ambrose', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'002', N'Dr. Charles Xavier', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'003', N'Christina Adams', N'N')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'003', N'Wade Wilson', N'N')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'003', N'Dr. Jade Knight', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'004', N'Kim Williams', N'N')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'004', N'Peter Dinklage', N'N')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'005', N'Dr. Amulya Singh', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'005', N'Dr. Debbie Watson', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'005', N'Dr. Stacy Kudrow', N'Y')
INSERT [dbo].[ChatBot_Facebook_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'005', N'Alex Jones', N'N')
INSERT [dbo].[ChatBot_Facebook_Events_Attended] ([Customer_ID], [Events_Attended]) VALUES (N'001', N'NorthEast Summit of Neurologists')
INSERT [dbo].[ChatBot_Facebook_Events_Attended] ([Customer_ID], [Events_Attended]) VALUES (N'001', N'World Congress on Innovative Research in Neurology')
INSERT [dbo].[ChatBot_Facebook_Events_Attended] ([Customer_ID], [Events_Attended]) VALUES (N'002', N'2nd International Conference and Expo on Holistic Medicine and Nursing')
INSERT [dbo].[ChatBot_Facebook_Events_Attended] ([Customer_ID], [Events_Attended]) VALUES (N'004', N'3rd Global Summit on Laser Treatment')
INSERT [dbo].[ChatBot_Facebook_Events_Attended] ([Customer_ID], [Events_Attended]) VALUES (N'007', N'Glycobiology World Congress')
INSERT [dbo].[ChatBot_Facebook_Groups] ([Customer_ID], [Facebook_Groups]) VALUES (N'004', N'Harward Medical School 1997 Batch')
INSERT [dbo].[ChatBot_Facebook_Groups] ([Customer_ID], [Facebook_Groups]) VALUES (N'004', N'Abdominal Surgeons Group, GA')
INSERT [dbo].[ChatBot_Facebook_Groups] ([Customer_ID], [Facebook_Groups]) VALUES (N'004', N'Analytics for Clinical Trials')
INSERT [dbo].[ChatBot_Facebook_Groups] ([Customer_ID], [Facebook_Groups]) VALUES (N'001', N'Glaims Institute of Medical Acience, 2001 Batch')
INSERT [dbo].[ChatBot_Facebook_Groups] ([Customer_ID], [Facebook_Groups]) VALUES (N'001', N'Adventure on Wheels')
INSERT [dbo].[ChatBot_Facebook_Groups] ([Customer_ID], [Facebook_Groups]) VALUES (N'001', N'Pfizer Speaker Group')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'001', N'Deakin University')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'001', N'Doctors Jobs in US')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'001', N'Pfizer')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'001', N'AstraZeneca')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'002', N'Boehringer Ingelheim')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'002', N'Abbott')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'002', N'DIA')
INSERT [dbo].[ChatBot_Facebook_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'002', N'Clinical Research and Clinical Drug Development')
INSERT [dbo].[ChatBot_Facebook_Planned_Events] ([Customer_ID], [Planned_Events]) VALUES (N'004', N'Private Equity Forum Chicago 2017')
INSERT [dbo].[ChatBot_Facebook_Planned_Events] ([Customer_ID], [Planned_Events]) VALUES (N'005', N'19th Annual Cardiology Conference')
INSERT [dbo].[ChatBot_Facebook_Planned_Events] ([Customer_ID], [Planned_Events]) VALUES (N'009', N'23rd International Workshop Conference on Angiology')
INSERT [dbo].[ChatBot_Individual_Publications] ([Customer_ID], [Individual_Publications]) VALUES (N'001', N'Pharmacological basics of therapeutics')
INSERT [dbo].[ChatBot_Individual_Publications] ([Customer_ID], [Individual_Publications]) VALUES (N'001', N'Improving Bioscience research reporting')
INSERT [dbo].[ChatBot_Individual_Publications] ([Customer_ID], [Individual_Publications]) VALUES (N'001', N'Lasor beam propagation through skin tissues')
INSERT [dbo].[ChatBot_Individual_Publications] ([Customer_ID], [Individual_Publications]) VALUES (N'004', N'Immunochemistry in practice')
INSERT [dbo].[ChatBot_Individual_Publications] ([Customer_ID], [Individual_Publications]) VALUES (N'004', N'Study on fibrinogen and white cell count')
INSERT [dbo].[ChatBot_Internal_Sponsored_Trials] ([Customer_ID], [Internal_Sponsored_Trials]) VALUES (N'004', N'A clinical trial of the effects of dietary patterns on blood pressure')
INSERT [dbo].[ChatBot_Joint_Publications] ([Customer_ID], [Joint_Publications]) VALUES (N'005', N'Mutation in familial motor neuron disease')
INSERT [dbo].[ChatBot_Joint_Publications] ([Customer_ID], [Joint_Publications]) VALUES (N'004', N'Aromatase activity in primary and metastatic human breast cancer')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'004', N'Dr. Matt Thomas', N'Y')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'004', N'Dr. John Yan', N'Y')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'004', N'Dr. Stuart Cain', N'Y')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'004', N'Dr. William Robbs', N'Y')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Allen Toffel', N'N')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Dr. Matt Thomas', N'Y')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Dr. Brendan Faser', N'Y')
INSERT [dbo].[ChatBot_LinkedIn_Connections] ([Customer_ID], [Common_Connections], [Connection_HCP_Flag]) VALUES (N'001', N'Dr. Frank Miller', N'Y')
INSERT [dbo].[ChatBot_LinkedIn_Education] ([Customer_ID], [Education_Institute], [Degree]) VALUES (N'001', N'Harward Medical School', N'MD')
INSERT [dbo].[ChatBot_LinkedIn_Education] ([Customer_ID], [Education_Institute], [Degree]) VALUES (N'002', N'Stanford Medical School', N'DO')
INSERT [dbo].[ChatBot_LinkedIn_Education] ([Customer_ID], [Education_Institute], [Degree]) VALUES (N'003', N'Community Medical College, NV', N'MD')
INSERT [dbo].[ChatBot_LinkedIn_Education] ([Customer_ID], [Education_Institute], [Degree]) VALUES (NULL, NULL, NULL)
INSERT [dbo].[ChatBot_LinkedIn_Experience] ([Customer_ID], [Experience (months)], [Start_Date], [End_Date], [Office_Type], [Office_Name]) VALUES (N'001', 60, CAST(N'2000-01-01 00:00:00.000' AS DateTime), CAST(N'2004-12-31 00:00:00.000' AS DateTime), N'Clinic', N'Allergy Specialist Clinic')
INSERT [dbo].[ChatBot_LinkedIn_Experience] ([Customer_ID], [Experience (months)], [Start_Date], [End_Date], [Office_Type], [Office_Name]) VALUES (N'001', 60, CAST(N'2005-01-01 00:00:00.000' AS DateTime), CAST(N'2015-12-31 00:00:00.000' AS DateTime), N'Account', N'Fortis Hospital')
INSERT [dbo].[ChatBot_LinkedIn_Experience] ([Customer_ID], [Experience (months)], [Start_Date], [End_Date], [Office_Type], [Office_Name]) VALUES (N'001', 18, CAST(N'2016-01-01 00:00:00.000' AS DateTime), NULL, N'Account', N'Max Hospital')
INSERT [dbo].[ChatBot_LinkedIn_Experience] ([Customer_ID], [Experience (months)], [Start_Date], [End_Date], [Office_Type], [Office_Name]) VALUES (N'003', 36, CAST(N'2005-01-01 00:00:00.000' AS DateTime), CAST(N'2007-12-31 00:00:00.000' AS DateTime), N'Clinic', N'Specialist Treatment Centre')
INSERT [dbo].[ChatBot_LinkedIn_Experience] ([Customer_ID], [Experience (months)], [Start_Date], [End_Date], [Office_Type], [Office_Name]) VALUES (N'003', 48, CAST(N'2008-01-01 00:00:00.000' AS DateTime), CAST(N'2011-12-31 00:00:00.000' AS DateTime), N'Account', N'Apollo Hospital')
INSERT [dbo].[ChatBot_LinkedIn_Experience] ([Customer_ID], [Experience (months)], [Start_Date], [End_Date], [Office_Type], [Office_Name]) VALUES (N'003', 66, CAST(N'2012-01-01 00:00:00.000' AS DateTime), NULL, N'Account', N'Ryan Medical Centre')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'011', N'Advance Research in Abdominal Surgery')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'011', N'Cummins Medical Devices')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'011', N'Abbott')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'007', N'Generic Drugs')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'007', N'Development in Managed Markets')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'012', N'Disease Discovery in Dermatology')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'012', N'Pfizer')
INSERT [dbo].[ChatBot_LinkedIn_Interest_Areas] ([Customer_ID], [Interests]) VALUES (N'012', N'Clinical Research and Clinical Drug Development')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 11, 12, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 12, 13, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'001', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 8, 9, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 12, 13, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 16, 17, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'002', 17, 18, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 15, 16, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 16, 17, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 17, 18, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'004', 8, 9, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 13, 14, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 14, 15, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'003', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 8, 9, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'005', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 9, 10, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 16, 17, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'006', 17, 18, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 9, 10, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 10, 11, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 11, 12, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'007', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 8, 9, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 11, 12, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 12, 13, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'008', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 9, 10, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 16, 17, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'009', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 8, 9, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 15, 16, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 16, 17, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'010', 17, 18, N'Available')
GO
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 9, 10, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'011', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 8, 9, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 15, 16, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 16, 17, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'012', 17, 18, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'013', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 8, 9, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 9, 10, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 10, 11, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 11, 12, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 13, 14, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 14, 15, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 15, 16, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'014', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 8, 9, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 9, 10, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 10, 11, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 11, 12, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 12, 13, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 13, 14, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 14, 15, N'Available')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 15, 16, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 16, 17, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Calender] ([Customer_ID], [Start_Time], [End_Time], [Status]) VALUES (N'015', 17, 18, N'Occupied')
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'A', 94, 86, 88, 0.96, 1)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'002', N'Chris', N'Evans', N'ALLERGY', N'3020 SCENIC HWY S', N'SNELLVILLE', N'GA', N'30039', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'A', 74, 60, 50, 0.94, 2)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'A', 77, 59, 95, 0.92, 3)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'B', 71, 83, 67, 0.9, 4)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'005', N'Ned', N'Stark', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'100 GENEVIEVE CT', N'PEACHTREE CITY', N'GA', N'30269', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'B', 75, 59, 85, 0.83, 5)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'006', N'Leo', N'Brown', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'12 MEDICAL DR NE', N'CARTERSVILLE', N'GA', N'30121', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'C', 95, 75, 82, 0.8, 6)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'A', 100, 94, 66, 0.8, 7)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'008', N'Gal', N'Lee', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'231 GRAEFE ST', N'GRIFFIN', N'GA', N'30224', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'C', 66, 83, 95, 0.76, 8)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'009', N'Amy', N'Adams', N'ADOLESCENT MEDICINE (PEDIATRICS)', N'755 MOUNT VERNON HWY NE', N'ATLANTA', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'C', 64, 79, 73, 0.73, 9)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'010', N'Sophia', N'Myles', N'ADOLESCENT MEDICINE (PEDIATRICS)', N'744 NOAH DR', N'JASPER', N'GA', N'30143', N'10101', N'10100', N'Birmingham', N'NorthEast', N'Y', N'C', 62, 52, 65, 0.71, 10)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'011', N'Jen', N'Mendez', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'N', N'Non-Target', 16, 29, 28, 0.4, 11)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'012', N'Will', N'Turner', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'N', N'Non-Target', 26, 18, 21, 0.37, 12)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'013', N'Jack', N'Snyder', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'N', N'Non-Target', 21, 28, 24, 0.34, 13)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'014', N'Rob', N'Owen', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'N', N'Non-Target', 16, 12, 20, 0.28, 14)
INSERT [dbo].[ChatBot_Physician_Universe] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Flag], [Target_Level], [Brand_X_TRx], [Brand_Y_TRx], [Brand_Z_TRx], [Customer_Valuation_Index], [Customer_Rank]) VALUES (N'015', N'Serena', N'Smith', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'N', N'Non-Target', 30, 30, 17, 0.23, 15)
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'001', N'John', N'Players', N'ALLERGY', N'4895 WINDWARD PKWY', N'ALPHARETTA', N'GA', N'30004', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', 8, 2, 1, 3, N'Brand_Z', N'Brand_X', N'Brand_Y')
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'002', N'Chris', N'Evans', N'ALLERGY', N'3020 SCENIC HWY S', N'SNELLVILLE', N'GA', N'30039', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', 8, 2, 1, 3, N'Brand_Z', N'Brand_X', N'Brand_Y')
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'003', N'Robert', N'Buttler', N'ABDOMINAL SURGERY', N'800 MOUNT VERNON HWY NE', N'SANDY SPRINGS', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', 8, 2, 1, 3, N'Brand_Z', N'Brand_X', N'Brand_Y')
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'004', N'Paul', N'Wilson', N'ABDOMINAL SURGERY', N'5670 PEACHTREE DUNWOODY RD', N'ATLANTA', N'GA', N'30342', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', 6, 3, 2, 1, N'Brand_X', N'Brand_Y', N'Brand_Z')
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'005', N'Ned', N'Stark', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'100 GENEVIEVE CT', N'PEACHTREE CITY', N'GA', N'30269', N'10101', N'10100', N'Birmingham', N'NorthEast', N'B', 6, 3, 2, 1, N'Brand_X', N'Brand_Y', N'Brand_Z')
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'006', N'Leo', N'Brown', N'ADULT CARDIOTHORACIC ANESTHESIOLOGY', N'12 MEDICAL DR NE', N'CARTERSVILLE', N'GA', N'30121', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', 4, 0, 3, 1, N'Brand_Y', N'Brand_Z', NULL)
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'007', N'Jack', N'Warne', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'1525 CLIFTON RD NE', N'ATLANTA', N'GA', N'30322', N'10101', N'10100', N'Birmingham', N'NorthEast', N'A', 8, 2, 1, 3, N'Brand_Z', N'Brand_X', N'Brand_Y')
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'008', N'Gal', N'Lee', N'ANESTHESIOLOGY CRITICAL CARE MED (EM)', N'231 GRAEFE ST', N'GRIFFIN', N'GA', N'30224', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', 4, 0, 3, 1, N'Brand_Y', N'Brand_Z', NULL)
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'009', N'Amy', N'Adams', N'ADOLESCENT MEDICINE (PEDIATRICS)', N'755 MOUNT VERNON HWY NE', N'ATLANTA', N'GA', N'30328', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', 4, 0, 3, 1, N'Brand_Y', N'Brand_Z', NULL)
INSERT [dbo].[ChatBot_PTT_File] ([Customer_ID], [First_Name], [Last_Name], [Specialty], [Address], [City], [State], [Zip], [Territory_Code], [Region_Code], [Territory_Name], [Region_Name], [Target_Level], [CallFrequency], [Sample_per_Call_P1], [Sample_per_Call_P2], [Sample_per_Call_P3], [Sales_Direction_1], [Sales_Direction_2], [Sales_Direction_3]) VALUES (N'010', N'Sophia', N'Myles', N'ADOLESCENT MEDICINE (PEDIATRICS)', N'744 NOAH DR', N'JASPER', N'GA', N'30143', N'10101', N'10100', N'Birmingham', N'NorthEast', N'C', 4, 0, 3, 1, N'Brand_Y', N'Brand_Z', NULL)
INSERT [dbo].[ChatBot_Third_Party_Trials] ([Customer_ID], [Third_Party_Trials]) VALUES (N'004', N'A clinical trial of vena caval filters')
INSERT [dbo].[ChatBot_Third_Party_Trials] ([Customer_ID], [Third_Party_Trials]) VALUES (N'008', N'Mineral density and bone turnover in rheumatoid arthritis')
USE [master]
GO
ALTER DATABASE [LS_Call_Plan_BOT] SET  READ_WRITE 
GO
