import datetime as dt
import os

from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    DateTime,
    BigInteger,
    select,
    func,
    distinct,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session as OrmSession


connection_string = "postgresql://{}:{}@{}:{}/{}".format(
    os.environ["POSTGRES_USER"],
    os.environ["POSTGRES_PASSWORD"],
    os.environ["POSTGRES_HOST"],
    os.environ["POSTGRES_PORT"],
    os.environ["POSTGRES_DB"],
)
engine = create_engine(connection_string)
Base = declarative_base()
Session = sessionmaker(bind=engine)


class Record(Base):  # type: ignore

    __tablename__ = "records"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(20), nullable=False)
    time = Column(DateTime, nullable=False)
    value = Column(Integer, nullable=False)

    def to_dict(self):
        return {
            "name": self.name,
            "time": self.time.timestamp(),
            "value": self.value,
        }


def write_record(name: str, time: dt.datetime, value: int):
    record = Record(name=name, time=time, value=value)
    session: OrmSession
    with Session() as session:
        with session.begin():
            session.add(record)


def get_last_record(name: str):
    session: OrmSession
    with Session() as session:
        last_time = session.execute(
            select(func.max(Record.time)).where(Record.name == name)
        ).scalar()
        record: Record = session.execute(
            select(Record).where(Record.name == name).where(Record.time == last_time)
        ).scalar()
    if record:
        return record
    return None


def get_records(ticker_name: str, start: dt.datetime, end: dt.datetime) -> list[dict]:
    session: OrmSession
    with Session() as session:
        records = session.execute(
            select(Record)
            .where(Record.name == ticker_name)
            .where(Record.time >= start)
            .where(Record.time < end)
        ).all()
    print("sent", len(records))
    return [record.to_dict() for (record,) in records]


def get_ticker_names():
    session: OrmSession
    with Session() as session:
        names = session.execute(select(Record.name).distinct())
        result = sorted([name for (name,) in names])
        print(result)
    return result
