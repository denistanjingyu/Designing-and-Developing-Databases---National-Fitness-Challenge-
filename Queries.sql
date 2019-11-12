									/* SQL Queries (Part I) */
-- Q1.Generate a list of male users who are >= 21 years old
SELECT *
FROM user
WHERE Gender = 'M' and Age >= 21
ORDER BY UserID;


-- Q2. Generate a list of male users who are following more female users than male users
                     
-- (i) Get all users who follow AT LEAST ONE FEMALE user 
CREATE VIEW followFemaleIntermediate AS
SELECT FollowerID, COUNT(FollowedID) AS followingNumberOfFemales
FROM followship
WHERE FollowedID IN (SELECT UserID 
					 FROM User
					 WHERE Gender = 'F')
GROUP BY FollowerID
ORDER BY FollowerID;

-- (ii) Perform a UNION to include users who DO NOT FOLLOW any FEMALE users at all
CREATE VIEW followFemale AS
SELECT *
FROM followFemaleIntermediate
UNION
SELECT UserID, 0 AS followingNumberOfFemales
FROM user
WHERE UserID NOT IN (SELECT FollowerID
					 FROM followFemaleIntermediate)
ORDER BY FollowerID;

-- (iii) Check our final view created 
SELECT *
FROM followFemale;
                 
-- (i) Get all users who follow AT LEAST ONE MALE user
CREATE VIEW followMaleIntermediate AS
SELECT FollowerID, COUNT(FollowedID) AS followingNumberOfMales
FROM followship
WHERE FollowedID IN (SELECT UserID 
					 FROM User
					 WHERE Gender = 'M')
GROUP BY FollowerID
ORDER BY FollowerID;

-- (ii) Perform a UNION to include users who DO NOT FOLLOW any MALE users at all
CREATE VIEW followMale AS
SELECT *
FROM followMaleIntermediate
UNION
SELECT UserID, 0 AS followingNumberOfMales
FROM User
WHERE UserID NOT IN (SELECT FollowerID
					 FROM followMaleIntermediate)
ORDER BY FollowerID;

-- (iii) Check our final view created 
SELECT *
FROM followMale;

-- Next, perform an inner join on both views to obtain our final view
CREATE VIEW followingGenderSplit AS
SELECT mff.FollowerID, mff.followingNumberOfFemales, mfm.followingNumberOfMales
FROM followFemale AS mff
INNER JOIN followMale AS mfm
ON mff.FollowerID = mfm.FollowerID;

-- (iii) Check our final view
SELECT *
FROM followingGenderSplit;

-- Lastly, query for all the relevant rows in followingGenderSplit 
SELECT *
FROM user
WHERE UserID IN (SELECT FollowerID
				 FROM followingGenderSplit
				 WHERE followingNumberOfFemales > followingNumberOfMales) -- Following more female users than male users
AND Gender = 'M'; 														  -- Select all male users 


-- Q3. Generate a list of female users who are followed by only male users

-- (i) Get all users who have AT LEAST ONE FEMALE follower
CREATE VIEW followerFemaleIntermediate AS
SELECT FollowedID, COUNT(FollowerID) AS numberOfFemaleFollowers
FROM followship
WHERE FollowerID IN (SELECT UserID 
					 FROM User
					 WHERE Gender = 'F')
GROUP BY FollowedID
ORDER BY FollowedID;

-- (ii) Perform a UNION to include users who have NO FEMALE FOLLOWERS at all
CREATE VIEW followerFemale AS
SELECT *
FROM followerFemaleIntermediate
UNION
SELECT UserID, 0 AS numberOfFemaleFollowers
FROM user
WHERE UserID NOT IN (SELECT FollowedID
					 FROM followerFemaleIntermediate)
ORDER BY FollowedID;

-- (iii) Check our final view created 
SELECT *
FROM followerFemale;
                 
-- (i) Get all users who have AT LEAST ONE MALE follower
CREATE VIEW followerMaleIntermediate AS
SELECT FollowedID, COUNT(FollowerID) AS numberOfMaleFollowers
FROM followship
WHERE FollowerID IN (SELECT UserID 
					 FROM User
					 WHERE Gender = 'M')
GROUP BY FollowedID
ORDER BY FollowedID;

-- (ii) Perform a UNION to include users who have NO MALE FOLLOWERS at all
CREATE VIEW followerMale AS
SELECT *
FROM followerMaleIntermediate
UNION
SELECT UserID, 0 AS numberOfMaleFollowers
FROM user
WHERE UserID NOT IN (SELECT FollowedID
					 FROM followerMaleIntermediate)
ORDER BY FollowedID;

-- (iii) Check our final view created 
SELECT *
FROM followerMale;

-- Next, perform an inner join on both views to obtain our final view
CREATE VIEW followersGenderSplit AS
SELECT ff.FollowedID, ff.numberOfFemaleFollowers, fm.numberOfMaleFollowers
FROM followerFemale AS ff
INNER JOIN followerMale AS fm
ON ff.FollowedID = fm.FollowedID;

