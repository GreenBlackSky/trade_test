import datetime as dt
import json
from random import random

from asyncio import sleep
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from websockets.exceptions import ConnectionClosedOK
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

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)


manager = ConnectionManager()

@app.get("/history")
async def root(start: dt.datetime, end: dt.datetime):
    return json.dumps(get_records(start, end))


@app.websocket("/update/")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            await websocket.send_json({"value": random()})
            await sleep(1)
    except (WebSocketDisconnect, ConnectionClosedOK) as e:
        manager.disconnect(websocket)
