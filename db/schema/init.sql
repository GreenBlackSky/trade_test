CREATE TABLE tickers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(10) NOT NULL,
    time TIMESTAMP NOT NULL,
    value INT NOT NULL
);