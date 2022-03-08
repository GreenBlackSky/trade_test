from asyncio import sleep
from random import random
from fastapi import FastAPI, WebSocket


app = FastAPI()



@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.websocket("/update")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    data = {
        f"ticker_{i:02d}": 0 for i in range(100)
    }
    while True:
        for key, value in data.items():
            data[key] = value + generate_movement()
        await websocket.send_json(data)
        await sleep(1)