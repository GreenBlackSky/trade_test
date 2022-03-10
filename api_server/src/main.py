from asyncio import get_event_loop, create_task
import datetime as dt
import json
from typing import Any

from aiokafka import AIOKafkaConsumer
from fastapi import FastAPI, WebSocket
from starlette.endpoints import WebSocketEndpoint
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


@app.websocket_route("/update/")
class WebsocketConsumer(WebSocketEndpoint):
    async def on_connect(self, websocket: WebSocket) -> None:
        await websocket.accept()

        loop = get_event_loop()
        self.consumer = AIOKafkaConsumer(
            "tickers",
            loop=loop,
            bootstrap_servers=["kafka:29092"],
            enable_auto_commit=False,
        )
        await self.consumer.start()
        self.consumer_task = create_task(
            self.send_consumer_message(websocket=websocket)
        )
        await self.consumer_task

    async def on_disconnect(self, websocket: WebSocket, close_code: int) -> None:
        self.consumer_task.cancel()
        await self.consumer.stop()

    async def on_receive(self, websocket: WebSocket, data: Any) -> None:
        pass

    async def send_consumer_message(self, websocket: WebSocket) -> None:
        async for data in self.consumer:
            for record in json.loads(data.value):
                print("sending", record)
                await websocket.send_text(json.dumps(record))
