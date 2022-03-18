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
    
