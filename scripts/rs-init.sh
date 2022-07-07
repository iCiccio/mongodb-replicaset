#!/bin/bash

mongo <<EOF
var config = {
    "_id": "${MONGO_REPLICA_SET_NAME}",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "${MONGO_REPLICA_SET_ADDR1}:27017",
            "priority": 3
        },
        {
            "_id": 2,
            "host": "${MONGO_REPLICA_SET_ADDR2}:27018",
            "priority": 2
        },
        {
            "_id": 3,
            "host": "${MONGO_REPLICA_SET_ADDR1}:27019",
            "priority": 1
        }
    ]
};
rs.initiate(config, { force: true });
rs.status();
EOF
