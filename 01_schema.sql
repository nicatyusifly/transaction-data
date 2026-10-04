/*
================================================================================
 01_schema.sql
 BANK TRANSACTIONS SQL PORTFOLIO PROJECT (ORACLE SQL)
 Bu fayl: cedvellerin strukturunu (DDL) yaradir.
 Iere: branches -> customers -> transactions
================================================================================
*/

-- Movcud obyektleri temizle (yenidenqurma ucun tehlukesiz)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE transactions PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE customers PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE branches PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE branches (
    branch_id       NUMBER          PRIMARY KEY,
    branch_name     VARCHAR2(100)   NOT NULL,
    city            VARCHAR2(50)    NOT NULL
);

CREATE TABLE customers (
    customer_id     NUMBER          PRIMARY KEY,
    full_name       VARCHAR2(100)   NOT NULL,
    city            VARCHAR2(50),
    birth_date      DATE,
    registration_dt DATE            NOT NULL
);

CREATE TABLE transactions (
    transaction_id    NUMBER          PRIMARY KEY,
    customer_id       NUMBER          NOT NULL,
    branch_id         NUMBER          NOT NULL,
    transaction_date  DATE            NOT NULL,
    transaction_type  VARCHAR2(20)    NOT NULL,  -- DEPOSIT, WITHDRAWAL, PAYMENT, TRANSFER
    category          VARCHAR2(30)    NOT NULL,  -- SALARY, RENT, ATM, GROCERY, ...
    amount            NUMBER(12,2)    NOT NULL,
    CONSTRAINT fk_txn_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_txn_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
);

CREATE INDEX ix_txn_customer ON transactions(customer_id);
CREATE INDEX ix_txn_branch   ON transactions(branch_id);
CREATE INDEX ix_txn_date     ON transactions(transaction_date);

COMMENT ON TABLE branches IS 'Bank filiallari';
COMMENT ON TABLE customers IS 'Bank musterileri';
COMMENT ON TABLE transactions IS 'Musteri hesab hereketleri (tranzaksiyalar)';
