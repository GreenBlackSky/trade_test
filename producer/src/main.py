import datetime as dt
from json import dumps
from random import random
from time import sleep

from kafka import KafkaProducer


def generate_movement():
    movement = -1 if random() < 0.5 else 1
    return movement


def fetch_current_values():
    return {f"ticker_{i:02d}": 0 for i in range(100)}


def get_first_updates(values):
    timestamp = dt.datetime.now().timestamp()
    return [
        {'name': name, value: values[name], 'time': timestamp}
        for name, value in values.items()
    ]


def update_values(values: dict[str, int]):
    update = []
    timestamp = dt.datetime.now().timestamp()
    for name, value in values.items():
        values[name] = value + generate_movement()
        update.append({'name': name, value: values[name], 'time': timestamp})
    return update


def send_values(producer: KafkaProducer, values: dict[str, int]):
    producer.send(f"tickers", value=values)


if __name__ == "__main__":
    producer = KafkaProducer(
        bootstrap_servers=["kafka:29092"],
        value_serializer=lambda x: dumps(x).encode("utf-8"),
    )

    values = fetch_current_values()
    send_values(producer, get_first_updates(values))

    while True:
        update = update_values(values)
        send_values(producer, update)
        print("updated")
        sleep(1)