-- (iii) Check our final view
SELECT *
FROM followersGenderSplit;

-- Lastly, query for all the relevant rows in followersGenderSplit 
SELECT *
FROM user
WHERE UserID IN (SELECT FollowedID
				 FROM followersGenderSplit
				 WHERE numberOfMaleFollowers > 0  -- Has at least 1 male follower
                 AND numberOfFemaleFollowers = 0) -- Has no female followers at all
AND Gender = 'F';                                 -- To select all female users


-- Q4. Generate a list of users who are following each other mutually.
SELECT f1.FollowedID, f1.FollowerID
FROM followship AS f1, followship AS f2
WHERE f1.followerID = f2.followedID AND f1.followedID = f2.followerID
ORDER BY f1.FollowedID;


/*
Q5. Generate activeness insight, i.e., a list of users who have exercised 
Q6. Based on the above (activeness insight), generate age-based activeness insight 
Q7. Enrich the above (age-based activeness insight) with genders (i.e., provides age-based activeness insight for each gender)
*/

-- Step 1 : We first create a view, ExerciseStrata, as defined below
CREATE VIEW ExerciseStrata AS
SELECT user.UserID,
	   ROUND(DATEDIFF(CURDATE(), user.UserJoinDate) / 7) AS WeeksJoined,
	   SUM(ActivityDuration) / (DATEDIFF(CURDATE(), user.UserJoinDate) / 7) AS WeeklyExerciseDuration,
	   CASE 
		   WHEN SUM(ActivityDuration) / (DATEDIFF(CURDATE(), user.UserJoinDate) / 7) < 30 THEN "<30"
		   WHEN SUM(ActivityDuration) / (DATEDIFF(CURDATE(), user.UserJoinDate) / 7) >= 30 AND SUM(ActivityDuration) / (DATEDIFF(CURDATE(), user.UserJoinDate) / 7) < 60 THEN "30 - 60"
		   WHEN SUM(ActivityDuration) / (DATEDIFF(CURDATE(), user.UserJoinDate) / 7) >= 60 AND SUM(ActivityDuration) / (DATEDIFF(CURDATE(), user.UserJoinDate) / 7) <= 120 THEN "60 - 120"
		   ELSE ">120" END AS WeeklyExerciseDurationClass,
       user.Age,
	   CASE 
		   WHEN user.Age < 21 THEN "<21"
		   WHEN user.Age >= 21 AND user.Age < 35 THEN "21 - 35"
		   WHEN user.Age >= 35 AND user.Age <= 50 THEN "35 - 50"
		   ELSE ">50" END AS AgeRange,
	   user.Gender
FROM activity
INNER JOIN user 
ON activity.UserID = user.UserID
GROUP BY user.UserID, user.Age, user.Gender
ORDER BY UserID;


SELECT WeeklyExerciseDurationClass, AgeRange, Gender, UserID
FROM exercisestrata
ORDER BY WeeklyExerciseDurationClass,
		 /* Due to inconsistency in string comparison, we used a custom key comparator for AgeRange */
		 CASE 
			 WHEN AgeRange = "<21" THEN '1'
             WHEN AgeRange = "21-35" THEN '2'
             WHEN AgeRange = "35-50" THEN '3'
             WHEN AgeRange = ">50" THEN '4'
             ELSE AgeRange END ASC, 
		 Gender;




-- Step 2 : Get a summary count of the number of users falling into each category
SELECT WeeklyExerciseDurationClass AS `Weekly Exercise Duration (in minutes)`, AgeRange AS `Age`, Gender, COUNT(UserID) AS `Number of Users`
FROM ExerciseStrata
GROUP BY WeeklyExerciseDurationClass, AgeRange, Gender
ORDER BY WeeklyExerciseDurationClass, 
		/* Due to inconsistency in string comparison, we used a custom key comparator for AgeRange */
		 CASE 
			 WHEN AgeRange = "<21" THEN '1'
             WHEN AgeRange = "21-35" THEN '2'
             WHEN AgeRange = "35-50" THEN '3'
             WHEN AgeRange = ">50" THEN '4'
             ELSE AgeRange END ASC,            
		 Gender DESC; 

/*
Step 3 : Retrieve actual user details of users in specific categories

As there're 4 * 4 * 2 = 32 possible combinations of user categories, we shall only demonstrate 2 example tables.
    
Example 1 : Find a list of users who :
			 (i) Exercise > 60 minutes every week
             (ii) Are older than 50 years old
   			 (iii) Are female
                 
Example 2 : Find a list of users who :
			(i) Exercise < 30 minutes every week
			(ii) Are younger than 21 years old
     		(iii) Are male
*/

-- Solution to Example 1
SELECT *
FROM user
WHERE UserID IN (SELECT UserID 
				 FROM ExerciseStrata
				 WHERE AgeRange = '>50' AND Gender = 'F' AND (WeeklyExerciseDurationClass = '60 - 120' OR 
															  WeeklyExerciseDurationClass = '>120'));
                 
