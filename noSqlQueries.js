db.BC2402.aggregate({
    $match: {$and: [{Male_Follows: {
        $exists: true
    }},
    {Female_Follows: {
        $exists: true
    }}]}},
    {$project: {
        name: "UserName",
        Gender: "Gender",
        countMale: {$size: "$Male_Follows"},
        countFemale: {$size: "$Female_Follows"}
    }},
    {
        $match: 
        {$expr: {
            $gt: ["$countMale","$countFemale"]
        }
    }}
)

db.BC2402.aggregate({$match: {
    $and: [{
        Gender:"F"
    },{
        Male_Followers: {$exists: true}
    },{
        Female_Followers: {$exists: false}
    }]
}})

//No "hax"
//Q2
db.BC2402.aggregate({
    $match: {
        Gender:"M"
    }
},{
    $lookup: {
           from: "BC2402",
           localField: "Follows",
           foreignField: "UserID",
           as: "Follows"
         }
},{
    $project: {
        UserID:1,
        Gender:1,
        countMales:{$size: {
        $filter: {
          input: "$Follows",
          as: "e",
          cond: {$eq: ["$$e.Gender", "M"]}
        }
    }},
        countFemales:{$size: {
            $filter: {
              input: "$Follows",
              as: "v",
              cond: {$eq: ["$$v.Gender", "F"]}
            }
        }
    }}},
    {
        $match: {
            $expr: { $gt: [ "$countFemales" , "$countMales"] }}
    },
    {
        $project: {
            UserID:1,
            Gender:1,
            countMales:1,
            countFemales:1
        }
})

//Q3
db.BC2402.aggregate({
    $match: {
        Gender:"F"
    }
},{
    $lookup: {
           from: "BC2402",
           localField: "Followers",
           foreignField: "UserID",
           as: "Followers"
         }
},{
    $project: {
        UserID:1,
        Gender:1,
        countMales:{$size: {
        $filter: {
          input: "$Followers",
          as: "e",
          cond: {$eq: ["$$e.Gender", "M"]}
        }
    }},
        countFemales:{$size: {
            $filter: {
              input: "$Followers",
              as: "v",
              cond: {$eq: ["$$v.Gender", "F"]}
            }
        }
    }}},
    {
        $match: {
        $expr: {
            $and: [{$gt: ["$countMales",0]},{$eq: ["$countFemales",0]}]
        }
    }},
    {
        $project: {
            UserID:1,
            Gender:1,
            countMales:1,
            countFemales:1
        }
})

//Q4
db.BC2402.aggregate({
    $project: {
        UserID:1,
        Follows:1,
        Followers:1,
        mutualFollows:{
            $setIntersection: ["$Follows","$Followers"]
        }
    }
},{
    $match: {
        $expr: {
            $and: [{
                $not: [{
                    $eq: ["$mutualFollows",null]
                }]
            },{
                $gt: [ {$size: "$mutualFollows"} , 0]
            }]
        }
    }
})

//Q5, Q6, Q7
db.BC2402.aggregate({
    $project: {
        UserID:1,
        Age:1,
        Gender:1,
        WeeklyExerciseDuration:{
            $divide: [{
                $sum: "$Activity.ActivityDuration"
            }, {
                $round: {
                    $divide: [{
                        $subtract: [new Date(),"$UserJoinDate"]
                    },
                        1000 * 60 * 60 * 24 * 7
                    ]
                }
            }]
        }
    }
},{
    $project: {
        UserID:1,
        Age:1,
        Gender:1,
        WeeklyExerciseDurationClass: {
        $cond: {if: {
            $lt: ["$WeeklyExerciseDuration",30]
        },then: "<30", else: {
            $cond: { if: { $lt: ["$WeeklyExerciseDuration",60] }, then: "30-60", else: {
                $cond: { if: { $lt: ["$WeeklyExerciseDuration",120] }, then: "60-120", else: ">120" }
            } }
        }
    }},
    AgeGroup:{
        $cond:{
            if:{
                $lt:["$Age", 21]
            },
            then:"<21",
            else:{
                $cond:{
                    if:{
                        $lt:["$Age", 35]
                    },
                    then:"21-35",
                    else:{
                        $cond:{
                            if:{
                                $lt:["$Age", 50]
                            },
                            then:"35-50",
                            else:">50"
                        }
                    }
                }
            }
        }
    }
}})

//Q8
db.BC2402.aggregate({
    $match: {
        Activity:{
            $exists: true
        }
    }
},{
    $project: {
        UserID:1,
        AverageKudos:{
            $divide: [{
                $sum: {
                    $map: {
                      input: "$Activity.KudoReceived",
                      as: "e",
                      in: {$size: "$$e"}
                    }
                }
            }, {
                $size: "$Activity"
            }]
        },
    }
},{
    $match: {
        AverageKudos:{
            $gt: 5
        }
    }
})

//Q9
db.BC2402.aggregate({
    $match: {
        Activity:{
            $exists: true
        }
    }
},{
    $unwind:"$Activity"
},{
	$project:{
		UserID:1,
		ActivityMonth:{$month:"$Activity.ActivityDate"},
		TotalKudos:{
			$map:{
				input: "$Activity.KudoReceived",
				as: "e",
				in: "$$e"
			}
		}
	}
},{
	$unwind:"$TotalKudos"
},{
	$group:{
		_id:{UserID:"$UserID",ActivityMonth:"$ActivityMonth",KudoGiver:"$TotalKudos"},
		KudosGiven:{$sum:1}
	}
})

//10
db.BC2402.aggregate({
    $unwind:"$Follows"
},{
    $lookup:{
        from:"BC2402",
        localField:"Follows",
        foreignField:"UserID",
        as:"Follows"
    }
},{
    $project: {
        UserID:1,
        WeeklyExerciseDuration:{
            $divide: [{
                $sum: "$Activity.ActivityDuration"
            }, {
                $round: {
                    $divide: [{
                        $subtract: [new Date(),"$UserJoinDate"]
                    },
                        1000 * 60 * 60 * 24 * 7
                    ]
                }
            }]
        },
		WeeklyExerciseDistance:{
			$divide: [{
                $sum: "$Activity.ActivityDistance"
            }, {
                $round: {
                    $divide: [{
                        $subtract: [new Date(),"$UserJoinDate"]
                    },
                        1000 * 60 * 60 * 24 * 7
                    ]
                }
            }]
		},
		FollowsID:{$arrayElemAt:["$Follows.UserID",0]},
        FollowsExerciseDuration:{
            $divide: [{
                $sum: {$arrayElemAt:["$Follows.Activity.ActivityDuration",0]}
            }, {
                $round: {
                    $divide: [{
                        $subtract: [new Date(),{$arrayElemAt:["$Follows.UserJoinDate",0]}]
                    },
                        1000 * 60 * 60 * 24 * 7
                    ]
                }
            }]
        },
		FollowsExerciseDistance:{
			$divide: [{
                $sum: {$arrayElemAt:["$Follows.Activity.ActivityDistance",0]
            }, {
                $round: {
                    $divide: [{
                        $subtract: [new Date(),{$arrayElemAt:["$Follows.UserJoinDate",0]}]
                    },
                        1000 * 60 * 60 * 24 * 7
                    ]
                }
            }]
		},
    }
})