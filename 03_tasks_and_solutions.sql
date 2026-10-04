/*
================================================================================
 03_tasks_and_solutions.sql
 BANK TRANSACTIONS SQL PORTFOLIO PROJECT (ORACLE SQL)

 Bu fayl: 01_schema.sql ve 02_seed_data.sql icra edildikden sonra ise dusur.
 Data: 6 filial, 30 musteri (2 muşteri tranzaksiyasız), ~760 tranzaksiya,
       2024-01-01 - 2024-06-30 araligi.

 Seviyye: Orta (Intermediate)
 Movzular: Single-row functions | INNER JOIN | LEFT JOIN | CTE (WITH) |
           Window Functions (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD)

 Struktur: her tapşırıq once komment ile izah olunur, sonra hell (SELECT)
           sorğusu verilir.
================================================================================
*/


/* ============================================================
   BÖLMƏ A — SINGLE-ROW FUNCTIONS
   ============================================================ */

-- TASK A1: Hər müştərinin tam adını böyük hərflərlə, şəhərini kiçik
-- hərflərlə göstərin və qeydiyyat ilini ayrıca sütunda verin.
SELECT
    customer_id,
    UPPER(full_name)                    AS full_name_upper,
    LOWER(NVL(city, 'unknown'))         AS city_lower,
    EXTRACT(YEAR FROM registration_dt)  AS registration_year
FROM customers
ORDER BY customer_id;


-- TASK A2: Hər müştərinin bankda neçə il/ay üzv olduğunu hesablayın.
SELECT
    full_name,
    registration_dt,
    TRUNC(MONTHS_BETWEEN(SYSDATE, registration_dt) / 12)        AS years_as_member,
    TRUNC(MOD(MONTHS_BETWEEN(SYSDATE, registration_dt), 12))    AS extra_months
FROM customers
ORDER BY years_as_member DESC;


-- TASK A3: Tranzaksiyaların məbləğini formatlaşdırın ($1,234.00 şəklində)
-- və işarəsinə görə DEBIT/CREDIT etiketi əlavə edin.
SELECT
    transaction_id,
    TO_CHAR(amount, '$999,999.00')                       AS formatted_amount,
    CASE WHEN amount < 0 THEN 'DEBIT' ELSE 'CREDIT' END  AS flow_type,
    INITCAP(category)                                    AS category_pretty
FROM transactions
WHERE ROWNUM <= 20
ORDER BY transaction_id;


-- TASK A4: Hər tranzaksiyanın ay adını (məs. "January") və rüb (quarter)
-- nömrəsini göstərin.
SELECT
    transaction_id,
    transaction_date,
    TRIM(TO_CHAR(transaction_date, 'Month'))  AS txn_month_name,
    TO_CHAR(transaction_date, 'Q')            AS txn_quarter
FROM transactions
WHERE ROWNUM <= 20
ORDER BY transaction_date;


-- TASK A5: Müştəri adının ilk hərfini və soyadının ilk 3 hərfini
-- birləşdirərək "istifadəçi kodu" yaradın (məs: "E-MEM").
SELECT
    full_name,
    SUBSTR(full_name, 1, 1) || '-' ||
        UPPER(SUBSTR(SUBSTR(full_name, INSTR(full_name, ' ') + 1), 1, 3)) AS user_code
FROM customers
ORDER BY full_name;


/* ============================================================
   BÖLMƏ B — INNER JOIN
   ============================================================ */

-- TASK B1: Tranzaksiyası olan bütün müştərilərin adı, filial adı və
-- tranzaksiya məlumatlarını göstərin (yalnız real tranzaksiyalar).
SELECT
    c.full_name,
    c.city              AS customer_city,
    b.branch_name,
    t.transaction_date,
    t.category,
    t.amount
FROM customers c
INNER JOIN transactions t ON c.customer_id = t.customer_id
INNER JOIN branches b     ON t.branch_id   = b.branch_id
WHERE ROWNUM <= 20
ORDER BY c.full_name, t.transaction_date;


-- TASK B2: Hər müştərinin ümumi (net) balansını və tranzaksiya sayını
-- hesablayın (yalnız tranzaksiyası olanlar).
SELECT
    c.customer_id,
    c.full_name,
    COUNT(t.transaction_id)   AS txn_count,
    SUM(t.amount)             AS net_balance
