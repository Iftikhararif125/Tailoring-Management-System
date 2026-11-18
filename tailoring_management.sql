
-- =====================================================
-- PROJECT: TAILORING MANAGEMENT SYSTEM
-- DATABASE: tailoring_management
-- DBMS: MySQL 8.0+
-- =====================================================

CREATE DATABASE IF NOT EXISTS tailoring_management
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tailoring_management;

-- =====================================================
-- 1. CUSTOMER TABLE
-- =====================================================

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- 2. TAILOR TABLE
-- =====================================================

CREATE TABLE tailors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    specialization VARCHAR(255),
    work_area VARCHAR(255),
    address VARCHAR(255),
    phone_number VARCHAR(20),
    email VARCHAR(255) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- 3. DESIGNER TABLE
-- =====================================================

CREATE TABLE designers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    specialization VARCHAR(255),
    address VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- 4. DESIGNER-TAILOR RELATIONSHIP TABLE
-- Many-to-Many Relationship
-- =====================================================

CREATE TABLE designer_tailor (
    designer_id INT NOT NULL,
    tailor_id INT NOT NULL,
    role VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,

    PRIMARY KEY (designer_id, tailor_id),

    CONSTRAINT fk_dt_designer
        FOREIGN KEY (designer_id)
        REFERENCES designers(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_dt_tailor
        FOREIGN KEY (tailor_id)
        REFERENCES tailors(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_dt_dates
        CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- =====================================================
-- 5. TAILOR-CUSTOMER RELATIONSHIP TABLE
-- Many-to-Many Relationship
-- =====================================================

CREATE TABLE tailor_customer (
    tailor_id INT NOT NULL,
    customer_id INT NOT NULL,
    relationship_type VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,

    PRIMARY KEY (tailor_id, customer_id),

    CONSTRAINT fk_tc_tailor
        FOREIGN KEY (tailor_id)
        REFERENCES tailors(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_tc_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_tc_dates
        CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- =====================================================
-- 6. CUSTOMER-DESIGNER RELATIONSHIP TABLE
-- Many-to-Many Relationship
-- =====================================================

CREATE TABLE customer_designer (
    customer_id INT NOT NULL,
    designer_id INT NOT NULL,
    role VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,

    PRIMARY KEY (customer_id, designer_id),

    CONSTRAINT fk_cd_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_cd_designer
        FOREIGN KEY (designer_id)
        REFERENCES designers(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_cd_dates
        CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- =====================================================
-- 7. INDEXES
-- =====================================================

CREATE INDEX idx_designer_tailor_tailor
    ON designer_tailor(tailor_id);

CREATE INDEX idx_tailor_customer_customer
    ON tailor_customer(customer_id);

CREATE INDEX idx_customer_designer_designer
    ON customer_designer(designer_id);

-- =====================================================
-- 8. SAMPLE DATA
-- =====================================================

INSERT INTO customers
(email, first_name, last_name, phone_number)
VALUES
('ahmad@example.com', 'Ahmad', 'Ali', '03001234567'),
('sara@example.com', 'Sara', 'Khan', '03007654321'),
('usman@example.com', 'Usman', 'Ahmed', '03001112223');

INSERT INTO tailors
(specialization, work_area, address, phone_number,
 email, first_name, last_name)
VALUES
('Traditional Clothing', 'Menswear', 'Yazd, Iran',
 '09120000001', 'tailor1@example.com', 'Ali', 'Reza'),
('Formal Clothing', 'Menswear and Womenswear', 'Tehran, Iran',
 '09120000002', 'tailor2@example.com', 'Hassan', 'Karimi');

INSERT INTO designers
(specialization, address, email, phone_number,
 first_name, last_name)
VALUES
('Fashion Design', 'Yazd, Iran',
 'designer1@example.com', '09120000003', 'Maryam', 'Ahmadi'),
('Wedding Dress Design', 'Tehran, Iran',
 'designer2@example.com', '09120000004', 'Fatemeh', 'Hosseini');

-- Designer-Tailor relationships
INSERT INTO designer_tailor
(designer_id, tailor_id, role, start_date, end_date)
VALUES
(1, 1, 'Design Consultant', '2026-01-01', NULL),
(2, 2, 'Design Specialist', '2026-02-01', NULL);

-- Tailor-Customer relationships
INSERT INTO tailor_customer
(tailor_id, customer_id, relationship_type, start_date, end_date)
VALUES
(1, 1, 'Regular Customer', '2026-01-10', NULL),
(2, 2, 'New Customer', '2026-02-15', NULL),
(1, 3, 'Regular Customer', '2026-03-01', NULL);

-- Customer-Designer relationships
INSERT INTO customer_designer
(customer_id, designer_id, role, start_date, end_date)
VALUES
(1, 1, 'Custom Design', '2026-01-15', NULL),
(2, 2, 'Wedding Design', '2026-02-20', NULL);

-- =====================================================
-- 9. TEST QUERIES
-- =====================================================

-- Display all customers
SELECT * FROM customers;

-- Display all tailors
SELECT * FROM tailors;

-- Display all designers
SELECT * FROM designers;

-- Show customers with their tailors
SELECT
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    t.first_name AS tailor_first_name,
    t.last_name AS tailor_last_name,
    tc.relationship_type,
    tc.start_date
FROM tailor_customer tc
JOIN customers c ON tc.customer_id = c.id
JOIN tailors t ON tc.tailor_id = t.id;

-- Show designers working with tailors
SELECT
    d.first_name AS designer_first_name,
    d.last_name AS designer_last_name,
    t.first_name AS tailor_first_name,
    t.last_name AS tailor_last_name,
    dt.role
FROM designer_tailor dt
JOIN designers d ON dt.designer_id = d.id
JOIN tailors t ON dt.tailor_id = t.id;

-- Show customers connected with designers
SELECT
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    d.first_name AS designer_first_name,
    d.last_name AS designer_last_name,
    cd.role
FROM customer_designer cd
JOIN customers c ON cd.customer_id = c.id
JOIN designers d ON cd.designer_id = d.id;

-- =====================================================
-- END OF PROJECT
-- =====================================================
