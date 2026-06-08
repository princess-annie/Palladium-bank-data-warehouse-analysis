-- Creating all dimension first
--1. Creating a Customer Dim SCD(TYPE 2)
--stores all customers profile and tracks teir changes using the scd type 2
CREATE TABLE Dim_Customer(
c_sk INT PRIMARY KEY,--SURROGATE KEY FOR CUSTOMERS
CUSTOMER_ID VARCHAR(20),
CUSTOMER_NAME VARCHAR(100),
TIER VARCHAR(20),
EFFECTIVE_DATE DATE, --WHEN THE TEIR BECAME ACTIVE
END_DATE DATE, --WHEN THE TEIR EXPIRED
is_current SMALLINT-- 1 FOR ACTIVE RECORD AND 0 FOR HISTORICAL RECORDS
);

--2. Creating a Branch Dim
--stores information about bank branches
CREATE TABLE Dim_Branch(
b_sk INT PRIMARY KEY,--SURROGATE KEY FOR BRANCH
BRANCH_ID VARCHAR(20),
BRANCH_NAME VARCHAR(100),
STATE VARCHAR(20)
);

--3. Creating a Product Dim
--stores details about banking products
CREATE TABLE Dim_Product(
p_sk INT PRIMARY KEY,--SURROGATE KEY FOR PRODUCT
PRODUCT_ID VARCHAR(20),
PRODUCT_NAME VARCHAR(100),
PRODUCT_TYPE VARCHAR(50)
);

--4. Creating a Channel Dim
--tracks the medium used for transaction
CREATE TABLE Dim_Channel(
ch_sk INT PRIMARY KEY,--SURROGATE KEY FOR CHANNEL
CHANNEL_NAME VARCHAR(50)
);

--5. Creating a Date Dim
--extract day, year, month, filter
CREATE TABLE Dim_Date(
date_key INT PRIMARY KEY,
Txn_Date Date,
day VARCHAR(10),
month VARCHAR(15),
year INT
);


--6. Creating the Transaction Fact Table
--stores quantitative measures of every transaction.
CREATE TABLE Fact_Transactions(
txn_ID VARCHAR(20) PRIMARY KEY,
customer_sk_fk INT,
branch_sk_fk INT,
product_sk_fk INT,
date_key_fk INT,
channel_sk_fk INT,
txn_type VARCHAR(20),
amount NUMERIC(15, 2),
balance_after NUMERIC(15, 2),
fee_amt NUMERIC(15, 2),

CONSTRAINT fk_customer FOREIGN KEY(customer_sk_fk) REFERENCES Dim_Customer(c_sk),
CONSTRAINT fk_branch FOREIGN KEY(branch_sk_fk) REFERENCES Dim_Branch(b_sk),
CONSTRAINT fk_product FOREIGN KEY(product_sk_fk) REFERENCES Dim_Product(p_sk),
CONSTRAINT fk_channel FOREIGN KEY(channel_sk_fk) REFERENCES Dim_Channel(ch_sk),
CONSTRAINT fk_date_key FOREIGN KEY(date_key_fk) REFERENCES Dim_Date(date_key)
);

--inserting into customer dim
INSERT INTO Dim_Customer(c_sk, CUSTOMER_ID, CUSTOMER_NAME, TIER, EFFECTIVE_DATE, END_DATE, is_current )
VALUES
(1, 'C0002', 'Amina Okonkwo', 'Platinum', '2024-01-08','9999-12-31',1),
(2, 'C0001', 'Emeka Yakubu',  'Platinum', '2024-01-08','9999-12-31',1),
(3, 'C0004', 'Fatima Ibrahim', 'Standard', '2024-01-08','9999-12-31',1),
(4, 'C0003', 'Funke Nwosu', 'Silver', '2024-01-08','9999-12-31',1),
(5, 'C0005', 'Gbenga Ibrahim', 'Platinum', '2024-01-08','9999-12-31',1),
(6, 'C0006', 'Halima Danladi', 'Standard', '2024-01-08','9999-12-31',1),
(7, 'C0007', 'Rotimi Adeleke', 'Gold', '2024-01-08','9999-12-31',1);

INSERT INTO Dim_Branch(b_sk, BRANCH_ID, BRANCH_NAME, STATE)
VALUES
(1,'B03','Victoria Island','Lagos'),
(2,'B02', 'Ikeja','Lagos'),
(3, 'B04', 'Abuja Central','Abuja'),
(4,'B01', 'Lagos Island','Lagos'),
(5, 'B06', 'Kano Central','Kano'),
(6,'B07', 'Port Harcourt','Rivers');

INSERT INTO Dim_Product(p_sk, PRODUCT_ID, PRODUCT_NAME, PRODUCT_TYPE)
VALUES
(1, 'P008','Credit Card','Card'),
(2, 'P010',	'Internet Banking',	'Digital'),
(3,'P007',	'Debit Card','Card'),
(4,'P001', 'Current Account','Account'),
(5,'P009', 'Mobile Banking','Digital'),
(6,'P002','Savings Account','Account'),
(7,'P004','Personal Loan','Loan'),
(8,'P003',	'Fixed Deposit','Savings');

INSERT INTO Dim_Channel(ch_sk, CHANNEL_NAME)
VALUES
(1,'POS'),
(2, 'Internet Banking'),
(3, 'Mobile App'),
(4, 'ATM'),
(5, 'USSD'),
(6, 'Branch');

INSERT INTO Dim_Date(date_key, Txn_Date, day, month, year)
select
to_char(datum,'YYYYMMDD'):: INT AS date_key,
datum AS Txn_Date,
to_char(datum, 'FMDay') AS day,
to_char(datum, 'FMMonth') AS month,
extract (year from datum) AS year
FROM generate_series(
'2024-01-01'::date, --start of th year
'2025-06-30'::date, --18 months complete
'1 day'::interval
)datum;

