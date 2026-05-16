-- ================================================================
--  SMART CITY — FIXED DATABASE SCRIPT
--  Kya hard-coded hai vs kya dynamic hai:
--
--  HARD-CODED (admin change nahi karta):
--    - LOCATIONS (Sector A-F) — city fixed hai
--    - DEPARTMENTS (Roads, Water etc) — govt fixed hai
--    - RESOURCES initial setup — sirf qty change hoti hai
--
--  DYNAMIC (user/admin karta hai at runtime):
--    - USERS — register karo
--    - COMPLAINTS — citizens submit karte hain
--    - REPORTS — admin generate karta hai
--    - resource allocated_qty — admin allocate karta hai
-- ================================================================


-- ================================================
-- STEP 1: CLEAN DROP (pehle run karo)
-- ================================================

DROP VIEW vw_resource_overview;
DROP VIEW vw_user_summary;
DROP VIEW vw_dept_performance;
DROP VIEW vw_area_analytics;
DROP VIEW vw_complaints_full;

DROP TABLE REPORTS     CASCADE CONSTRAINTS PURGE;
DROP TABLE RESOURCES   CASCADE CONSTRAINTS PURGE;
DROP TABLE COMPLAINTS  CASCADE CONSTRAINTS PURGE;
DROP TABLE USERS       CASCADE CONSTRAINTS PURGE;
DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS PURGE;
DROP TABLE LOCATIONS   CASCADE CONSTRAINTS PURGE;

DROP SEQUENCE location_seq;
DROP SEQUENCE dept_seq;
DROP SEQUENCE users_seq;
DROP SEQUENCE complaint_seq;
DROP SEQUENCE resource_seq;
DROP SEQUENCE report_seq;

DROP PROCEDURE sp_resolve_complaint;
DROP PROCEDURE sp_register_user;
DROP PROCEDURE sp_submit_complaint;
DROP PROCEDURE sp_allocate_resource;
DROP PROCEDURE sp_generate_report;

COMMIT;


-- ================================================
-- STEP 2: SEQUENCES
-- ================================================

CREATE SEQUENCE location_seq  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE dept_seq      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE users_seq     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE complaint_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE resource_seq  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE report_seq    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;


-- ================================================
-- STEP 3: TABLES
-- ================================================

-- Table 1: LOCATIONS (hard-coded — city sectors fixed)
CREATE TABLE LOCATIONS (
  area_id    NUMBER(10)    NOT NULL,
  area_name  VARCHAR2(60)  NOT NULL,
  zone       VARCHAR2(30)  NOT NULL,
  population NUMBER(10)    DEFAULT 0,
  latitude   NUMBER(10,6),
  longitude  NUMBER(10,6),
  created_at DATE          DEFAULT SYSDATE,
  CONSTRAINT pk_locations PRIMARY KEY (area_id),
  CONSTRAINT chk_zone CHECK (
    zone IN ('North','South','East','West','Central')
  )
);

-- Table 2: DEPARTMENTS (hard-coded — govt departments fixed)
CREATE TABLE DEPARTMENTS (
  dept_id       NUMBER(10)    NOT NULL,
  dept_name     VARCHAR2(60)  NOT NULL,
  head_officer  VARCHAR2(100),
  contact_email VARCHAR2(100),
  budget        NUMBER(14,2)  DEFAULT 0,
  spent         NUMBER(14,2)  DEFAULT 0,
  total_complaints NUMBER     DEFAULT 0,
  created_at    DATE          DEFAULT SYSDATE,
  CONSTRAINT pk_departments PRIMARY KEY (dept_id),
  CONSTRAINT uq_dept_email  UNIQUE (contact_email),
  CONSTRAINT chk_budget     CHECK (budget >= 0),
  CONSTRAINT chk_spent      CHECK (spent  >= 0)
);

