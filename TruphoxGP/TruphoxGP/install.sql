﻿USE MASTER
GO
DROP DATABASE dbTruphox
GO
CREATE DATABASE dbTruphox
GO
USE dbTruphox
GO

-------------------------------- TABLES --------------------------------

CREATE TABLE tbAccount
(
	username VARCHAR(30) PRIMARY KEY,
	userPassword VARCHAR(30),
	email VARCHAR(70),
	firstName VARCHAR(40),
	lastName VARCHAR (40),
	dob DATETIME,
	profileImage VARCHAR(150),
	active BIT,
	accessLevel INT
)

CREATE TABLE tbFollowing
(
	followID INT IDENTITY (0,1) PRIMARY KEY,
	username VARCHAR(30) FOREIGN KEY REFERENCES tbAccount(username),
	followedUser VARCHAR(30) FOREIGN KEY REFERENCES tbAccount(username)
)

CREATE TABLE tbBlocked
(
	blockID INT IDENTITY (0,1) PRIMARY KEY,
	username VARCHAR(30) FOREIGN KEY REFERENCES tbAccount(username),
	blockedUser VARCHAR(30) FOREIGN KEY REFERENCES tbAccount(username),
	blockDate DATETIME
)

CREATE TABLE tbNotifications
(
	notificationID INT IDENTITY (0,1) PRIMARY KEY,
	notificationText VARCHAR(100),
	notificationDate DATETIME
)

CREATE TABLE tbPost
(
	postID INT IDENTITY(0,1) PRIMARY KEY,
	rating INT,
	postText VARCHAR(200),
	postDate DATETIME,
	lastComment INT
)

CREATE TABLE tbComments
(
	commentID INT IDENTITY (0,1) PRIMARY KEY,
	postID INT FOREIGN KEY REFERENCES tbPost(postID),
	postCommentNumber INT,
	commentText VARCHAR(100),
	commentDate DATETIME
)

CREATE TABLE tbLike
(
	likeID INT IDENTITY (0,1) PRIMARY KEY,
	postID INT FOREIGN KEY REFERENCES tbPost(postID),
	username VARCHAR(30) FOREIGN KEY REFERENCES tbAccount(username)
)

CREATE TABLE tbTagNames
(
	tagID INT IDENTITY (0,1) PRIMARY KEY,
	tagName VARCHAR(30)
)

CREATE TABLE tbPostTag
(
	postTagID INT IDENTITY (0,1) PRIMARY KEY,
	postID INT FOREIGN KEY REFERENCES tbPost(postID),
	tagID INT FOREIGN KEY REFERENCES tbTagNames(tagID)
)

CREATE TABLE tbWriting
(
	writingID INT IDENTITY (0,1) PRIMARY KEY,
	writingText VARCHAR(3000),
	writingTitle VARCHAR(100),
	writingSubTitle VARCHAR(100)
)

CREATE TABLE tbArt
(
	artID INT IDENTITY (0,1) PRIMARY KEY,
	artLink VARCHAR(150),
	artTitle VARCHAR(100),
	artSubtitle VARCHAR(100)
)

CREATE TABLE tbPhotography
(
	photoID INT IDENTITY (0,1) PRIMARY KEY,
	photoLink VARCHAR(150),
	photoTitle VARCHAR(100),
	photoSubtitle VARCHAR(100)
)

CREATE TABLE tbVideo
(
	videoID INT IDENTITY (0,1) PRIMARY KEY,
	videoLink VARCHAR(150),
	videoTitle VARCHAR(100),
	videoSubtitle VARCHAR(100)
)

--CREATE TABLE tbSales
--(
--	saleID INT IDENTITY (0,1) PRIMARY KEY,
--	saleStatus VARCHAR(30)

--)

--CREATE TABLE tbType
--(
--	typeID INT IDENTITY (0,1) PRIMARY KEY,
--	typeName VARCHAR(30)
--)

--CREATE TABLE tbItem
--(
--	itemID INT IDENTITY (0,1) PRIMARY KEY,
--	typeID INT FOREIGN KEY REFERENCES tbType(typeID),
--	itemName VARCHAR(40)
--)

