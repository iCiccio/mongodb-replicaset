#!/bin/bash

mongosh <<EOF
use admin

db.createUser(
  {
  user: "${MONGO_INITDB_ROOT_USERNAME}",
  pwd: "${MONGO_INITDB_ROOT_PASSWORD}",
  roles: [{ role: "root", db: "admin"}]
  })

db.auth("${MONGO_INITDB_ROOT_USERNAME}", "${MONGO_INITDB_ROOT_PASSWORD}")

db.createUser(
  {
  user: "${MONGO_CL_ADMIN_USERNAME}",
  pwd: "${MONGO_CL_ADMIN_PASSWORD}",
  roles: [{ role: "userAdminAnyDatabase", db: "admin"}, { role: "clusterAdmin", db: "admin"}]
  })

show users
EOF
