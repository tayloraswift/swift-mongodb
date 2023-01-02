db = connect('mongodb://mongo-1:27017/admin');
db.runCommand({'replSetInitiate': {
    "_id": "test-set",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "mongo-1:27017",
            "tags": {
                "c": "C",
                "a": "A",
                "b": "B",
            },
            "priority": 2
        },
        {
            "_id": 2,
            "host": "mongo-2:27017",
            "tags": {
                "b": "B",
                "d": "D",
                "c": "C"
            },
            "priority": 1
        },
        {
            "_id": 3,
            "host": "mongo-3:27017",
            "priority": 0,
            "arbiterOnly": true
        }
    ]
}});