select * from Dim_Date limit 50;

Alter TABLE Fact_Transactions
ADD CONSTRAINT fk_date FOREIGN KEY(date_key_fk) REFERENCES Dim_Date(date_key),
ADD CONSTRAINT fk_customer FOREIGN KEY(customer_sk_fk) REFERENCES Dim_Customer(c_sk),
ADD CONSTRAINT fk_branch FOREIGN KEY(branch_sk_fk) REFERENCES Dim_Branch(b_sk),
ADD CONSTRAINT fk_product FOREIGN KEY(product_sk_fk) REFERENCES Dim_Product(p_sk),
ADD CONSTRAINT fk_channel FOREIGN KEY(channel_sk_fk) REFERENCES Dim_Channel(ch_sk),
ADD CONSTRAINT fk_date_key FOREIGN KEY(date_key_fk) REFERENCES Dim_Date(date_key);

--ALTER TABLE Fact_Transactions DROP CONSTRAINT IF EXISTS fk_customer;
Alter TABLE Fact_Transactions
ADD CONSTRAINT fk_date FOREIGN KEY(date_key_fk) REFERENCES Dim_Date(date_key),
ADD CONSTRAINT fk_customer FOREIGN KEY(customer_sk_fk) REFERENCES Dim_Customer(c_sk),
ADD CONSTRAINT fk_branch FOREIGN KEY(branch_sk_fk) REFERENCES Dim_Branch(b_sk),
ADD CONSTRAINT fk_product FOREIGN KEY(product_sk_fk) REFERENCES Dim_Product(p_sk),
ADD CONSTRAINT fk_channel FOREIGN KEY(channel_sk_fk) REFERENCES Dim_Channel(ch_sk);

--verification
select constraint_name, constraint_type
from information_schema.table_constraints
where table_name ='fact_transactions';

ALTER TABLE Fact_Transactions
ADD CONSTRAINT fk_customer FOREIGN KEY(customer_sk_fk) REFERENCES Dim_Customer(c_sk);


---temporary table
DROP TABLE IF EXISTS Staging_Transactions;

CREATE TABLE Staging_Transactions (
    txn_id VARCHAR(50),
    txn_date VARCHAR(50),        -- Changed to VARCHAR for easier import
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    tier VARCHAR(20),
    branch_id VARCHAR(20),
    branch_name VARCHAR(50),
    state VARCHAR(50),
    product_id VARCHAR(20),
    product_name VARCHAR(50),
    product_type VARCHAR(20),
    txn_type VARCHAR(50),
    channel VARCHAR(50),
    amount VARCHAR(50),          -- Changed to VARCHAR to handle the "45,000"
    balance_after VARCHAR(50)    -- Changed to VARCHAR
);
select * from staging_transactions;

INSERT INTO Fact_Transactions (
    txn_ID, customer_sk_fk, branch_sk_fk, product_sk_fk, date_key_fk, channel_sk_fk, 
    txn_type, amount, balance_after, fee_amt
)
SELECT 
    stg.txn_id,
    c.c_sk,
    b.b_sk,
    p.p_sk,
    d.date_key,
    ch.ch_sk,
    stg.txn_type,
    REPLACE(stg.amount, ',', '')::NUMERIC,        -- Strips the comma from 45,000
    REPLACE(stg.balance_after, ',', '')::NUMERIC, -- Strips the comma
    0.00
FROM Staging_Transactions stg
JOIN Dim_Customer c ON stg.customer_id = c.CUSTOMER_ID AND c.is_current = 1
JOIN Dim_Branch b   ON stg.branch_id = b.BRANCH_ID
JOIN Dim_Product p  ON stg.product_id = p.PRODUCT_ID
JOIN Dim_Channel ch ON stg.channel = ch.CHANNEL_NAME
JOIN Dim_Date d     ON stg.txn_date::DATE = d.Txn_Date;

select * from fact_transactions;

--Data Quality checks
--check if customer has any null
select count(*) AS cust_count
FROM fact_transactions f
left join Dim_Customer c ON f.customer_sk_fk =c.c_sk
where c.c_sk is null;

--check for the integrity of negative amount
select * from fact_transactions where amount < 0;

--check if there are any future dates from what we created
select * from fact_transactions f
join Dim_Date d ON f.date_key_fk =d.date_key
where d.txn_date > CURRENT_DATE;

--check for null primary keys
select count(*) from fact_transactions where txn_id is null;

--indexing
CREATE INDEX idx_fact_date ON fact_transactions(date_key_fk);
CREATE INDEX idx_fact_customer ON fact_transactions(customer_sk_fk);
CREATE INDEX idx_stg_cust_id ON staging_transactions(customer_id);

--partitioning
--we can partition the fact table either by year or month
COMMENT ON COLUMN fact_transactions.date_key_fk IS 'Recommended partitioning key for 18 month historical data';
COMMENT ON TABLE staging_transactions IS 'temporary loading area for raw csv imports';

--create aggregation table
CREATE TABLE Aggregation_table AS
select
d.year,
d.month,
b.branch_name,
sum(f.amount) AS Total_Revenue,
Count(f.txn_id) AS Txn_Count
FROM  fact_transactions f
JOIN Dim_Date d ON f.date_key_fk =d.date_key
JOIN Dim_Branch b ON f.branch_sk_fk =b.b_sk
GROUP BY d.year,d.month, b.branch_name;

--VERIFICATION
SELECT * FROM Aggregation_table
ORDER BY year, month, branch_name;