-- Table 3: USERS (dynamic — users register karte hain)
CREATE TABLE USERS (
  user_id       NUMBER(10)    NOT NULL,
  full_name     VARCHAR2(100) NOT NULL,
  email         VARCHAR2(100) NOT NULL,
  password_hash VARCHAR2(255) NOT NULL,
  user_role     VARCHAR2(20)  DEFAULT 'citizen',
  area_id       NUMBER(10),
  phone         VARCHAR2(20),
  profile_pic   VARCHAR2(255),
  is_active     NUMBER(1)     DEFAULT 1,
  created_at    DATE          DEFAULT SYSDATE,
  last_login    DATE,
  CONSTRAINT pk_users      PRIMARY KEY (user_id),
  CONSTRAINT uq_user_email UNIQUE (email),
  CONSTRAINT fk_user_area  FOREIGN KEY (area_id)
    REFERENCES LOCATIONS(area_id) ON DELETE SET NULL,
  CONSTRAINT chk_user_role CHECK (
    user_role IN ('admin','officer','citizen')
  ),
  CONSTRAINT chk_is_active CHECK (is_active IN (0,1))
);

-- Table 4: COMPLAINTS (dynamic — citizens submit karte hain)
CREATE TABLE COMPLAINTS (
  complaint_id  NUMBER(10)    NOT NULL,
  user_id       NUMBER(10)    NOT NULL,
  dept_id       NUMBER(10)    NOT NULL,
  area_id       NUMBER(10)    NOT NULL,
  title         VARCHAR2(120) NOT NULL,
  description   VARCHAR2(800),
  image_url     VARCHAR2(255),
  comp_status   VARCHAR2(20)  DEFAULT 'Open',
  priority      VARCHAR2(10)  DEFAULT 'Medium',
  feedback      VARCHAR2(300),
  rating        NUMBER(1),
  created_at    DATE          DEFAULT SYSDATE,
  updated_at    DATE          DEFAULT SYSDATE,
  resolved_at   DATE,
  CONSTRAINT pk_complaints   PRIMARY KEY (complaint_id),
  CONSTRAINT fk_comp_user    FOREIGN KEY (user_id)
    REFERENCES USERS(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_comp_dept    FOREIGN KEY (dept_id)
    REFERENCES DEPARTMENTS(dept_id),
  CONSTRAINT fk_comp_area    FOREIGN KEY (area_id)
    REFERENCES LOCATIONS(area_id),
  CONSTRAINT chk_comp_status CHECK (comp_status IN
    ('Open','In Progress','Resolved','Closed')),
  CONSTRAINT chk_priority    CHECK (
    priority IN ('High','Medium','Low')
  ),
  CONSTRAINT chk_rating      CHECK (
    rating IS NULL OR rating BETWEEN 1 AND 5
  ),
  CONSTRAINT chk_resolved    CHECK (
    resolved_at IS NULL OR resolved_at >= created_at
  )
);

-- Table 5: RESOURCES (semi-hard-coded — types fixed, qty dynamic)
CREATE TABLE RESOURCES (
  resource_id   NUMBER(10)    NOT NULL,
  res_name      VARCHAR2(100) NOT NULL,
  icon          VARCHAR2(10)  DEFAULT 'R',
  dept_id       NUMBER(10)    NOT NULL,
  total_qty     NUMBER(6)     DEFAULT 0,
  allocated_qty NUMBER(6)     DEFAULT 0,
  unit          VARCHAR2(30)  DEFAULT 'units',
  res_status    VARCHAR2(20)  DEFAULT 'Available',
  updated_at    DATE          DEFAULT SYSDATE,
  CONSTRAINT pk_resources    PRIMARY KEY (resource_id),
  CONSTRAINT fk_res_dept     FOREIGN KEY (dept_id)
    REFERENCES DEPARTMENTS(dept_id) ON DELETE CASCADE,
  CONSTRAINT chk_res_status  CHECK (
    res_status IN ('Available','Low','Depleted')
  ),
  CONSTRAINT chk_alloc_total CHECK (allocated_qty <= total_qty),
  CONSTRAINT chk_total_pos   CHECK (total_qty >= 0)
);

-- Table 6: REPORTS (dynamic — admin generate karta hai)
CREATE TABLE REPORTS (
  report_id    NUMBER(10)    NOT NULL,
  title        VARCHAR2(120) NOT NULL,
  generated_by NUMBER(10),
  report_type  VARCHAR2(40)  DEFAULT 'general',
  created_at   DATE          DEFAULT SYSDATE,
  summary_data CLOB,
  CONSTRAINT pk_reports      PRIMARY KEY (report_id),
  CONSTRAINT fk_report_user  FOREIGN KEY (generated_by)
    REFERENCES USERS(user_id) ON DELETE SET NULL,
  CONSTRAINT chk_report_type CHECK (report_type IN (
    'general','complaints','budget','resources','traffic'
  ))
);


-- ================================================
-- STEP 4: ALTER TABLE (DDL concept demo)
-- ================================================

ALTER TABLE COMPLAINTS ADD is_anonymous NUMBER(1) DEFAULT 0;
ALTER TABLE COMPLAINTS ADD CONSTRAINT chk_anon
  CHECK (is_anonymous IN (0,1));


-- ================================================
-- STEP 5: INDEXES
-- ================================================

CREATE INDEX idx_users_email         ON USERS(email);
CREATE INDEX idx_users_role          ON USERS(user_role);
CREATE INDEX idx_complaints_status   ON COMPLAINTS(comp_status);
CREATE INDEX idx_complaints_priority ON COMPLAINTS(priority);
CREATE INDEX idx_complaints_area     ON COMPLAINTS(area_id);
CREATE INDEX idx_complaints_dept     ON COMPLAINTS(dept_id);
CREATE INDEX idx_complaints_user     ON COMPLAINTS(user_id);
CREATE INDEX idx_complaints_date     ON COMPLAINTS(created_at);
CREATE INDEX idx_resources_dept      ON RESOURCES(dept_id);
CREATE INDEX idx_resources_status    ON RESOURCES(res_status);


-- ================================================
-- STEP 6: TRIGGERS
-- ================================================

-- Auto ID triggers
CREATE OR REPLACE TRIGGER trg_location_id
BEFORE INSERT ON LOCATIONS FOR EACH ROW
BEGIN
  IF :NEW.area_id IS NULL THEN
    :NEW.area_id := location_seq.NEXTVAL;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_dept_id
BEFORE INSERT ON DEPARTMENTS FOR EACH ROW
BEGIN
  IF :NEW.dept_id IS NULL THEN
    :NEW.dept_id := dept_seq.NEXTVAL;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_user_id
BEFORE INSERT ON USERS FOR EACH ROW
BEGIN
  IF :NEW.user_id IS NULL THEN
    :NEW.user_id := users_seq.NEXTVAL;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_complaint_id
BEFORE INSERT ON COMPLAINTS FOR EACH ROW
BEGIN
  IF :NEW.complaint_id IS NULL THEN
    :NEW.complaint_id := complaint_seq.NEXTVAL;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_resource_id
BEFORE INSERT ON RESOURCES FOR EACH ROW
BEGIN
  IF :NEW.resource_id IS NULL THEN
    :NEW.resource_id := resource_seq.NEXTVAL;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_report_id
BEFORE INSERT ON REPORTS FOR EACH ROW
BEGIN
  IF :NEW.report_id IS NULL THEN
    :NEW.report_id := report_seq.NEXTVAL;
  END IF;
END;
/

-- Business trigger: auto resolved_at jab status = Resolved
CREATE OR REPLACE TRIGGER trg_auto_resolve_date
BEFORE UPDATE ON COMPLAINTS FOR EACH ROW
BEGIN
  IF :NEW.comp_status = 'Resolved'
     AND :OLD.comp_status != 'Resolved' THEN
    :NEW.resolved_at := SYSDATE;
  END IF;
  :NEW.updated_at := SYSDATE;
END;
/

-- Business trigger: resource status auto calculate
CREATE OR REPLACE TRIGGER trg_resource_status
BEFORE INSERT OR UPDATE ON RESOURCES FOR EACH ROW
BEGIN
  IF :NEW.allocated_qty >= :NEW.total_qty THEN
    :NEW.res_status := 'Depleted';
  ELSIF :NEW.allocated_qty >= :NEW.total_qty * 0.8 THEN
    :NEW.res_status := 'Low';
  ELSE
    :NEW.res_status := 'Available';
  END IF;
  :NEW.updated_at := SYSDATE;
END;
/

-- Business trigger: dept complaint counter
CREATE OR REPLACE TRIGGER trg_dept_comp_count
AFTER INSERT OR DELETE ON COMPLAINTS FOR EACH ROW
BEGIN
  IF INSERTING THEN
    UPDATE DEPARTMENTS
    SET total_complaints = total_complaints + 1
    WHERE dept_id = :NEW.dept_id;
  ELSIF DELETING THEN
    UPDATE DEPARTMENTS
    SET total_complaints = total_complaints - 1
    WHERE dept_id = :OLD.dept_id;
  END IF;
END;
/


-- ================================================
-- STEP 7: VIEWS
-- ================================================

-- View 1: Full complaint details (4 tables JOIN)
CREATE OR REPLACE VIEW vw_complaints_full AS
SELECT
  c.complaint_id,
  c.title,
  c.description,
  c.comp_status      AS status,
  c.priority,
  c.created_at,
  c.resolved_at,
  c.feedback,
  c.rating,
  u.full_name        AS citizen_name,
  u.email            AS citizen_email,
  u.phone            AS citizen_phone,
  l.area_name,
  l.zone,
  d.dept_name        AS department,
  d.head_officer,
  NVL(TO_CHAR(c.resolved_at,'DD-MON-YYYY'),
      'Pending') AS resolution_date,
  CASE c.priority
    WHEN 'High'   THEN 3
    WHEN 'Medium' THEN 2
    ELSE               1
  END AS priority_rank
FROM COMPLAINTS  c
JOIN USERS       u ON c.user_id = u.user_id
JOIN LOCATIONS   l ON c.area_id = l.area_id
JOIN DEPARTMENTS d ON c.dept_id = d.dept_id;


-- View 2: Area-wise analytics (COUNT + GROUP BY)
CREATE OR REPLACE VIEW vw_area_analytics AS
SELECT
  l.area_id,
  l.area_name,
  l.zone,
  l.population,
  COUNT(c.complaint_id) AS total_complaints,
  SUM(CASE WHEN c.comp_status='Open'
      THEN 1 ELSE 0 END) AS open_count,
  SUM(CASE WHEN c.comp_status='In Progress'
      THEN 1 ELSE 0 END) AS inprog_count,
  SUM(CASE WHEN c.comp_status='Resolved'
      THEN 1 ELSE 0 END) AS resolved_count,
  SUM(CASE WHEN c.priority='High'
      THEN 1 ELSE 0 END) AS high_priority,
  ROUND(
    SUM(CASE WHEN c.comp_status='Resolved'
        THEN 1 ELSE 0 END)
    / NULLIF(COUNT(c.complaint_id),0) * 100, 1
  ) AS resolution_pct
FROM LOCATIONS l
LEFT JOIN COMPLAINTS c ON l.area_id = c.area_id
GROUP BY l.area_id, l.area_name, l.zone, l.population;


-- View 3: Department performance (JOIN + AVG + SUM)
CREATE OR REPLACE VIEW vw_dept_performance AS
SELECT
  d.dept_id,
  d.dept_name        AS department,
  d.head_officer,
  d.budget,
  d.spent,
  ROUND((d.spent / NULLIF(d.budget,0))*100,1) AS budget_used_pct,
  d.budget - d.spent AS budget_remaining,
  COUNT(c.complaint_id) AS total_complaints,
  SUM(CASE WHEN c.comp_status='Resolved'
      THEN 1 ELSE 0 END) AS resolved,
  SUM(CASE WHEN c.comp_status='Open'
      THEN 1 ELSE 0 END) AS open_count,
  SUM(CASE WHEN c.comp_status='In Progress'
      THEN 1 ELSE 0 END) AS in_progress,
  ROUND(AVG(
    CASE WHEN c.resolved_at IS NOT NULL
    THEN (c.resolved_at - c.created_at) * 24 END
  ),2) AS avg_resolution_hours
FROM DEPARTMENTS d
LEFT JOIN COMPLAINTS c ON d.dept_id = c.dept_id
GROUP BY d.dept_id, d.dept_name,
         d.head_officer, d.budget, d.spent;


-- View 4: User summary (LEFT JOIN)
CREATE OR REPLACE VIEW vw_user_summary AS
SELECT
  u.user_id,
  u.full_name,
  u.email,
  u.user_role,
  u.phone,
  NVL(l.area_name,'Not assigned') AS area,
  NVL(l.zone,'-')                 AS zone,
  u.created_at,
  NVL(TO_CHAR(u.last_login,
      'DD-MON-YYYY'),'Never')     AS last_login,
  COUNT(c.complaint_id)           AS total_complaints,
  SUM(CASE WHEN c.comp_status='Resolved'
      THEN 1 ELSE 0 END)          AS resolved_complaints
FROM USERS u
LEFT JOIN LOCATIONS  l ON u.area_id = l.area_id
LEFT JOIN COMPLAINTS c ON u.user_id = c.user_id
WHERE u.is_active = 1
GROUP BY u.user_id, u.full_name, u.email,
         u.user_role, u.phone, l.area_name,
         l.zone, u.created_at, u.last_login;


-- View 5: Resource overview
CREATE OR REPLACE VIEW vw_resource_overview AS
SELECT
  r.resource_id,
  r.res_name    AS resource_name,
  r.icon,
  d.dept_name   AS department,
  r.total_qty,
  r.allocated_qty,
  r.total_qty - r.allocated_qty AS available_qty,
  r.unit,
  r.res_status  AS status,
  ROUND((r.allocated_qty /
         NULLIF(r.total_qty,0))*100,1) AS utilization_pct
FROM RESOURCES   r
JOIN DEPARTMENTS d ON r.dept_id = d.dept_id;


-- ================================================
-- STEP 8: STORED PROCEDURES
-- ================================================

-- Procedure 1: Citizen complaint submit kare
CREATE OR REPLACE PROCEDURE sp_submit_complaint(
  p_user_id     IN NUMBER,
  p_dept_id     IN NUMBER,
  p_area_id     IN NUMBER,
  p_title       IN VARCHAR2,
  p_description IN VARCHAR2,
  p_priority    IN VARCHAR2 DEFAULT 'Medium',
  p_new_id      OUT NUMBER
) AS
BEGIN
  INSERT INTO COMPLAINTS(
    user_id, dept_id, area_id,
    title, description, priority
  ) VALUES (
    p_user_id, p_dept_id, p_area_id,
    TRIM(p_title),
    TRIM(p_description),
    NVL(p_priority,'Medium')
  ) RETURNING complaint_id INTO p_new_id;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Complaint #' || p_new_id || ' submitted.');
EXCEPTION
  WHEN OTHERS THEN ROLLBACK; RAISE;
END sp_submit_complaint;
/


-- Procedure 2: Officer complaint resolve kare
CREATE OR REPLACE PROCEDURE sp_resolve_complaint(
  p_complaint_id IN NUMBER,
  p_feedback     IN VARCHAR2 DEFAULT NULL
) AS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM COMPLAINTS WHERE complaint_id = p_complaint_id;

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Complaint not found: ' || p_complaint_id);
  END IF;

  UPDATE COMPLAINTS
  SET  comp_status = 'Resolved',
       resolved_at = SYSDATE,
       updated_at  = SYSDATE,
       feedback    = NVL(p_feedback, feedback)
  WHERE complaint_id = p_complaint_id;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Complaint #' ||
    p_complaint_id || ' resolved.');
