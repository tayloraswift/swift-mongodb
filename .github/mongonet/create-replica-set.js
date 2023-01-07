db = connect('mongodb://mongo-0:27017/admin');
db.runCommand({'replSetInitiate': {
    "_id": "test-set",
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "mongo-0:27017",
            "tags": {
                "priority": "high",
                "name": "A",
            },
            "priority": 2
        },
        {
            "_id": 1,
            "host": "mongo-1:27017",
            "tags": {
                "priority": "low",
                "name": "B",
            },
            "priority": 1
        },
        {
            "_id": 2,
            "host": "mongo-2:27017",
            "tags": {
                "priority": "zero",
                "name": "C",
            },
            "priority": 0
        },
        {
            "_id": 3,
            "host": "mongo-3:27017",
            "tags": {
                "priority": "zero",
                "name": "D",
            },
            "priority": 0
        },
        {
            "_id": 4,
            "host": "mongo-4:27017",
            "tags": {
                "priority": "zero",
                "name": "H",
            },
            "secondaryDelaySecs": 5,
            "priority": 0,
            "votes": 0,
            "hidden": true
        },
        {
            "_id": 5,
            "host": "mongo-5:27017",
            "priority": 0,
            "arbiterOnly": true
        }
    ]
}});
