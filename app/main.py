from fastapi import FastAPI, Response
from models import User
# from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from pymongo import MongoClient

# config system
client = MongoClient('localhost:27017')
db = client.myapp

app = FastAPI()


@app.get("/health")
def read_health():
    return {"status": "ok"}


@app.get("/users/{user_id}")
def get_user(user_id: str, response: Response):
    user = db.users.find_one({"user_id": user_id})
    if user:
        return {"message": f"The name of {user['user_id']} is {user['user_name']}"}
    else:
        response.status_code = 404
        return {"error": "User not found"}


@app.put("/users/{user_id}", status_code=204)
def upsert_user(user_id: str, user: User):
    db.users.update_one({'user_id': user_id}, {"$set": {'user_id': user_id, 'user_name': user.name}}, upsert=True)

# FastAPIInstrumentor.instrument_app(app)