-- Solution to Example 2
SELECT *
FROM user
WHERE UserID IN (SELECT UserID 
				 FROM ExerciseStrata
				 WHERE AgeRange = '<21' AND Gender = 'M' AND WeeklyExerciseDurationClass = '<30');


-- Q8. Generate a list of users who have received > 5 Kudos in average for each activity

-- Create a view for the total Kudos received by each user
CREATE VIEW ActivityKudoView AS
SELECT a.UserID AS `UserID`, COUNT(k.UserID) AS `Total Kudos Received`
FROM kudo AS k
INNER JOIN activity AS a
ON k.ActivityID = a.ActivityID
GROUP BY a.UserID
ORDER BY a.UserID;

/*
Note : We can safely ignore the users who have not received ANY Kudos at all from any of their activities, simply 
because this Q8 focuses only users who have obtained >5 Kudos, and omitting the aforementioned users from this
query will have no effect on its validity.
*/

-- Create a view for the total activities done by each user
CREATE VIEW UserNumActivities AS
SELECT UserID, COUNT(ActivityID) AS NumberOfActivities
FROM activity
GROUP BY UserID
ORDER BY UserID;

-- Merge the 2 views
SELECT a.UserID, `Total Kudos Received`, NumberOfActivities AS `Number of Activities`, `Total Kudos Received` / NumberOfActivities AS `Average Kudos received per activity`
FROM ActivityKudoView AS a
INNER JOIN UserNumActivities AS u
ON a.UserID = u.UserID
WHERE `Total Kudos Received` / NumberOfActivities > 5;


/*
 Q9. Compute monthly active social networks, i.e., for each user,
 list out his/her followers, who have given him/her >=5 Kudos for
 each month’s activities.
 */
 SELECT a.UserID AS `UserID`,
		k.UserID AS `FollowerID`,
        MONTHNAME(ActivityDate) AS `Activity Month`,
        COUNT(a.ActivityID) AS `Total Monthly Kudos given`
 FROM activity AS a
 INNER JOIN kudo AS k
 ON a.ActivityID = k.ActivityID
 GROUP BY `UserID`, `FollowerID`, `Activity Month`
 ORDER BY a.UserID;
 
 
 /*
 Q10. Conduct social comparison analysis, i.e., for each user,
 list out his or her weekly average activity distance and weekly
 average activity duration. Additionally, compute the weekly 
 averages for his social networks (i.e., followed by the user)
 */

-- Step 1 : Create a view of all users and their Weekly Averages of Activity Distance and Duration
CREATE VIEW UserDistanceDuration AS
SELECT a.UserID,
	   ROUND(SUM(ActivityDistance) / (DATEDIFF(CURDATE(), u.UserJoinDate) / 7), 2) AS `Weekly Average Activity Distance (KM)`,
	   ROUND(SUM(ActivityDuration) / (DATEDIFF(CURDATE(), u.UserJoinDate) / 7), 2) AS `Weekly Average Activity Duration (MIN)`
FROM activity AS a
INNER JOIN user AS u
ON a.UserID = u.UserID
GROUP BY a.UserID
UNION
SELECT u.UserID, 0 AS `Weekly Average Activity Distance (KM)`, 0 AS `Weekly Average Activity Duration (MIN)`
FROM user AS u
WHERE UserID NOT IN (SELECT UserID 
					 FROM activity)
GROUP BY u.UserID
ORDER BY UserID;

-- Step 2 : Create a view of the Kudo table, but update it to reflect users who DO NOT FOLLOW anybody
CREATE VIEW KudoUpdated AS
SELECT FollowedID, FollowerID
FROM followship
UNION 
SELECT null AS FollowedID, UserID AS FollowerID
FROM user
WHERE UserID NOT IN (SELECT FollowerID FROM followship);

-- Step 2 : We get a temporary social network view showing each user and who he follows
CREATE VIEW SocialNetworkTemp AS 
SELECT UserID, `Weekly Average Activity Distance (KM)`, `Weekly Average Activity Duration (MIN)`, `FollowedID`
FROM UserDistanceDuration AS UDD
INNER JOIN KudoUpdated AS K
ON UDD.UserID = K.FollowerID
ORDER BY UserID;

-- Step 3 : Join SocialNetworkTemp with UserDistanceDuration again to get the following's activity statistics
SELECT S.UserID,
	   S.`Weekly Average Activity Distance (KM)`,
       S.`Weekly Average Activity Duration (MIN)`, 
	   FollowedID,
       U.`Weekly Average Activity Duration (MIN)` AS `Following's Weekly Average Activity Duration (MIN)`,
       U.`Weekly Average Activity Distance (KM)` AS `Following's Weekly Average Activity Distance (KM)`
FROM SocialNetworkTemp AS S
INNER JOIN UserDistanceDuration AS U
ON S.FollowedID = U.UserID
ORDER BY UserID, FollowedID;

							   /* End of SQL Queries (Part 1) */