import datetime as dt
import json
from random import random

from asyncio import sleep
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware

from .db_handler import get_records


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/history")
async def root(start: dt.datetime, end: dt.datetime):
    return json.dumps(get_records(start, end))


@app.websocket("/update/")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        await websocket.send_json({"value": random()})
        await sleep(1)
