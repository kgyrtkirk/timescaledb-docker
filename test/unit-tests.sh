#!/bin/bash

set -e

echo "waiting for db"
/wait

psql -l
dropdb test
createdb test

psql -b -v ON_ERROR_STOP=1 test <<EOF
CREATE TABLE stocks_real_time (
  time TIMESTAMPTZ NOT NULL,
  symbol TEXT NOT NULL,
  price DOUBLE PRECISION NULL,
  day_volume INT NULL
);
CREATE TABLE company (
  symbol TEXT NOT NULL,
  name TEXT NOT NULL
);

SELECT create_hypertable('stocks_real_time','time');

CREATE INDEX ix_symbol_time ON stocks_real_time (symbol, time DESC);

insert into stocks_real_time values
('2020-11-11 11:11:11','A',9,1),
('2020-11-11 11:12:11','A',11,1),
('2020-11-11 11:13:11','B',1,1);

insert into company values ('A','AAA');
SELECT
    avg(price)
FROM stocks_real_time srt
JOIN company c ON c.symbol = srt.symbol
WHERE c.name = 'AAA';


SELECT symbol, first(price,time), last(price, time)
FROM stocks_real_time srt
GROUP BY symbol
ORDER BY symbol
;
EOF