FROM customers c
INNER JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY net_balance DESC;


-- TASK B3: Hər müştəri və hər ay üzrə xərclədiyi (mənfi) ümumi məbləği
-- göstərin, yalnız 500-dən çox xərci olan ay-müştəri cütlərini seçin.
SELECT
    c.full_name,
    TO_CHAR(t.transaction_date, 'YYYY-MM')  AS txn_month,
    SUM(ABS(t.amount))                      AS total_spent
FROM customers c
INNER JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.amount < 0
GROUP BY c.full_name, TO_CHAR(t.transaction_date, 'YYYY-MM')
HAVING SUM(ABS(t.amount)) > 500
ORDER BY total_spent DESC;


/* ============================================================
   BÖLMƏ C — LEFT JOIN
   ============================================================ */

-- TASK C1: Bütün müştəriləri göstərin (tranzaksiyası olmayanlar da daxil).
SELECT
    c.customer_id,
    c.full_name,
    t.transaction_id,
    t.amount
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
WHERE ROWNUM <= 30
ORDER BY c.customer_id;


-- TASK C2: Heç bir tranzaksiyası olmayan (qeyri-aktiv) müştəriləri tapın.
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    c.registration_dt
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.transaction_id IS NULL;


-- TASK C3: Hər filial üzrə tranzaksiya sayı və ümumi dövriyyəni göstərin,
-- tranzaksiyası olmayan filial olsa belə siyahıda qalsın.
SELECT
    b.branch_id,
    b.branch_name,
    b.city,
    COUNT(t.transaction_id)     AS total_transactions,
    NVL(SUM(t.amount), 0)       AS total_amount
FROM branches b
LEFT JOIN transactions t ON b.branch_id = t.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_transactions DESC;


/* ============================================================
   BÖLMƏ D — CTE (WITH)
   ============================================================ */

-- TASK D1: Hər müştərinin aylıq SALARY məbləğini hesablayın, sonra
-- ümumi orta maaşdan yüksək olan ay-müştəri kombinasiyalarını tapın.
WITH monthly_salary AS (
    SELECT
        c.customer_id,
        c.full_name,
        TRUNC(t.transaction_date, 'MM') AS txn_month,
        SUM(t.amount)                   AS salary_amount
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.category = 'SALARY'
    GROUP BY c.customer_id, c.full_name, TRUNC(t.transaction_date, 'MM')
),
avg_salary AS (
    SELECT AVG(salary_amount) AS overall_avg_salary
    FROM monthly_salary
)
SELECT
    ms.full_name,
    ms.txn_month,
    ms.salary_amount,
    ROUND(a.overall_avg_salary, 2) AS avg_salary_all_customers
FROM monthly_salary ms
CROSS JOIN avg_salary a
WHERE ms.salary_amount > a.overall_avg_salary
ORDER BY ms.salary_amount DESC;


-- TASK D2: Hər müştərinin ümumi gəlir (müsbət) və xərc (mənfi) cəmlərini
-- ayrıca hesablayıb net cash-flow müəyyənləşdirin.
WITH income AS (
    SELECT customer_id, SUM(amount) AS total_income
    FROM transactions
    WHERE amount > 0
    GROUP BY customer_id
),
expense AS (
    SELECT customer_id, SUM(amount) AS total_expense
    FROM transactions
    WHERE amount < 0
    GROUP BY customer_id
)
SELECT
    c.full_name,
    NVL(i.total_income, 0)                             AS total_income,
    NVL(e.total_expense, 0)                             AS total_expense,
    NVL(i.total_income, 0) + NVL(e.total_expense, 0)    AS net_cash_flow
FROM customers c
LEFT JOIN income  i ON c.customer_id = i.customer_id
LEFT JOIN expense e ON c.customer_id = e.customer_id
ORDER BY net_cash_flow DESC;


