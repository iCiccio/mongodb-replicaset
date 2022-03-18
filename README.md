# **Configure MongoDB Replica Set**
![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
## **Prerequisites**
- Docker (version 20.10+)
- docker-compose (version 1.29.2+)

## **Deployment**

For deploying the mongodb replicaset, open your `terminal` and write:
```bash
    $ git clone https://github.com/iCiccio/mongodb-replicaset.git
    $ cd mongodb-replicaset
    $ ./configure.sh
```

You will be guided in a configuration tool that will deploy for you the mongodb replicaset.

![guide-terminal](docs/images/set-env.png)

The `configure.sh` script will ask you to set yout parameters. The parameters are stored in a `.env` file. The file containes:
```bash
#### MongoDB Configuration
MONGO_INITDB_ROOT_USERNAME=<root_username>
MONGO_INITDB_ROOT_PASSWORD=<root_password>
MONGO_REPLICA_SET_NAME=<replicaset_name>
MONGO_CL_ADMIN_USERNAME=<username_clusteradmin>
MONGO_CL_ADMIN_PASSWORD=<password_clusteradmin>
```

## **docker-compose.yml**

```yaml
version: "3"

services:

  mongodb:
    image: mongo:latest
    restart: always
    container_name: mongodb
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
      - MONGO_REPLICA_SET_NAME=${MONGO_REPLICA_SET_NAME}
      - MONGO_CL_ADMIN_USERNAME=${MONGO_CL_ADMIN_USERNAME}
      - MONGO_CL_ADMIN_PASSWORD=${MONGO_CL_ADMIN_PASSWORD}
    volumes:
      - mongodb-rs-1:/data/db
      - ./auth/key:/auth/key
      - ./scripts/rs-init.sh:/scripts/rs-init.sh
      - ./scripts/user-init.sh:/scripts/user-init.sh

    entrypoint: [ "/usr/bin/mongod",  "--keyFile", "/auth/key", "--bind_ip_all", "--replSet", "${MONGO_REPLICA_SET_NAME}", "--port", "27017"]
    networks:
      - mongo-plus-network

  mongodb2:
    image: mongo:latest
    restart: always
    container_name: mongodb2
    ports:
      - "27018:27018"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
    volumes:
      - mongodb-rs-2:/data/db
      - ./auth/key:/auth/key
    entrypoint: [ "/usr/bin/mongod",  "--keyFile", "/auth/key", "--bind_ip_all", "--replSet", "${MONGO_REPLICA_SET_NAME}", "--port", "27018"]
    networks:
      - mongo-plus-network
    depends_on:
      - mongodb

  mongodb3:
    image: mongo:latest
    restart: always
    container_name: mongodb3
    ports:
      - "27019:27019"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
    volumes:
      - mongodb-rs-3:/data/db
      - ./auth/key:/auth/key
    entrypoint: [ "/usr/bin/mongod",  "--keyFile", "/auth/key", "--bind_ip_all", "--replSet", "${MONGO_REPLICA_SET_NAME}", "--port", "27019"]
    networks:
      - mongo-plus-network
    depends_on:
      - mongodb

  mongo-express:
    image: mongo-express
    container_name: mongo-express
    restart: 'always'
    ports:
      - 8081:8081
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - ME_CONFIG_MONGODB_ADMINPASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
      - ME_CONFIG_MONGODB_SERVER=mongodb
    depends_on:
      - mongodb
      - mongodb2
      - mongodb3
    networks:
      - mongo-plus-network

networks:
  mongo-plus-network:

volumes:
  mongodb-rs-1:
  mongodb-rs-2:
  mongodb-rs-3:
```

## **MongoDB UI**
The docker-compose contains the Mongo Express viewer for mongodb. The service is available at `http://localhost:8081/`.

## **Test**
You can test the replicaset adding databases, collections and documents through the mongo-express service or using the script in the `examples` folder: 
```bash
    $ python3 examples/mongo_insert.py
```
#### **Insert Document in Mongo**

```python
import os
import pymongo
from dotenv import load_dotenv

from pprint import pprint
load_dotenv()

## Set connection parameters
username = os.getenv('MONGO_INITDB_ROOT_USERNAME', 'root')
password = os.getenv("MONGO_INITDB_ROOT_PASSWORD", 'toor')
rs = os.getenv('MONGO_REPLICA_SET_NAME', 'rs0')

## Connect to mongo
myclient = pymongo.MongoClient(f"mongodb://{username}:{password}@localhost:27017")

## Select the dbrs database and the contributors collection
db = myclient["dbrs"]
coll = db["contributors"]

## Document to store in the contributors collection
document = {"name": "<name>", "email": "<email>"}

## Mongo insert
result = coll.insert_one(document)
print("[SAVED] Document _id: {0}".format(result.inserted_id))

## Mongo query for retrieving every document in contributors
for doc in coll.find({}):
    pprint(doc)
    
```
