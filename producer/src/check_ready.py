from time import sleep

from kafka import KafkaConsumer
from kafka.errors import NoBrokersAvailable

while True:
    try:
        consumer = KafkaConsumer(bootstrap_servers=['kafka:29092'])
        break
    except NoBrokersAvailable as e:
        print("No brokers")
        sleep(5)
 
while len(consumer.topics()) != 100:
    print("Topics not ready")
    sleep(5)