EXCEPTION
  WHEN OTHERS THEN ROLLBACK; RAISE;
END sp_resolve_complaint;
/


-- Procedure 3: New user register kare
CREATE OR REPLACE PROCEDURE sp_register_user(
  p_name     IN VARCHAR2,
  p_email    IN VARCHAR2,
  p_password IN VARCHAR2,
  p_area_id  IN NUMBER,
  p_role     IN VARCHAR2 DEFAULT 'citizen',
  p_new_id   OUT NUMBER
) AS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM USERS WHERE email = LOWER(TRIM(p_email));

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20002,
      'Email already registered: ' || p_email);
  END IF;

  INSERT INTO USERS(
    full_name, email, password_hash, user_role, area_id
  ) VALUES (
    TRIM(p_name),
    LOWER(TRIM(p_email)),
    p_password,
    NVL(p_role,'citizen'),
    p_area_id
  ) RETURNING user_id INTO p_new_id;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('User #' || p_new_id || ' registered.');
EXCEPTION
  WHEN OTHERS THEN ROLLBACK; RAISE;
END sp_register_user;
/


-- Procedure 4: Admin resource allocate kare
CREATE OR REPLACE PROCEDURE sp_allocate_resource(
  p_resource_id IN NUMBER,
  p_qty         IN NUMBER
) AS
  v_total     NUMBER;
  v_allocated NUMBER;
