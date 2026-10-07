/*
 * Test data for the rtest image (app-test.R), as a DuckDB file.
 *
 * The container's default query is:
 *   SELECT AVG(speed) AS "Average Speed" FROM carspeed;
 *
 * Build the file with the DuckDB CLI:
 *   duckdb carspeed.duckdb < testdata-duckdb.sql
 * or with Python:
 *   python -c "import duckdb; duckdb.connect('carspeed.duckdb').sql(open('testdata-duckdb.sql').read())"
 *
 * Expected average: 63.02
 */

CREATE OR REPLACE TABLE carspeed (
    id          INTEGER PRIMARY KEY,
    plate       VARCHAR      NOT NULL,
    make        VARCHAR,
    model       VARCHAR,
    speed       DECIMAL(6,2) NOT NULL,   -- km/h
    speed_limit INTEGER      NOT NULL,
    road        VARCHAR,
    recorded_at TIMESTAMP    NOT NULL
);

INSERT INTO carspeed VALUES
    (1,  'AB12 CDE', 'Ford',    'Focus',   48.50, 48, 'A803 Kirkintilloch Rd', '2026-08-01 07:14:00'),
    (2,  'SC09 XYZ', 'Toyota',  'Corolla', 62.10, 48, 'A803 Kirkintilloch Rd', '2026-08-01 07:31:00'),
    (3,  'GL55 TRU', 'Nissan',  'Qashqai', 31.75, 32, 'Byres Road',            '2026-08-01 08:02:00'),
    (4,  'ED18 KLM', 'BMW',     '320d',    97.40, 96, 'M8 Junction 18',        '2026-08-01 08:20:00'),
    (5,  'AB60 PQR', 'Skoda',   'Octavia',112.30, 96, 'M8 Junction 18',        '2026-08-01 08:22:00'),
    (6,  'FF21 JHG', 'Renault', 'Clio',    44.90, 48, 'Great Western Rd',      '2026-08-02 09:05:00'),
    (7,  'KY71 WWE', 'Audi',    'A4',      55.60, 48, 'Great Western Rd',      '2026-08-02 09:11:00'),
    (8,  'DD34 MNO', 'Vauxhall','Corsa',   28.20, 32, 'Sauchiehall St',        '2026-08-02 10:47:00'),
    (9,  'PH02 RST', 'Tesla',   'Model 3', 88.05, 96, 'M77 Northbound',        '2026-08-02 17:33:00'),
    (10, 'IV88 UVW', 'Kia',     'Sportage',73.15, 64, 'A9 Dunblane',           '2026-08-03 06:58:00'),
    (11, 'SB44 ABC', 'Honda',   'Civic',   66.80, 64, 'A9 Dunblane',           '2026-08-03 07:02:00'),
    (12, 'MX19 DEF', 'Mercedes','C220',   104.95, 96, 'M74 Southbound',        '2026-08-03 12:40:00'),
    (13, 'OU07 GHI', 'Seat',    'Ibiza',   35.40, 32, 'Dumbarton Rd',          '2026-08-04 14:19:00'),
    (14, 'LN23 JKL', 'Volvo',   'XC40',    49.95, 48, 'Maryhill Rd',           '2026-08-04 15:26:00'),
    (15, 'YT16 MNP', 'Peugeot', '208',     58.35, 48, 'Maryhill Rd',           '2026-08-04 15:44:00'),
    (16, 'ZZ99 QRS', 'Fiat',    '500',     22.60, 32, 'Argyle St',             '2026-08-05 11:08:00'),
    (17, 'CA31 TUV', 'Hyundai', 'i30',     91.20, 96, 'M80 Northbound',        '2026-08-05 18:51:00'),
    (18, 'WS76 WXY', 'Mazda',   'CX-5',    69.70, 64, 'A82 Loch Lomond',       '2026-08-06 08:37:00'),
    (19, 'BT05 ZAB', 'Subaru',  'Impreza', 78.45, 64, 'A82 Loch Lomond',       '2026-08-06 08:41:00'),
    (20, 'RG12 CDX', 'Citroen', 'C3',      41.05, 48, 'Paisley Rd West',       '2026-08-06 19:12:00');

-- Sanity check: this is the query the container runs by default.
SELECT AVG(speed) AS "Average Speed" FROM carspeed;
