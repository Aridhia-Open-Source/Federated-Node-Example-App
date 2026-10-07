/*
 * Test data for the rtest image (app-test.R).
 *
 * The container's default query is:
 *   SELECT AVG(speed) AS "Average Speed" FROM carspeed;
 *
 * Run against MSSQL, e.g.:
 *   sqlcmd -S localhost,1433 -U sa -P '<password>' -i testdata-mssql.sql
 * or, if the target database does not exist yet, create it first:
 *   sqlcmd -S localhost,1433 -U sa -P '<password>' -Q "CREATE DATABASE testing21"
 *   sqlcmd -S localhost,1433 -U sa -P '<password>' -d testing21 -i testdata-mssql.sql
 */

IF OBJECT_ID('dbo.carspeed', 'U') IS NOT NULL
    DROP TABLE dbo.carspeed;
GO

CREATE TABLE dbo.carspeed (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    plate       VARCHAR(10)   NOT NULL,
    make        VARCHAR(50)   NULL,
    model       VARCHAR(50)   NULL,
    speed       DECIMAL(6,2)  NOT NULL,   -- km/h
    speed_limit INT           NOT NULL,
    road        VARCHAR(100)  NULL,
    recorded_at DATETIME2(0)  NOT NULL
);
GO

INSERT INTO dbo.carspeed (plate, make, model, speed, speed_limit, road, recorded_at) VALUES
    ('AB12 CDE', 'Ford',    'Focus',   48.50, 48, 'A803 Kirkintilloch Rd', '2026-08-01T07:14:00'),
    ('SC09 XYZ', 'Toyota',  'Corolla', 62.10, 48, 'A803 Kirkintilloch Rd', '2026-08-01T07:31:00'),
    ('GL55 TRU', 'Nissan',  'Qashqai', 31.75, 32, 'Byres Road',            '2026-08-01T08:02:00'),
    ('ED18 KLM', 'BMW',     '320d',    97.40, 96, 'M8 Junction 18',        '2026-08-01T08:20:00'),
    ('AB60 PQR', 'Skoda',   'Octavia',112.30, 96, 'M8 Junction 18',        '2026-08-01T08:22:00'),
    ('FF21 JHG', 'Renault', 'Clio',    44.90, 48, 'Great Western Rd',      '2026-08-02T09:05:00'),
    ('KY71 WWE', 'Audi',    'A4',      55.60, 48, 'Great Western Rd',      '2026-08-02T09:11:00'),
    ('DD34 MNO', 'Vauxhall','Corsa',   28.20, 32, 'Sauchiehall St',        '2026-08-02T10:47:00'),
    ('PH02 RST', 'Tesla',   'Model 3', 88.05, 96, 'M77 Northbound',        '2026-08-02T17:33:00'),
    ('IV88 UVW', 'Kia',     'Sportage',73.15, 64, 'A9 Dunblane',           '2026-08-03T06:58:00'),
    ('SB44 ABC', 'Honda',   'Civic',   66.80, 64, 'A9 Dunblane',           '2026-08-03T07:02:00'),
    ('MX19 DEF', 'Mercedes','C220',   104.95, 96, 'M74 Southbound',        '2026-08-03T12:40:00'),
    ('OU07 GHI', 'Seat',    'Ibiza',   35.40, 32, 'Dumbarton Rd',          '2026-08-04T14:19:00'),
    ('LN23 JKL', 'Volvo',   'XC40',    49.95, 48, 'Maryhill Rd',           '2026-08-04T15:26:00'),
    ('YT16 MNP', 'Peugeot', '208',     58.35, 48, 'Maryhill Rd',           '2026-08-04T15:44:00'),
    ('ZZ99 QRS', 'Fiat',    '500',     22.60, 32, 'Argyle St',             '2026-08-05T11:08:00'),
    ('CA31 TUV', 'Hyundai', 'i30',     91.20, 96, 'M80 Northbound',        '2026-08-05T18:51:00'),
    ('WS76 WXY', 'Mazda',   'CX-5',    69.70, 64, 'A82 Loch Lomond',       '2026-08-06T08:37:00'),
    ('BT05 ZAB', 'Subaru',  'Impreza', 78.45, 64, 'A82 Loch Lomond',       '2026-08-06T08:41:00'),
    ('RG12 CDX', 'Citroen', 'C3',      41.05, 48, 'Paisley Rd West',       '2026-08-06T19:12:00');
GO

-- Sanity check: this is the query the container runs by default.
SELECT AVG(speed) AS "Average Speed" FROM dbo.carspeed;
GO
