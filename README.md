# Designing and Developing Databases - National Fitness Challenge
## Problem Statement
The Ministry of Healthy Lifestyle (MHL) has tasked your team to design and develop a database solution to store information about their national fitness challenge, which is facilitated through the mobile app “Fitness 365”. The Ministry hopes that the database will improve their ability to understand citizens’ (about 5 million citizens) activeness and lifestyle. Since MHL will be promoting the app with incentivized campaigns, citizens are expected to use the app frequently for a prolonged period (i.e., 1 year). App usage is expected to be highly intensive during weekends and weekday evenings, while usage is expected to be sparse during daytime in weekdays.

The Ministry’s requirements include:

(1)	User login

(2)	User profile

(3)	Tracking of user running/ jogging activities

(4)	Twitter-style social media (i.e., a user is following someone and/or a user is being followed by someone)

(5)	Posting of tracked activities with (optional) comments and photos

(6)	Giving Kudos and comments on posting

(7)	Running clubs 

(8)	Weekly leaderboard

(9)	Personal best


## A.1 Relational database implementation

# The specific deliverables are:

•	Instructions on deploying the relational database (i.e., steps to import the .sql package)

•	The relational database must include dummy data (the amount of dummy data must be adequate to perform queries listed below)

•	SQL statements (with expected outputs) for queries (i.e., in a sql or text file) as follows:

o	Generate a list of male users who are >= 21 years old

o	Generate a list of male users who are following more female users than male users

o	Generate a list of female users who are followed by only male users

o	Generate a list of users who are following each other mutually. For example, A is following B and B is following B (in other words, A is following B and A is also followed by B)

o	Generate activeness insight, i.e., a list of users who have exercised (i) less than 30 minutes per week, (ii) between 30 minutes and 60 minutes, (iii) between 60 minutes and 120 minutes, and (iv) more than 120 minutes

o	Based on the above (activeness insight), generate age-based activeness insight, i.e., (i) below 21 years old, (ii) between 21 and 35 years old, (iii) between 35 and 50 years old, and (iv) above 50 years old

o	Enrich the above (age-based activeness insight) with genders (i.e., provides age-based activeness insight for each gender)

o	Generate a list of users who have received > 5 Kudos in average for each activity

o	Compute monthly active social networks, i.e., for each user, list out his/her followers, who have given him/her >=5 Kudos for each month’s activities

o	Conduct social comparison analysis, i.e., for each user, list out his or her weekly average activity distance and weekly average activity duration. Additionally, compute the weekly averages for his social networks (i.e., followed by the user)

## A.2 Nonrelational database implementation

# A nonrelational database shall be implemented. You may develop the nonrelational database using MongoDB or Neo4j. You are recommended to develop the nonrelational database design based on that in A.1.

The specific deliverables are:

-	Instructions on deploying the nonrelational database 
-	The nonrelational database must include dummy data (consistent with that in A.1)
-	noSQL / Cypher statements (with expected outputs) for queries (i.e., in a text file) as depicted in A1 above.