BEGIN
  SELECT total_qty, allocated_qty
  INTO   v_total, v_allocated
  FROM   RESOURCES
  WHERE  resource_id = p_resource_id
  FOR UPDATE;

  IF v_allocated + p_qty > v_total THEN
    RAISE_APPLICATION_ERROR(-20003,
      'Not enough. Available: ' || (v_total - v_allocated));
  END IF;

  UPDATE RESOURCES
  SET allocated_qty = allocated_qty + p_qty
  WHERE resource_id = p_resource_id;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Allocated ' || p_qty || ' units.');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20004,
      'Resource not found: ' || p_resource_id);
  WHEN OTHERS THEN ROLLBACK; RAISE;
END sp_allocate_resource;
/


-- Procedure 5: Admin report generate kare
CREATE OR REPLACE PROCEDURE sp_generate_report(
  p_title   IN VARCHAR2,
  p_type    IN VARCHAR2,
  p_user_id IN NUMBER,
  p_new_id  OUT NUMBER
) AS
  v_total    NUMBER;
  v_open     NUMBER;
  v_resolved NUMBER;
  v_summary  VARCHAR2(500);
BEGIN
  SELECT COUNT(*) INTO v_total
  FROM COMPLAINTS;
  SELECT COUNT(*) INTO v_open
  FROM COMPLAINTS WHERE comp_status = 'Open';
  SELECT COUNT(*) INTO v_resolved
  FROM COMPLAINTS WHERE comp_status = 'Resolved';

  v_summary :=
    'Total: '    || v_total    || ' | ' ||
    'Open: '     || v_open     || ' | ' ||
    'Resolved: ' || v_resolved || ' | ' ||
    'Date: ' || TO_CHAR(SYSDATE,'DD-MON-YYYY');

  INSERT INTO REPORTS(
    title, generated_by, report_type, summary_data
  ) VALUES (
    p_title, p_user_id, p_type, v_summary
  ) RETURNING report_id INTO p_new_id;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Report #' || p_new_id || ' created.');
