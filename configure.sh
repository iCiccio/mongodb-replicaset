#!/bin/bash

rm -rf auth/ .env
chmod +x scripts/*.sh

echo "MongoDB Replica Set Configuration Tool"
echo "Generating a key ..."
mkdir auth
openssl rand -base64 700 > ./auth/key
echo "Changing permission to ./auth/key"
chmod 600 ./auth/key

echo "==== MongoDB Config ===="
read -p "Enter mongo root username [root]: " r_name
r_name=${r_name:-root}
read -p "Enter mongo password for root account [toor]: " r_psw
r_psw=${r_psw:-toor}
read -p "Enter mongo replica set name [rs0]: " rs_name
rs_name=${rs_name:-rs0}
read -p "Enter mongo replica set cluster name [cl-admin]: " cl_name
cl_name=${cl_name:-cl-admin}
read -p "Enter mongo replica set cluster user password [cluster]: " cl_psw
cl_psw=${cl_psw:-cluster}

# shellcheck disable=SC2129
echo "#### MongoDB Configuration" >> .env
echo "MONGO_INITDB_ROOT_USERNAME=$r_name" >> .env
echo "MONGO_INITDB_ROOT_PASSWORD=$r_psw" >> .env
echo "MONGO_REPLICA_SET_NAME=$rs_name" >> .env
echo "MONGO_CL_ADMIN_USERNAME=$cl_name" >> .env
echo "MONGO_CL_ADMIN_PASSWORD=$cl_psw" >> .env
echo "Creating .env file ..."

docker-compose down -v
if [[ -z $1 ]]; then
    echo "[DEFAULT] Composing docker-compose.yml"
    docker-compose up -d --build -V --remove-orphans
else
    echo "Composing $1"
    docker-compose -f $1 up -d --build -V --remove-orphans
fi

echo "Waiting for all services up..."
sleep 5

echo "Running initialization script..."
docker exec mongodb /scripts/rs-init.sh
docker-compose restart
sleep 30
echo "Running root and admin users ..."
# docker exec mongodb /scripts/user-init.sh
docker exec -i mongodb bash < ./scripts/user-init.sh

printf "\n\nMongoDB Replica Set started.\n"
printf "For inspecting and testing the MongoDB Replica Set\n"
printf "visit the http://127.0.0.1:8081 or you can use the python script in the test folder.\n"
printf "Make sure to install pymongo:\n"
printf "  $ pip install pymongo --user\n"
printf "and execute the script:\n"
printf "  $ python3 test/insert_demo.py\n"