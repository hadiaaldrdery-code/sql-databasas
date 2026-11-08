-- Student: Lina Nagi
-- Student: Hadia Aldirdiry
-- Student: Samar khalid
-- Student Number: 202512809
-- Student Number: 202512812
-- Student Number: 202512085
SET student_number = 202512812;
SET P = MOD(student_number, 10);
SET U = MOD(MOD(student_number, 100), 6) + 1;
SET M = MOD(P, 5) + 1; 

CREATE DATABASE IF NOT EXISTS sms_202512812;
USE sms_202512812;

CREATE TABLE ranks (
    rank_id INT PRIMARY KEY,
    rank_name VARCHAR(50) NOT NULL UNIQUE,
    rank_level INT NOT NULL CHECK (rank_level BETWEEN 1 AND 6)
);

CREATE TABLE units (
    unit_id INT PRIMARY KEY,
    unit_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL
);


CREATE TABLE missions (
    mission_id INT PRIMARY KEY,
    mission_name VARCHAR(100) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE,
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE soldiers (
    soldier_id INT AUTO_INCREMENT PRIMARY KEY,
    service_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    enlistment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    rank_id INT NOT NULL,
    unit_id INT NOT NULL,

    CHECK (status IN ('Active', 'On Leave', 'Retired')),
    CHECK (enlistment_date > date_of_birth),

    FOREIGN KEY (rank_id) REFERENCES ranks(rank_id),
    FOREIGN KEY (unit_id) REFERENCES units(unit_id)
);


CREATE TABLE soldier_missions (
    soldier_id INT NOT NULL,
    mission_id INT NOT NULL,
    mission_role VARCHAR(100) NOT NULL,

    PRIMARY KEY (soldier_id, mission_id),

    FOREIGN KEY (soldier_id) REFERENCES soldiers(soldier_id),
    FOREIGN KEY (mission_id) REFERENCES missions(mission_id)
);

INSERT INTO ranks VALUES
(1, 'Private', 1),
(2, 'Corporal', 2),
(3, 'Sergeant', 3),
(4, 'Lieutenant', 4),
(5, 'Captain', 5),
(6, 'Major', 6);

INSERT INTO units VALUES
(1, 'Alpha Company', 'North Camp'),
(2, 'Bravo Company', 'South Camp'),
(3, 'Charlie Company', 'East Camp'),
(4, 'Delta Company', 'West Camp'),
(5, 'Signals Unit', 'Central Camp'),
(6, 'Medical Unit', 'Central Camp');

INSERT INTO missions VALUES
(1, 'Exercise Falcon', '2025-02-03', '2025-02-28'),
(2, 'Flood Relief', '2025-04-14', '2025-05-30'),
(3, 'Border Patrol', '2025-07-01', NULL),
(4, 'Peace Support', '2025-09-15', NULL),
(5, 'Field Medical Camp', '2026-01-12', '2026-01-23');


INSERT INTO soldiers
(service_number, first_name, last_name, date_of_birth,
 enlistment_date, status, rank_id, unit_id)
VALUES
(CONCAT('ST-', @student_number),
 'Hadia', 'Aldirdiry',
 '2000-01-10', '2022-01-10',
 'Active', 1, @U);

INSERT INTO soldiers
(service_number, first_name, last_name, date_of_birth,
 enlistment_date, status, rank_id, unit_id)
VALUES
(CONCAT('ST-', @student_number, '-2'),
 'John', 'Mugisha',
 '1999-05-12', '2021-06-15',
 'Active', MOD(@P, 6) + 1, @U);

INSERT INTO soldiers
(service_number, first_name, last_name, date_of_birth,
 enlistment_date, status, rank_id, unit_id)
VALUES
(CONCAT('ST-', @student_number, '-3'),
 'Peter', 'Uwimana',
 '1998-03-20', '2020-04-10',
 'Active', 2, MOD(@U, 6) + 1);

INSERT INTO soldier_missions
(soldier_id, mission_id, mission_role)
VALUES
(31, @M, 'Team Leader'),
(32, @M, 'Medic');

SELECT *
FROM soldiers
ORDER BY soldier_id DESC
LIMIT 10;

SELECT *
FROM soldiers
WHERE soldier_id IN (
    SELECT soldier_id
    FROM (
        SELECT soldier_id
        FROM soldiers
        ORDER BY soldier_id DESC
        LIMIT 10
    ) AS recent_soldiers
)
ORDER BY soldier_id ASC;

SELECT *
FROM soldiers
WHERE soldier_id IN (10, 15, 20);

SELECT *
FROM soldiers
WHERE soldier_id IN (10 + @P, 15 + @P, 20 + @P);

SELECT *
FROM soldiers
WHERE status = 'Active'
AND soldier_id BETWEEN 10 AND 20;

SELECT
    s.soldier_id,
    s.first_name,
    s.last_name,
    r.rank_name
FROM soldiers s
JOIN ranks r ON s.rank_id = r.rank_id
ORDER BY r.rank_level DESC, s.last_name ASC;

SELECT
    s.first_name,
    s.last_name,
    r.rank_name,
    u.unit_name,
    u.location
FROM soldiers s
JOIN ranks r ON s.rank_id = r.rank_id
JOIN units u ON s.unit_id = u.unit_id
WHERE s.status = 'Active'
AND s.unit_id = @U;

SELECT
    s.soldier_id,
    s.first_name,
    s.last_name,
    r.rank_name,
    m.mission_name,
    sm.mission_role,
    u.unit_name
FROM soldier_missions sm
JOIN soldiers s ON sm.soldier_id = s.soldier_id
JOIN missions m ON sm.mission_id = m.mission_id
JOIN ranks r ON s.rank_id = r.rank_id
JOIN units u ON s.unit_id = u.unit_id
WHERE m.mission_id = @M;

SELECT *
FROM soldiers s
WHERE NOT EXISTS (
    SELECT 1
    FROM soldier_missions sm
    WHERE sm.soldier_id = s.soldier_id
);

SELECT
    u.unit_name,
    COUNT(s.soldier_id) AS total_soldiers
FROM units u
LEFT JOIN soldiers s ON u.unit_id = s.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY total_soldiers DESC;

EXPLAIN
SELECT *
FROM soldiers
WHERE last_name = 'Mugisha';

CREATE INDEX idx_soldiers_last_name
ON soldiers(last_name);

EXPLAIN
SELECT *
FROM soldiers
WHERE last_name = 'Mugisha';

CREATE VIEW v_soldier_profile AS
SELECT
    s.soldier_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    r.rank_name,
    u.unit_name,
    u.location
FROM soldiers s
JOIN ranks r ON s.rank_id = r.rank_id
JOIN units u ON s.unit_id = u.unit_id;

SELECT *
FROM v_soldier_profile
WHERE unit_name = (
    SELECT unit_name
    FROM units
    WHERE unit_id = @U
)
ORDER BY full_name ASC;

SELECT * FROM ranks;
SELECT * FROM units;
SELECT * FROM missions;
SELECT * FROM soldiers;
SELECT * FROM soldier_missions;
SELECT * FROM v_soldier_profile;
