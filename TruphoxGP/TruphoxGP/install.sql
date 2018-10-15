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

CREATE TABLE tbNotification
(
	notificationID INT IDENTITY (0,1) PRIMARY KEY,
	notificationText VARCHAR(100),
	notificationDate DATETIME,
	username VARCHAR(30) FOREIGN KEY REFERENCES tbAccount(username)
)

CREATE TABLE tbPost
(
	postID INT IDENTITY(0,1) PRIMARY KEY,
	rating INT,
	postText VARCHAR(800),
	postDate DATETIME,
	lastComment INT,
	username VARCHAR(30)
)

CREATE TABLE tbComment
(
	commentID INT IDENTITY (0,1) PRIMARY KEY,
	postID INT FOREIGN KEY REFERENCES tbPost(postID),
	postCommentNumber INT,
	commentText VARCHAR(100),
	commentDate DATETIME,
	username VARCHAR(30)
)

CREATE TABLE tbLike
(
	likeID INT IDENTITY (0,1) PRIMARY KEY,
	postID INT FOREIGN KEY REFERENCES tbPost(postID),
	username VARCHAR(30) FOREIGN KEY REFERENCES tbAccount(username)
)

CREATE TABLE tbTagName
(
	tagID INT IDENTITY (0,1) PRIMARY KEY,
	tagName VARCHAR(30)
)

