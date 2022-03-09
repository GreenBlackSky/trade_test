import datetime as dt
import json

from kafka import KafkaConsumer

from .db_handler import write_record


consumer = KafkaConsumer(bootstrap_servers=["kafka:29092"])
consumer.subscribe(["tickers"])


for message in consumer:
    message = json.loads(message.value)
    for record in message:
        write_record(
            record["name"], dt.datetime.fromtimestamp(record["time"]), record["value"]
        )
        print(record)