-- TASK D3: Filial üzrə hər kateqoriyanın (RENT, GROCERY, ATM və s.)
-- ümumi məbləğini hesablayın, sonra hər filialın ən çox xərclənən
-- kateqoriyasını tapın (CTE + window function birlikdə).
WITH branch_category AS (
    SELECT
        b.branch_name,
        t.category,
        SUM(ABS(t.amount)) AS total_amount
    FROM branches b
    JOIN transactions t ON b.branch_id = t.branch_id
    WHERE t.amount < 0
    GROUP BY b.branch_name, t.category
),
ranked AS (
    SELECT
        branch_category.*,
        RANK() OVER (PARTITION BY branch_name ORDER BY total_amount DESC) AS rnk
    FROM branch_category
)
SELECT branch_name, category, total_amount
FROM ranked
WHERE rnk = 1
ORDER BY total_amount DESC;


/* ============================================================
   BÖLMƏ E — WINDOW FUNCTIONS
   ============================================================ */

-- TASK E1: ROW_NUMBER — hər müştərinin ilk tranzaksiyasını (ən erkən
-- tarixli) tapın.
SELECT customer_id, transaction_date, category, amount
FROM (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY t.customer_id
            ORDER BY t.transaction_date ASC
        ) AS rn
    FROM transactions t
)
WHERE rn = 1
ORDER BY customer_id;


-- TASK E2: RANK vs DENSE_RANK — müştəriləri ümumi dövriyyəyə (abs məbləğ
-- cəmi) görə sırala, hər iki funksiyanın fərqini müqayisə edin.
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.full_name,
        SUM(ABS(t.amount)) AS total_turnover
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.full_name
)
SELECT
    full_name,
    ROUND(total_turnover, 2)                             AS total_turnover,
    RANK()       OVER (ORDER BY total_turnover DESC)      AS turnover_rank,
    DENSE_RANK() OVER (ORDER BY total_turnover DESC)      AS turnover_dense_rank
FROM customer_totals
ORDER BY turnover_rank;


-- TASK E3: LAG — hər müştərinin ardıcıl aylıq maaşları arasındakı
-- dəyişikliyi (əvvəlki aya nisbətən) hesablayın.
WITH monthly_salary AS (
    SELECT
        c.full_name,
        TRUNC(t.transaction_date, 'MM') AS txn_month,
        SUM(t.amount)                   AS salary_amount
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.category = 'SALARY'
    GROUP BY c.full_name, TRUNC(t.transaction_date, 'MM')
)
SELECT
    full_name,
    txn_month,
    ROUND(salary_amount, 2) AS salary_amount,
    ROUND(LAG(salary_amount) OVER (PARTITION BY full_name ORDER BY txn_month), 2) AS prev_month_salary,
    ROUND(
        salary_amount - LAG(salary_amount) OVER (PARTITION BY full_name ORDER BY txn_month)
    , 2) AS salary_change
FROM monthly_salary
ORDER BY full_name, txn_month;


-- TASK E4: LEAD — hər müştərinin iki ardıcıl tranzaksiyası arasında
-- neçə gün fasilə olduğunu hesablayın və 30 gündən çox fasilə olanları tapın.
SELECT customer_id, transaction_date, next_transaction_date, days_until_next
FROM (
    SELECT
        customer_id,
        transaction_date,
        LEAD(transaction_date) OVER (
            PARTITION BY customer_id ORDER BY transaction_date
        ) AS next_transaction_date,
        LEAD(transaction_date) OVER (
            PARTITION BY customer_id ORDER BY transaction_date
        ) - transaction_date AS days_until_next
    FROM transactions
)
WHERE days_until_next > 30
ORDER BY days_until_next DESC;


-- TASK E5: Cari toplam (running total) — hər müştərinin balansının
-- zaman ərzində necə dəyişdiyini (kumulyativ cəm) göstərin.
SELECT
    customer_id,
    transaction_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_balance
FROM transactions
WHERE customer_id = 101
ORDER BY transaction_date;


-- TASK E6: NTILE — müştəriləri ümumi dövriyyəyə görə 4 bərabər qrupa
-- (kvartil) bölün (VIP seqmentasiyası üçün).
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.full_name,
        SUM(ABS(t.amount)) AS total_turnover
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.full_name
)
SELECT
    full_name,
    ROUND(total_turnover, 2) AS total_turnover,
    NTILE(4) OVER (ORDER BY total_turnover DESC) AS turnover_quartile
FROM customer_totals
ORDER BY total_turnover DESC;
