
-- stored_procedures.sql
-- NOTE: The following uses PostgreSQL PL/pgSQL syntax. Adapt for MySQL/SQL Server if required.

-- Create account (returns new account id)
CREATE OR REPLACE FUNCTION create_account(p_customer_id INTEGER, p_branch_id INTEGER, p_type VARCHAR, p_currency CHAR(3), p_opening_amount NUMERIC)
RETURNS INTEGER AS $$
DECLARE
    new_aid INTEGER;
BEGIN
    INSERT INTO accounts (customer_id, branch_id, account_type, currency, balance)
    VALUES (p_customer_id, p_branch_id, p_type, p_currency, COALESCE(p_opening_amount,0))
    RETURNING account_id INTO new_aid;

    IF COALESCE(p_opening_amount,0) > 0 THEN
        INSERT INTO transactions (account_id, txn_type, amount, balance_after, description)
        VALUES (new_aid, 'DEPOSIT', p_opening_amount, p_opening_amount, 'Opening deposit');
    END IF;
    RETURN new_aid;
END;
$$ LANGUAGE plpgsql;

-- Deposit
CREATE OR REPLACE FUNCTION deposit(p_account_id INTEGER, p_amount NUMERIC, p_employee_id INTEGER DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
    cur_balance NUMERIC;
BEGIN
    SELECT balance INTO cur_balance FROM accounts WHERE account_id = p_account_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account % not found', p_account_id;
    END IF;

    cur_balance := cur_balance + p_amount;
    UPDATE accounts SET balance = cur_balance WHERE account_id = p_account_id;
    INSERT INTO transactions (account_id, txn_type, amount, balance_after, performed_by, description)
    VALUES (p_account_id, 'DEPOSIT', p_amount, cur_balance, p_employee_id, 'Deposit');
END;
$$ LANGUAGE plpgsql;

-- Withdraw (simple version)
CREATE OR REPLACE FUNCTION withdraw(p_account_id INTEGER, p_amount NUMERIC, p_employee_id INTEGER DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
    cur_balance NUMERIC;
BEGIN
    SELECT balance INTO cur_balance FROM accounts WHERE account_id = p_account_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account % not found', p_account_id;
    END IF;

    IF cur_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds for account %', p_account_id;
    END IF;

    cur_balance := cur_balance - p_amount;
    UPDATE accounts SET balance = cur_balance WHERE account_id = p_account_id;
    INSERT INTO transactions (account_id, txn_type, amount, balance_after, performed_by, description)
    VALUES (p_account_id, 'WITHDRAW', p_amount, cur_balance, p_employee_id, 'Withdrawal');
END;
$$ LANGUAGE plpgsql;

-- Transfer between accounts
CREATE OR REPLACE FUNCTION transfer(p_from INTEGER, p_to INTEGER, p_amount NUMERIC, p_employee_id INTEGER DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
    b_from NUMERIC;
    b_to NUMERIC;
BEGIN
    IF p_from = p_to THEN
        RAISE EXCEPTION 'Cannot transfer to same account';
    END IF;

    SELECT balance INTO b_from FROM accounts WHERE account_id = p_from FOR UPDATE;
    SELECT balance INTO b_to FROM accounts WHERE account_id = p_to FOR UPDATE;

    IF b_from < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds in account %', p_from;
    END IF;

    b_from := b_from - p_amount;
    b_to := b_to + p_amount;

    UPDATE accounts SET balance = b_from WHERE account_id = p_from;
    UPDATE accounts SET balance = b_to WHERE account_id = p_to;

    INSERT INTO transactions (account_id, related_account_id, txn_type, amount, balance_after, performed_by, description)
    VALUES (p_from, p_to, 'TRANSFER', p_amount, b_from, p_employee_id, 'Transfer out');

    INSERT INTO transactions (account_id, related_account_id, txn_type, amount, balance_after, performed_by, description)
    VALUES (p_to, p_from, 'TRANSFER', p_amount, b_to, p_employee_id, 'Transfer in');
END;
$$ LANGUAGE plpgsql;

-- Simple statement query function (returns rows)
CREATE OR REPLACE FUNCTION account_statement(p_account_id INTEGER, p_from TIMESTAMP, p_to TIMESTAMP)
RETURNS TABLE(transaction_id INTEGER, txn_at TIMESTAMP, txn_type VARCHAR, amount NUMERIC, balance_after NUMERIC, description TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT transaction_id, txn_at, txn_type, amount, balance_after, description
    FROM transactions
    WHERE account_id = p_account_id AND txn_at BETWEEN p_from AND p_to
    ORDER BY txn_at;
END;
$$ LANGUAGE plpgsql;
