
-- queries.sql
-- Useful queries for reports and verification

-- 1. Customer accounts and balances
SELECT c.customer_id, c.first_name, c.last_name, a.account_id, a.account_type, a.balance, a.currency
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
ORDER BY c.customer_id;

-- 2. Recent transactions for an account
SELECT * FROM transactions WHERE account_id = 1 ORDER BY txn_at DESC LIMIT 20;

-- 3. Branch deposit totals (last 30 days)
SELECT b.branch_id, b.name, SUM(t.amount) AS total_deposits
FROM branches b
JOIN accounts a ON a.branch_id = b.branch_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.txn_type = 'DEPOSIT' AND t.txn_at >= NOW() - INTERVAL '30 days'
GROUP BY b.branch_id, b.name
ORDER BY total_deposits DESC;

-- 4. Overdrawn accounts (balance < 0)
SELECT account_id, customer_id, balance FROM accounts WHERE balance < 0;

-- 5. Loan outstanding summary
SELECT l.loan_id, l.account_id, a.customer_id, a.balance, l.principal, l.outstanding, l.interest_rate
FROM loans l JOIN accounts a ON a.account_id = l.account_id;