EXCEPTION
  WHEN OTHERS THEN ROLLBACK; RAISE;
END sp_generate_report;
/


-- ================================================
-- STEP 9: HARD-CODED SEED DATA
-- (Yeh sirf ek baar insert hota hai — change nahi hota)
-- ================================================

-- ── LOCATIONS (city sectors — fixed) ──────────────
INSERT INTO LOCATIONS(area_id,area_name,zone,population,latitude,longitude)
VALUES(location_seq.NEXTVAL,'Sector A','North',45000,31.4300,73.0800);

INSERT INTO LOCATIONS(area_id,area_name,zone,population,latitude,longitude)
VALUES(location_seq.NEXTVAL,'Sector B','North',38000,31.4400,73.0900);

INSERT INTO LOCATIONS(area_id,area_name,zone,population,latitude,longitude)
VALUES(location_seq.NEXTVAL,'Sector C','South',52000,31.4100,73.0700);

INSERT INTO LOCATIONS(area_id,area_name,zone,population,latitude,longitude)
VALUES(location_seq.NEXTVAL,'Sector D','South',29000,31.4000,73.1000);

INSERT INTO LOCATIONS(area_id,area_name,zone,population,latitude,longitude)
VALUES(location_seq.NEXTVAL,'Sector E','East',61000,31.4500,73.1200);