GO
-------------------------------- PROCEDURES --------------------------------

-------------------------------- ACCOUNTS --------------------------------

CREATE PROCEDURE spCreateAccount
(
	@username VARCHAR(30),
	@userPassword VARCHAR(30),
	@email VARCHAR(70),
	@firstName VARCHAR(40),
	@lastName VARCHAR (40),
	@dob DATETIME,
	@profileImage VARCHAR(150),
	@active BIT = 1,
	@accessLevel INT = 1
)
AS
BEGIN
	IF EXISTS (SELECT * FROM tbAccount WHERE username = @username)
		BEGIN
			SELECT 'User already exists' as MESSAGE
		END
	ELSE
		BEGIN
			INSERT INTO tbAccount (username, userPassword, email, firstName, lastName, dob, profileImage, active, accessLevel) VALUES
						(@username, @userPassword, @email, @firstName, @lastName, @dob, @profileImage, @active, @accessLevel)
		END
END
GO

CREATE PROCEDURE spReadAccount
(
	@username VARCHAR(30)
)
AS
BEGIN
	SELECT * FROM tbAccount WHERE username = ISNULL (@username, username)
END
GO

CREATE PROCEDURE spUpdateAccount
(
	@username VARCHAR(30),
	@userPassword VARCHAR(30),
	@dob DATETIME,
	@profileImage VARCHAR(150),
	@active BIT
)
AS
BEGIN
	UPDATE tbAccount SET
	username = @username,
	userPassword = @userPassword,
	dob = @dob,
	profileImage = @profileImage,
	active = @active
	WHERE username = @username
END
GO

CREATE PROCEDURE spDisableAccount
(
	@username VARCHAR(30)
)
AS
BEGIN
	UPDATE tbAccount SET
	active = 0
	WHERE username = @username
END
GO

-------------------------------- FOLLOWING --------------------------------

CREATE PROCEDURE spFollow
(
	@username VARCHAR(30),
	@followedUser VARCHAR(30)
)
AS
BEGIN
	IF EXISTS (SELECT * FROM tbBlocked WHERE username = @username AND blockedUser = @followedUser OR username = @followedUser AND blockedUser = @username)
		BEGIN
			SELECT 'User cannot be followed' AS MESSAGE
		END
	ELSE
		BEGIN
			IF EXISTS (SELECT * FROM tbFollowing WHERE username = @username and followedUser = @followedUser)
				BEGIN
					DELETE FROM tbFollowing WHERE username = @username and followedUser = @followedUser
				END
			ELSE
				BEGIN
					INSERT INTO tbFollowing (username, followedUser) VALUES
											(@username, @followedUser)
				END
		END
END
GO

CREATE PROCEDURE spReadFollow
(
	@username VARCHAR(30) = null,
	@followedUser VARCHAR(30) = null
)
AS
BEGIN
	IF (@username IS NOT NULL and @followedUser IS NULL)
		BEGIN
			SELECT * FROM tbFollowing WHERE username = @username
		END
	ELSE IF (@followedUser IS NOT NULL and @username IS NULL)
		BEGIN
			SELECT * FROM tbFollowing WHERE followedUser = @followedUser
		END
	ELSE
		BEGIN
			SELECT 'Must provide only username or followedUser' as MESSAGE
		END
END
GO	

-------------------------------- BLOCKED --------------------------------

CREATE PROCEDURE spBlock
(
	@username VARCHAR(30),
	@blockedUser VARCHAR(30),
	@blockDate DATETIME = null
)
AS
BEGIN
	IF EXISTS (SELECT * FROM tbBlocked WHERE username = @username and blockedUser = @blockedUser)
		BEGIN
			DELETE FROM tbBlocked WHERE username = @username and blockedUser = @blockedUser
		END
	ELSE
		BEGIN
			INSERT INTO tbBlocked(username, blockedUser, blockDate) VALUES
						(@username, @blockedUser, GETDATE())
		END
END
GO
