import datetime as dt
from random import random

from asyncio import sleep
from fastapi import FastAPI, WebSocket

from .db_handler import get_records


app = FastAPI()


@app.get("/history/")
async def root(start: dt.datetime, end: dt.datetime):
    return get_records(start, end)


@app.websocket("/update/")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        await websocket.send_json({"value": random()})
        await sleep(1)
