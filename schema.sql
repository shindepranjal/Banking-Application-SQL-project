
-- schema.sql
-- Banking application schema (compatible with PostgreSQL / adaptable to MySQL)
-- Create schema, tables, constraints and indexes

CREATE TABLE branches (
    branch_id      SERIAL PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    address        TEXT,
    phone          VARCHAR(20),
    created_at     TIMESTAMP DEFAULT NOW()
);

CREATE TABLE customers (
    customer_id    SERIAL PRIMARY KEY,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(200) UNIQUE,
    phone          VARCHAR(20),
    dob            DATE,
    created_at     TIMESTAMP DEFAULT NOW()
);

CREATE TABLE employees (
    employee_id    SERIAL PRIMARY KEY,
    branch_id      INTEGER REFERENCES branches(branch_id) ON DELETE SET NULL,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    role           VARCHAR(50),
    email          VARCHAR(200) UNIQUE,
    hired_at       DATE,
    created_at     TIMESTAMP DEFAULT NOW()
);

CREATE TABLE accounts (
    account_id     SERIAL PRIMARY KEY,
    customer_id    INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    branch_id      INTEGER REFERENCES branches(branch_id),
    account_type   VARCHAR(30) NOT NULL, -- 'SAVINGS', 'CURRENT', 'LOAN', 'FIXED'
    currency       CHAR(3) DEFAULT 'USD',
    balance        NUMERIC(18,2) DEFAULT 0.00,
    is_active      BOOLEAN DEFAULT TRUE,
    opened_at      TIMESTAMP DEFAULT NOW()
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id     INTEGER NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    related_account_id INTEGER, -- for transfers
    txn_type       VARCHAR(20) NOT NULL, -- 'DEPOSIT','WITHDRAW','TRANSFER','FEE','INTEREST','PAYMENT'
    amount         NUMERIC(18,2) NOT NULL CHECK (amount >= 0),
    balance_after  NUMERIC(18,2),
    performed_by   INTEGER REFERENCES employees(employee_id),
    txn_at         TIMESTAMP DEFAULT NOW(),
    description    TEXT
);

CREATE TABLE loans (
    loan_id        SERIAL PRIMARY KEY,
    account_id     INTEGER NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    principal      NUMERIC(18,2) NOT NULL,
    interest_rate  NUMERIC(5,4) NOT NULL, -- e.g., 0.0750 for 7.5%
    started_at     DATE,
    term_months    INTEGER,
    outstanding    NUMERIC(18,2)
);

CREATE TABLE cards (
    card_id        SERIAL PRIMARY KEY,
    account_id     INTEGER NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    card_number    VARCHAR(19) UNIQUE,
    card_type      VARCHAR(20), -- 'DEBIT','CREDIT'
    expiry_month   INTEGER,
    expiry_year    INTEGER,
    is_active      BOOLEAN DEFAULT TRUE,
    created_at     TIMESTAMP DEFAULT NOW()
);

-- Important indexes
CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_txn_account ON transactions(account_id);
CREATE INDEX idx_txn_txnat ON transactions(txn_at);