INSERT INTO LOCATIONS(area_id,area_name,zone,population,latitude,longitude)
VALUES(location_seq.NEXTVAL,'Sector F','West',34000,31.4200,73.0500);


-- ── DEPARTMENTS (govt depts — fixed) ───────────────
INSERT INTO DEPARTMENTS(dept_id,dept_name,head_officer,contact_email,budget)
VALUES(dept_seq.NEXTVAL,'Roads','Engr. Imran',
  'roads@smartcity.pk',5000000);

INSERT INTO DEPARTMENTS(dept_id,dept_name,head_officer,contact_email,budget)
VALUES(dept_seq.NEXTVAL,'Electricity','Engr. Tariq',
  'elect@smartcity.pk',4000000);

INSERT INTO DEPARTMENTS(dept_id,dept_name,head_officer,contact_email,budget)
VALUES(dept_seq.NEXTVAL,'Water','Engr. Samina',
  'water@smartcity.pk',3500000);

INSERT INTO DEPARTMENTS(dept_id,dept_name,head_officer,contact_email,budget)
VALUES(dept_seq.NEXTVAL,'Sanitation','Engr. Farhan',
  'sanit@smartcity.pk',2800000);

INSERT INTO DEPARTMENTS(dept_id,dept_name,head_officer,contact_email,budget)
VALUES(dept_seq.NEXTVAL,'Environment','Dr. Ayesha',
  'enviro@smartcity.pk',2000000);

