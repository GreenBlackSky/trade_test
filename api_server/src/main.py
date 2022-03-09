from asyncio import sleep
from random import random
from fastapi import FastAPI, WebSocket


app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.websocket("/update/")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        await websocket.send_json({"value": random()})
        await sleep(1)
