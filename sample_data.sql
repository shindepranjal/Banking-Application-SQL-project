
-- sample_data.sql
-- Example seed data for the banking application

-- Branches
INSERT INTO branches (name, address, phone) VALUES
('Central Branch', '100 Main St, Metropolis', '555-0100'),
('North Branch', '22 North Ave, Metropolis', '555-0110');

-- Customers
INSERT INTO customers (first_name, last_name, email, phone, dob) VALUES
('Asha', 'Kumar', 'asha.kumar@example.com', '+91-9876501001', '1988-04-12'),
('Ravi', 'Patel', 'ravi.patel@example.com', '+91-9876501002', '1990-09-08');

-- Employees
INSERT INTO employees (branch_id, first_name, last_name, role, email, hired_at) VALUES
(1, 'Priya', 'Singh', 'Teller', 'priya.singh@bank.example', '2019-02-15'),
(1, 'Deepak', 'Shah', 'Manager', 'deepak.shah@bank.example', '2016-11-01');

-- Accounts
INSERT INTO accounts (customer_id, branch_id, account_type, currency, balance) VALUES
(1, 1, 'SAVINGS', 'INR', 50000.00),
(2, 1, 'SAVINGS', 'INR', 150000.00);

-- Transactions (initial deposits)
INSERT INTO transactions (account_id, txn_type, amount, balance_after, performed_by, description) VALUES
(1, 'DEPOSIT', 50000.00, 50000.00, 1, 'Initial deposit'),
(2, 'DEPOSIT', 150000.00, 150000.00, 1, 'Initial deposit');
