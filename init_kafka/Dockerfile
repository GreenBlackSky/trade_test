FROM confluentinc/cp-kafka:latest

USER root

RUN mkdir /app && chmod +rwx /app

WORKDIR /app

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

CMD ./run.sh