CREATE TABLE tbPostTag
(
	postTagID INT IDENTITY (0,1) PRIMARY KEY,
	postID INT FOREIGN KEY REFERENCES tbPost(postID),
	tagID INT FOREIGN KEY REFERENCES tbTagName(tagID)
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

--CREATE TABLE tbSale
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
	@profileImage VARCHAR(150) = null,
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

CREATE PROCEDURE spCreateFollow
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

CREATE PROCEDURE spCreateBlock
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

CREATE PROCEDURE spReadBlock
(
	@username VARCHAR(30) = null,
	@blockedUser VARCHAR(30)
)
AS
BEGIN
	IF (@username IS NOT NULL and @blockedUser IS NULL)
		BEGIN
			SELECT * FROM tbBlocked WHERE username = @username
		END
	ELSE IF (@blockedUser IS NOT NULL and @username IS NULL)
		BEGIN
			SELECT * FROM tbBlocked WHERE blockedUser = @blockedUser
		END
	ELSE
		BEGIN
			SELECT 'Must provide only username or blockedUser' as MESSAGE
		END
END
GO

-------------------------------- Notification --------------------------------

CREATE PROCEDURE spCreateNotification
(
	@notificationText VARCHAR(100),
	@notificationDate DATETIME,
	@username VARCHAR(30)
)
AS
BEGIN
	INSERT INTO tbNotifications (notificationText, notificationDate, username) VALUES (@notificationText, GETDATE(), @username)
END
GO

CREATE PROCEDURE spReadNotification
(
	@username VARCHAR(30)
)
AS
BEGIN
	SELECT * FROM tbNotification WHERE username = ISNULL (@username, username)
END
GO

CREATE PROCEDURE spUpdateNotification
(
	@notificationID INT,
	@notificationText VARCHAR(100),
	@notificationDate DATETIME,
	@username VARCHAR(30)
)
AS
BEGIN
	UPDATE tbNotification SET
	notificationText = @notificationText,
	notificationDate = @notificationDate,
	username = @username
	WHERE notificationID = @notificationID
END
GO

CREATE PROCEDURE spDeleteNotification
(
	@notificationID INT
)
AS
BEGIN
	DELETE FROM tbNotification WHERE notificationID = @notificationID
END
GO

-------------------------------- POST --------------------------------

CREATE PROCEDURE spCreatePost
(
	@rating INT,
	@postText VARCHAR(800),
	@postDate DATETIME,
	@lastComment INT,
	@username VARCHAR(30)
)
AS
BEGIN
	INSERT INTO tbPost (rating, postText, postDate, lastComment, username) VALUES
					(@rating, @postText, GETDATE(), @lastComment, @username)
END
GO

CREATE PROCEDURE spReadPost
(
	@postID INT
)
AS
BEGIN
	SELECT * FROM tbPost WHERE postID = ISNULL (@postID, postID)
END
GO

CREATE PROCEDURE spUpdatePost
(
	@postID INT,
	@rating INT,
	@postText VARCHAR(200),
	@postDate DATETIME,
	@lastComment INT,
	@username VARCHAR(30)
)
AS
BEGIN
	UPDATE tbPost SET
	rating = @rating,
	postText = @postText,
	postDate = @postDate,
	lastComment = @lastComment,
	username = @username
	WHERE postID = @postID
END
GO

CREATE PROCEDURE spDeletePost
(
	@postID INT
)
AS
BEGIN
	DELETE FROM tbPost WHERE postID = @postID
END
GO

-------------------------------- COMMENT --------------------------------

CREATE PROCEDURE spCreateComment
(
	@postID INT,
	@postCommentNumber INT,
	@commentText VARCHAR(100),
	@commentDate DATETIME,
	@username VARCHAR(30)
)
AS
BEGIN
	INSERT INTO tbComment (postID, postCommentNumber, commentText, commentDate, username) VALUES
						(@postID, @postCommentNumber, @commentText, GETDATE(), @username)
END
GO

CREATE PROCEDURE spReadComment
(
	@postID INT
)
AS
BEGIN
	SELECT * FROM tbComment WHERE postID = ISNULL (@postID, postID)
END
GO

CREATE PROCEDURE spUpdateComment
(
	@commentID INT,	
	@commentText VARCHAR(100)	
)
AS
BEGIN
	UPDATE tbComment SET
	commentText = @commentText
	WHERE commentID = @commentID
END
GO

CREATE PROCEDURE spDeleteComment
(
	@commentID INT
)	
AS
BEGIN
	DELETE FROM tbComment WHERE commentID = @commentID
END
GO

-------------------------------- LIKE --------------------------------

CREATE PROCEDURE spCreateLike
(
	@postID INT,
	@username VARCHAR(30)
)
AS
BEGIN
	IF EXISTS (SELECT * FROM tbLike WHERE username = @username and postID = @postID)
				BEGIN
					DELETE FROM tbLike WHERE username = @username and postID = @postID
				END
			ELSE
				BEGIN				
					INSERT INTO tbLike (postID, username) VALUES
									(@postID, @username)
				END
END
GO

CREATE PROCEDURE spReadLike
(
	@postID INT
)
AS
BEGIN
	SELECT * FROM tbLike WHERE postID = ISNULL (@postID, postID)
END
GO


-------------------------------- TAGS --------------------------------

CREATE PROCEDURE spCreateTag
(
	@tagName VARCHAR(30)
)
AS
BEGIN
		IF EXISTS (SELECT * FROM tbTagName WHERE tagName = @tagName)
			BEGIN
				SELECT 'Tag Already Exists' AS MESSAGE
			END
		ELSE
			BEGIN				
				INSERT INTO tbTagName(tagName) VALUES
									(@tagName)
			END	
END
GO

CREATE PROCEDURE spReadTag
(
	@tagID INT
)
AS
BEGIN
	SELECT * FROM tbTagName WHERE tagID = ISNULL (@tagID, tagID)
END
GO

CREATE PROCEDURE spDeleteTag
(
	@tagID INT
)
AS
BEGIN
	DELETE FROM tbTagName WHERE tagID = @tagID
END
GO

-------------------------------- POST TAGS --------------------------------

CREATE PROCEDURE spCreatePostTag
(
	@postID INT,
	@tagName VARCHAR(30),
	@tagID INT
)
AS
BEGIN
	IF EXISTS (SELECT * FROM tbTagName WHERE tagName = @tagName)
		BEGIN
			INSERT INTO tbPostTag (postID, tagID) VALUES
								(@postID, @tagID)
		END
	ELSE
		BEGIN				
			INSERT INTO tbTagName(tagName) VALUES
								(@tagName)
			INSERT INTO tbPostTag (postID, tagID) VALUES
								(@postID, @@IDENTITY)
		END	
END
GO

CREATE PROCEDURE spReadPostTag
(
	@postTagID INT
)
AS
BEGIN
	SELECT * FROM tbPostTag WHERE postTagID = ISNULL (@postTagID, postTagID)
END
GO

CREATE PROCEDURE spDeletePostTag
(
	@postTagID INT
)
AS
BEGIN
	DELETE FROM tbPostTag WHERE postTagID = @postTagID
END
GO

-------------------------------- WRITING --------------------------------




	--writingID INT IDENTITY (0,1) PRIMARY KEY,
	--writingText VARCHAR(3000),
	--writingTitle VARCHAR(100),
	--writingSubTitle VARCHAR(100)
	

-------------------------------- USERS CREATED --------------------------------

EXEC spCreateAccount @username='wrenjay', @userPassword='admin', @email='wrenjaymes@gmail.com', @firstName='Wren', @lastName='Jaymes', @dob='1997-07-08', @profileImage='', @active='1', @accessLevel='0'
EXEC spCreateAccount @username='CanadaGhost', @userPassword='admin', @email='dancourcelles7@gmail.com', @firstName='', @lastName='', @dob='1990-09-07', @profileImage='', @active='1', @accessLevel='0'
EXEC spCreateAccount @username='TruPhox', @userPassword='admin', @email='truphox@gmail.com', @firstName='TruPhox', @lastName='Admin', @dob='', @profileImage='', @active='1', @accessLevel='0'
EXEC spCreateAccount @username='GigglesMcPhee', @userPassword='password', @email='', @firstName='Alex', @lastName='Chartier', @dob='', @profileImage='', @active='1', @accessLevel='1'
EXEC spCreateAccount @username='Stranger', @userPassword='password', @email='email@gmail.com', @firstName='Person', @lastName='PersonLast', @dob='1999-11-28', @profileImage='', @active='1', @accessLevel='1'
EXEC spCreateAccount @username='Person', @userPassword='password', @email='email2@gmail.com', @firstName='Person', @lastName='Person', @dob='1989-01-24', @profileImage='', @active='1', @accessLevel='1'

SELECT * FROM tbAccount
GO

---------------------POSTS CREATED (WRITTING) -------------------

EXEC spCreatePost @rating=0, @postText='IT HAS FINIALLY ARIVVED! This is the offical launch of TruPhox, the website built  for even the most novice of artists, videographers and poets. Post your creavity, like and share other ones and join the community that will accept you where ever you are.', @postDate='2018-10-18', @lastComment=0, @username='TruPhox'
EXEC spCreatePost @rating=0, @postText='Two things are infinite: the universe and human stupidity; and I''m not sure about the universe ― Albert Einstein', @postDate='', @lastComment='', @username='wrenjay'
EXEC spCreatePost @rating=0, @postText='To love at all is to be vulnerable. Love anything and your heart will be wrung and possibly broken. If you want to make sure of keeping it intact you must give it to no one, not even an animal. Wrap it carefully round with hobbies and little luxuries; avoid all entanglements. Lock it up safe in the casket or coffin of your selfishness. But in that casket, safe, dark, motionless, airless, it will change. It will not be broken; it will become unbreakable, impenetrable, irredeemable. To love is to be vulnerable ― C.S. Lewis, The Four Loves', @postDate='', @lastComment=3, @username='wrenjay'
EXEC spCreatePost @rating=0, @postText='I''M TINY RICK!!', @postDate='', @lastComment=3, @username='CanadaGhost'
EXEC spCreatePost @rating=0, @postText='I have decied that if I spent my whole life believing I am something, I will amount to nothing. But if I believe I am nothing I will amount to nothing. Either way you cannot win...', @postDate='', @lastComment=3, @username='Person'
EXEC spCreatePost @rating=0, @postText='Nobody exists on purpose. Nobody belongs anywhere. We''re all going to die. Come watch TV.', @postDate='', @lastComment=3, @username='Person'

------------------POSTS CREATED (ART) -------------------

EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''

------------------POSTS CREATED (VIDEO) -------------------

EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''

------------------POSTS CREATED (PHOTOGRAPHY) -------------------

EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''
EXEC spCreatePost @rating=0, @postText='', @postDate='', @lastComment=3, @username=''

SELECT * FROM tbPost