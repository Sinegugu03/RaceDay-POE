/* =========================================================================
   RaceDay - Full Database Schema
  ========================================================================= */

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

/* =========================================================================
   Drop tables if they already exist (clean re-run support)
   Order respects foreign key dependencies (children first)
   ========================================================================= */
IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* =========================================================================
   Table: Users
   Holds both Organisers and Participants, distinguished by Role.
   ========================================================================= */
CREATE TABLE dbo.Users (
    UserId         INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
    FullName       NVARCHAR(100)       NOT NULL,
    Email          NVARCHAR(150)       NOT NULL UNIQUE,
    PasswordHash   NVARCHAR(256)       NOT NULL,
    Role           VARCHAR(20)         NOT NULL DEFAULT 'Participant',
    PhoneNumber    NVARCHAR(20)        NULL,
    CreatedAt      DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser', 'Participant', 'Admin'))
);
GO


/* =========================================================================
   Table: Events
   Each event is owned by exactly one Organiser.
   ========================================================================= */
CREATE TABLE dbo.Events (
    EventId        INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,
    OrganiserId    INT                 NOT NULL,
    Name           NVARCHAR(150)       NOT NULL,
    Description    NVARCHAR(1000)      NULL,
    EventDate      DATE                NOT NULL,
    Location       NVARCHAR(200)       NOT NULL,
    Status         VARCHAR(20)         NOT NULL DEFAULT 'Planned',
    CreatedAt      DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId)
        REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Events_Status CHECK (Status IN ('Planned', 'Open', 'Closed', 'Completed', 'Cancelled'))
    );
GO

/* =======================================================================
	Table: Categories
	Race categories within an event (e.g. 5km, 10km, Half Marathon).
========================================================================== */
CREATE TABLE dbo.Categories (
	CategoryId      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	EventId         INT               NOT NULL,
	Name            NVARCHAR(100)     NOT NULL,
	DistanceKm      DECIMAL(6,2)      NOT NULL,
	MaxParticipants INT               NOT NULL DEFAULT 100,
	Fee             DECIMAL(10,2)     NOT NULL DEFAULT 0,
	StartTime       TIME              NULL,
	CONSTRAINT FK_Categories_Event FOREIGN KEY (EventId)
		REFERENCES dbo.Events(EventId) ON DELETE CASCADE,
	CONSTRAINT CK_Categories_Distance CHECK (DistanceKm > 0),
	CONSTRAINT CK_Categories_MaxParticipants CHECK (MaxParticipants > 0)
);
GO

/* =======================================================================
	Table: Enrolments
	Links a Participant (Users) to a Category. A participant may
	only enrol once per category.
========================================================================== */
CREATE TABLE dbo.Enrolments (
	EnrolmentId     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ParticipantId   INT               NOT NULL,
	CategoryId      INT               NOT NULL,
	EnrolmentDate   DATETIME          NOT NULL DEFAULT GETDATE(),
	Status          VARCHAR(20)       NOT NULL DEFAULT 'Pending',
	CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantId)
		REFERENCES dbo.Users(UserId),
	CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryId)
		REFERENCES dbo.Categories(CategoryId),
	CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
	CONSTRAINT UQ_Enrolments_Participant_Category UNIQUE (ParticipantId, CategoryId)
);
GO