INSERT INTO DEPARTMENTS(dept_id,dept_name,head_officer,contact_email,budget)
VALUES(dept_seq.NEXTVAL,'Transport','Engr. Zahid',
  'transport@smartcity.pk',3200000);


-- ── RESOURCES (types fixed — qty admin changes) ────
-- dept_id: 1=Roads, 2=Elect, 3=Water, 4=Sanit, 5=Env, 6=Trans
INSERT INTO RESOURCES(resource_id,res_name,icon,dept_id,
  total_qty,allocated_qty,unit)
VALUES(resource_seq.NEXTVAL,'Road Repair Vehicles',
  'V',1,20,0,'units');

INSERT INTO RESOURCES(resource_id,res_name,icon,dept_id,
  total_qty,allocated_qty,unit)
VALUES(resource_seq.NEXTVAL,'Water Tankers',
  'W',3,15,0,'units');

INSERT INTO RESOURCES(resource_id,res_name,icon,dept_id,
  total_qty,allocated_qty,unit)
VALUES(resource_seq.NEXTVAL,'Electricity Teams',
  'E',2,10,0,'teams');

INSERT INTO RESOURCES(resource_id,res_name,icon,dept_id,
  total_qty,allocated_qty,unit)
VALUES(resource_seq.NEXTVAL,'Sanitation Workers',
  'S',4,80,0,'workers');

INSERT INTO RESOURCES(resource_id,res_name,icon,dept_id,
  total_qty,allocated_qty,unit)
VALUES(resource_seq.NEXTVAL,'Traffic Officers',
  'T',6,50,0,'officers');

INSERT INTO RESOURCES(resource_id,res_name,icon,dept_id,
  total_qty,allocated_qty,unit)
VALUES(resource_seq.NEXTVAL,'Environment Kits',
  'K',5,30,0,'kits');


-- ── ADMIN USER (ek fixed admin — system ka) ────────
INSERT INTO USERS(user_id,full_name,email,password_hash,
  user_role,area_id,phone)
VALUES(users_seq.NEXTVAL,'Super Admin','admin@smartcity.pk',
  'admin123','admin',1,'0300-0000000');
-- Note: In real app, password_hash = bcrypt output from Node.js


-- ── SAMPLE COMPLAINTS (testing ke liye) ────────────
-- Yeh dynamic data hai — real app mein citizens enter karte hain
-- Yahan sirf 5 sample hain demo ke liye

INSERT INTO COMPLAINTS(complaint_id,user_id,dept_id,area_id,
  title,description,comp_status,priority)
VALUES(complaint_seq.NEXTVAL,1,1,1,
  'Road Damage',
  'Large pothole near main bus stop causing accidents',
  'Open','High');

INSERT INTO COMPLAINTS(complaint_id,user_id,dept_id,area_id,
  title,description,comp_status,priority)
VALUES(complaint_seq.NEXTVAL,1,2,3,
  'Power Outage',
  'No electricity in Block 4 for over 6 hours',
  'In Progress','High');

