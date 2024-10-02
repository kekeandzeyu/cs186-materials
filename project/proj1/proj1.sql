-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %' 
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear 
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid
  FROM people AS p
  INNER JOIN HallofFame AS h ON p.playerid = h.playerid
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC, h.playerid ASC;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, cp.schoolid, h.yearid
  FROM people AS p
  INNER JOIN HallofFame AS h ON p.playerid = h.playerid
  INNER JOIN CollegePlaying AS cp ON p.playerid = cp.playerid
  INNER JOIN Schools AS s ON cp.schoolid = s.schoolid
  WHERE h.inducted = 'Y' AND s.schoolState = 'CA'
  ORDER BY h.yearid DESC, cp.schoolid ASC, p.playerid ASC;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, cp.schoolid
  FROM people AS p
  INNER JOIN HallofFame AS h ON p.playerid = h.playerid
  LEFT JOIN CollegePlaying AS cp ON p.playerid = cp.playerid
  WHERE h.inducted = 'Y'
  ORDER BY p.playerid DESC, cp.schoolid ASC;
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerid, p.namefirst, p.namelast, b.yearid, 
         CAST(b.H + b.H2B + 2 * b.H3B + 3 * b.HR AS REAL) / b.AB AS slg
  FROM batting AS b
  INNER JOIN people AS p ON b.playerid = p.playerid
  WHERE b.AB > 50
  ORDER BY slg DESC, b.yearid ASC, b.playerid ASC
  LIMIT 10;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, 
         CAST(SUM(b.H + b.H2B + 2 * b.H3B + 3 * b.HR) AS REAL) / SUM(b.AB) AS lslg
  FROM batting AS b
  INNER JOIN people AS p ON b.playerid = p.playerid
  GROUP BY p.playerid, p.namefirst, p.namelast
  HAVING SUM(b.AB) > 50
  ORDER BY lslg DESC, p.playerid ASC
  LIMIT 10;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.namefirst, p.namelast, 
         CAST(SUM(b.H + b.H2B + 2 * b.H3B + 3 * b.HR) AS REAL) / SUM(b.AB) AS lslg
  FROM batting AS b
  INNER JOIN people AS p ON b.playerid = p.playerid
  GROUP BY p.playerid, p.namefirst, p.namelast
  HAVING SUM(b.AB) > 50
  AND lslg > (SELECT CAST(SUM(b2.H + b2.H2B + 2 * b2.H3B + 3 * b2.HR) AS REAL) / SUM(b2.AB)
              FROM batting AS b2
              WHERE b2.playerid = 'mayswi01')
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid ASC;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH range AS (
        SELECT MIN(salary) AS lowest, MAX(salary) AS highest, CAST (((MAX(salary) - MIN(salary))/10) AS INT) AS bucket FROM salaries where yearid = 2016
    )
    SELECT binid, lowest + binid * bucket, lowest + (binid + 1) * bucket, count(*)
    FROM binids b, salaries s, range
    WHERE (salary between lowest + binid * bucket and lowest + (binid + 1) * bucket)
    AND yearid = 2016
    GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s1.yearid, 
         MIN(s1.salary) - MIN(s2.salary),
         MAX(s1.salary) - MAX(s2.salary),
         AVG(s1.salary) - AVG(s2.salary)
  FROM salaries AS s1
  INNER JOIN salaries AS s2 ON s1.yearid = s2.yearid + 1
  GROUP BY s1.yearid
  ORDER BY s1.yearid ASC;
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT s.playerid, p.namefirst, p.namelast, s.salary, s.yearid
  FROM salaries AS s
  INNER JOIN people AS p ON s.playerid = p.playerid
  WHERE s.yearid = 2000 AND s.salary = (SELECT MAX(salary) FROM salaries WHERE yearid = 2000)
     OR s.yearid = 2001 AND s.salary = (SELECT MAX(salary) FROM salaries WHERE yearid = 2001);
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary) AS diffAvg
  FROM allstarfull AS a
  INNER JOIN salaries AS s ON a.playerid = s.playerid AND a.yearid = s.yearid
  WHERE a.yearid = 2016
  GROUP BY a.teamid;
;