/* =======================================================================
	Table: Results
	One result per enrolment (1:1).
========================================================================== */
CREATE TABLE dbo.Results (
	ResultId        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	EnrolmentId     INT               NOT NULL UNIQUE,
	FinishTime      TIME              NULL,
	Position        INT               NULL,
	Status          VARCHAR(20)       NOT NULL DEFAULT 'Not Started',
	CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentId)
		REFERENCES dbo.Enrolments(EnrolmentId) ON DELETE CASCADE,
		114     );
    GO
     
     /* =========================================================
         Table: Payments
         One payment record per enrolment (1:1).
     ============================================================ */    
     CREATE TABLE dbo.Payments (
       PaymentId       INT IDENTITY(1,1)   NOT NULL PRIMARY KEY,         
       EnrolmentId     INT                 NOT NULL UNIQUE         
       Amount          DECIMAL(10,2)       NOT NULL,
       PaymentDate     DATETIME            NULL,
       PaymentStatus   VARCHAR(20)         NOT NULL DEFAULT 'Unpaid',
        CONSTRAINT FK_Payments_Enrolment FOREIGN KEY (EnrolmentId)
             REFERENCES dbo.Enrolments(EnrolmentId) ON DELETE CASCADE,
        CONSTRAINT CK_Payments_Status CHECK (PaymentStatus IN ('Unpaid', 'Paid', 'Refunded'))
     );
     GO
     3     /* =========================================================
         SEED DATA
          ============================================================ */
     
     -- Organisers (2)
     INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, PhoneNumber)
     VALUES
         ('Thandeka Nkosi', 'thandeka.nkosi@raceday.co.za', 'HASHED_PASSWORD_1', 'Organiser', '0821234567'),
         ('Johan van der Merwe', 'johan.vdm@raceday.co.za', 'HASHED_PASSWORD_2', 'Organiser', '0837654321');
         
     -- Participants (2)
     INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, PhoneNumber)
     VALUES
        ('Malusi Mathonsi', 'malusi.mathonsi@example.com', 'HASHED_PASSWORD_3', 'Participant', '0731112222'),
         ('Aisha Patel', 'aisha.patel@example.com', 'HASHED_PASSWORD_4', 'Participant', '0743334444');
        
     -- Events (3)
     INSERT INTO dbo.Events (OrganiserId, Name, Description, EventDate, Location, Status)
     VALUES
         (1, 'Durban Beachfront Marathon', 'Annual marathon along the Durban beachfront promenade.', '2026-10-18', 'Durban, KZN', 'Open'),
        (1, 'Umhlanga Fun Run', 'Family-friendly fun run in support of local charities.', '2026-11-01', 'Umhlanga, KZN', 'Planned'),
         (2, 'Joburg City Trail Run', 'Off-road trail run through Johannesburg green belts.', '2026-09-20', 'Johannesburg, GP', 'Open');
        
     -- Categories (at least one per event)
     INSERT INTO dbo.Categories (EventId, Name, DistanceKm, MaxParticipants, Fee, StartTime)
     VALUES
         (1, '10km', 10.00, 500, 150.00, '06:00:00'),
         (1, 'Half Marathon (21km)', 21.10, 300, 250.00, '05:30:00'),
         (2, '5km Fun Run', 5.00, 1000, 80.00, '08:00:00'),
         (3, '15km Trail', 15.00, 200, 180.00, '07:00:00');
         
     -- Enrolments (participants enrol in categories)
     INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, Status)
     VALUES
      (3, 1, 'Confirmed'),   -- Malusi in Durban 10km
       (3, 3, 'Pending'),     -- Malusi in Umhlanga 5km
       (4, 2, 'Confirmed'),   -- Aisha in Durban Half Marathon
       (4, 4, 'Confirmed');   -- Aisha in Joburg 15km Trail
   
   -- Results (only for confirmed / completed enrolments)
   INSERT INTO dbo.Results (EnrolmentId, FinishTime, Position, Status)
   VALUES
       (1, '00:52:14', 12, 'Finished'),
      (3, '01:58:47', 5, 'Finished');
   
   -- Payments (one per enrolment)
   INSERT INTO dbo.Payments (EnrolmentId, Amount, PaymentDate, PaymentStatus)
   VALUES
       (1, 150.00, '2026-08-01 10:15:00', 'Paid'),
      (2, 80.00, NULL, 'Unpaid'),
       (3, 250.00, '2026-08-05 14:22:00', 'Paid'),
      (4, 180.00, '2026-08-10 09:05:00', 'Paid');
   GO
   
   /* =========================================================================
       Quick verification queries 
      ========================================================================= */
   SELECT * FROM dbo.Users;
   SELECT * FROM dbo.Events;
 SELECT * FROM dbo.Categories;
   SELECT * FROM dbo.Enrolments;
  SELECT * FROM dbo.Results;
   SELECT * FROM dbo.Payments;