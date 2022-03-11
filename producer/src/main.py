import datetime as dt
from functools import lru_cache
import json
from random import random
from time import sleep

from kafka import KafkaProducer

from .db_handler import get_last_record


def generate_movement():
    movement = -1 if random() < 0.5 else 1
    return movement


@lru_cache
def get_resource_names():
    return {f"ticker_{i:02d}" for i in range(3)}


def start_values():
    return {name: 0 for name in get_resource_names()}


def fetch_current_values():
    ret = {}
    for name in get_resource_names():
        if not (record := get_last_record(name)):
            return None
        ret[name] = record.value
    print("values fetched", ret)
    return ret


def get_first_updates(values):
    timestamp = dt.datetime.now().timestamp()
    return [
        {"name": name, value: values[name], "time": timestamp}
        for name, value in values.items()
    ]


def update_values(values: dict[str, int]):
    update = []
    timestamp = dt.datetime.now().timestamp()
    for name, value in values.items():
        values[name] = value + generate_movement()
        update.append({"name": name, "value": values[name], "time": timestamp})
        print("updated:", update[-1])
    return update


def send_values(producer: KafkaProducer, values: dict[str, int]):
    producer.send("tickers", value=values)


if __name__ == "__main__":
    producer = KafkaProducer(
        bootstrap_servers=["kafka:29092"],
        value_serializer=lambda x: json.dumps(x).encode("utf-8"),
    )

    if not (values := fetch_current_values()):
        values = start_values()
        send_values(producer, get_first_updates(values))

    while True:
        update = update_values(values)
        send_values(producer, update)
        print("sent", dt.datetime.now())
        sleep(1)
