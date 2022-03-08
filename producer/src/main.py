from cmath import log
from time import sleep
from json import dumps
from random import random

from kafka import KafkaProducer


def generate_movement():
    movement = -1 if random() < 0.5 else 1
    return movement


producer = KafkaProducer(
    bootstrap_servers=["kafka:29092"],
    value_serializer=lambda x: dumps(x).encode("utf-8"),
)

while True:
    for i in range(100):
        producer.send(f"ticker_{i:02d}", value=generate_movement())
    sleep(1)