INSERT INTO COMPLAINTS(complaint_id,user_id,dept_id,area_id,
  title,description,comp_status,priority)
VALUES(complaint_seq.NEXTVAL,1,3,2,
  'Water Pipe Leak',
  'Burst pipe flooding the main street near school',
  'Open','Medium');

INSERT INTO COMPLAINTS(complaint_id,user_id,dept_id,area_id,
  title,description,comp_status,priority)
VALUES(complaint_seq.NEXTVAL,1,4,4,
  'Garbage Dump',
  'Illegal garbage dump near school',
  'Resolved','Low');

INSERT INTO COMPLAINTS(complaint_id,user_id,dept_id,area_id,
  title,description,comp_status,priority)
VALUES(complaint_seq.NEXTVAL,1,6,2,
  'Traffic Signal Broken',
  'Traffic light stuck on red causing major backup',
  'Open','High');

-- Update dept spent (realistic values)
UPDATE DEPARTMENTS SET spent=3200000 WHERE dept_id=1;
UPDATE DEPARTMENTS SET spent=2800000 WHERE dept_id=2;
UPDATE DEPARTMENTS SET spent=2100000 WHERE dept_id=3;
UPDATE DEPARTMENTS SET spent=1900000 WHERE dept_id=4;
UPDATE DEPARTMENTS SET spent=1200000 WHERE dept_id=5;
UPDATE DEPARTMENTS SET spent=2400000 WHERE dept_id=6;

COMMIT;


-- ================================================
-- STEP 10: VERIFY
-- ================================================

-- Table row counts
SELECT 'LOCATIONS'   tbl, COUNT(*) rows FROM LOCATIONS   UNION ALL
SELECT 'DEPARTMENTS' tbl, COUNT(*) rows FROM DEPARTMENTS  UNION ALL
SELECT 'USERS'       tbl, COUNT(*) rows FROM USERS        UNION ALL
SELECT 'COMPLAINTS'  tbl, COUNT(*) rows FROM COMPLAINTS   UNION ALL
SELECT 'RESOURCES'   tbl, COUNT(*) rows FROM RESOURCES    UNION ALL
SELECT 'REPORTS'     tbl, COUNT(*) rows FROM REPORTS;

-- Views check
SELECT * FROM vw_complaints_full;
SELECT * FROM vw_area_analytics;
SELECT * FROM vw_dept_performance;
SELECT * FROM vw_user_summary;
SELECT * FROM vw_resource_overview;

-- ================================================
-- DYNAMIC QUERIES — jo Node.js backend use karega
-- ================================================

-- 1. Login check (Node.js call karega)
SELECT user_id, full_name, user_role, area_id
FROM   USERS
WHERE  email = 'admin@smartcity.pk'
AND    password_hash = 'admin123'
AND    is_active = 1;

-- 2. Get all complaints with details (frontend table)
SELECT * FROM vw_complaints_full ORDER BY created_at DESC;

-- 3. Filter complaints by status
SELECT * FROM vw_complaints_full
WHERE status = 'Open' ORDER BY priority_rank DESC;

-- 4. Filter complaints by area
SELECT * FROM vw_complaints_full
WHERE area_name = 'Sector A';

-- 5. Citizen apni complaints dekhe
SELECT * FROM vw_complaints_full
WHERE citizen_email = 'admin@smartcity.pk';

-- 6. Dashboard stat cards ke liye
SELECT
  COUNT(*)                                        AS total,
  SUM(CASE WHEN comp_status='Open'
      THEN 1 ELSE 0 END)                         AS open,
  SUM(CASE WHEN comp_status='Resolved'
      THEN 1 ELSE 0 END)                         AS resolved,
  SUM(CASE WHEN comp_status='In Progress'
      THEN 1 ELSE 0 END)                         AS in_progress
FROM COMPLAINTS;

-- 7. Test sp_resolve_complaint
BEGIN
  sp_resolve_complaint(4, 'Fixed by road team');
END;
/

-- 8. Test sp_allocate_resource
BEGIN
  sp_allocate_resource(1, 5);
END;
/

-- All resources with updated status
SELECT * FROM vw_resource_overview;

-- ================================================
-- END
-- ================================================