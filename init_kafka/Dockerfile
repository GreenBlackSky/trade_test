FROM confluentinc/cp-kafka:latest

CMD kafka-topics --bootstrap-server kafka:29092 --create --if-not-exists --topic tickers --replication-factor 1 --partitions 1