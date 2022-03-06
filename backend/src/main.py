from random import random

from fastapi import FastAPI


app = FastAPI()


def generate_movement():
    movement = -1 if random() < 0.5 else 1
    return movement


@app.get("/")
async def root():
    return {"message": "Hello World"}
