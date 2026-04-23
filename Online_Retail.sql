CREATE DATABASE retail_project;

USE retail_project;

CREATE TABLE online_retail(
Invoice_no VARCHAR(20),
Stock_code VARCHAR(20),
description TEXT,
quantity INT,
Invoicedate DATETIME,
unit_price DECIMAL(10,2),
customer_id INT,
country VARCHAR (50),
item_total DECIMAL (10,2)
);

SELECT * FROM online_retail_data;

SELECT COUNT(*) FROM online_retail_data;

SELECT * FROM online_retail_data LIMIT 10;

SELECT count(*) FROM online_retail_data WHERE quantity < 0;

-- TOTAL REVENUE 
SELECT SUM(item_total) AS total_revenue
FROM online_retail_data;


DESCRIBE online_retail_data;

SELECT DATE_FORMAT (invoice_date, '%Y-%m')
FROM online_retail_data;

-- MONTHLY SALES TREND
SELECT 
     DATE_FORMAT(invoice_date, '%Y-%m') AS
month,
     SUM(item_total) AS revenue
FROM online_retail_data
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month;

-- Top 10 customers
SELECT
      customer_id,
      SUM(item_total) AS revenue
FROM online_retail_data
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;

-- Top Products
SELECT 
      description,
      SUM(quantity) AS total_sold
FROM online_retail_data
GROUP BY description
ORDER BY total_sold DESC
LIMIT 10;

-- RFM ANALYSIS

SELECT MAX(invoice_date)FROM online_retail_data;

SELECT 
      customer_id,
      MAX(invoice_date) AS last_purchase,
      COUNT(DISTINCT invoice_no) AS frequency,
      SUM(item_total) AS monetary
FROM online_retail_data
WHERE customer_id IS NOT NULL
GROUP BY customer_id;


SELECT 
      customer_id,
      DATEDIFF(
               (SELECT MAX(invoice_date) FROM online_retail_data),
               MAX(invoice_date)) AS receny,
               COUNT(DISTINCT invoice_no) AS frequency,
               SUM(item_total) AS montary
FROM online_retail_data
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    
    CASE
       WHEN recency <= 30 THEN 3
       WHEN recency <= 90 THEN 2
       ELSE 1
	END AS r_score,
    
    CASE
       WHEN frequency >= 10 THEN 3
       WHEN frequency >= 5 THEN 2
       ELSE 1
	END AS f_score,
    
    CASE
       WHEN monetary >= 1000 THEN 3
       WHEN monetary >=500 THEN 2
       ELSE 1
	END AS m_score
    
FROM (
	SELECT 
		customer_id,
		DATEDIFF(
		    (SELECT MAX(invoice_date) FROM online_retail_data),
			MAX(invoice_date)
		) AS recency,
		COUNT(DISTINCT invoice_no) AS frequency,
		SUM(item_total) AS monetary
  FROM online_retail_data
  WHERE customer_id IS NOT NULL
  GROUP BY customer_id
) t;

-- Customer Segmentation
SELECT *,
    CASE
        WHEN r_score=3 AND f_score=3 AND 
m_score=3 THEN 'Champions'
        WHEN r_score>=2 AND f_score>=2 THEN 
'Loyal Customers'
        WHEN r_score=1 AND f_score=1 THEN 
'New Customers'
        WHEN r_score=1 THEN 'Lost Customers'
        ELSE 'Average'
	END AS segment
FROM(
	SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    
    CASE
       WHEN recency <= 30 THEN 3
       WHEN recency <= 90 THEN 2
       ELSE 1
	END AS r_score,
    
    CASE
       WHEN frequency >= 10 THEN 3
       WHEN frequency >= 5 THEN 2
       ELSE 1
	END AS f_score,
    
    CASE
       WHEN monetary >= 1000 THEN 3
       WHEN monetary >=500 THEN 2
       ELSE 1
	END AS m_score
    
FROM (
	SELECT 
		customer_id,
		DATEDIFF(
		    (SELECT MAX(invoice_date) FROM online_retail_data),
			MAX(invoice_date)
		) AS recency,
		COUNT(DISTINCT invoice_no) AS frequency,
		SUM(item_total) AS monetary
  FROM online_retail_data
  WHERE customer_id IS NOT NULL
  GROUP BY customer_id
)base
) scored;

SELECT COUNT(*) 
FROM (
    SELECT customer_id
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) t;

SELECT 
    r_score,
    f_score,
    m_score,
    COUNT(*) AS customers
FROM (
    SELECT 
        customer_id,

        CASE 
            WHEN DATEDIFF((SELECT 
MAX(invoice_date) FROM online_retail), 
MAX(invoice_date)) <= 30 THEN 3
            WHEN DATEDIFF((SELECT 
MAX(invoice_date) FROM online_retail),
MAX(invoice_date)) <= 90 THEN 2
            ELSE 1
        END AS r_score,

        CASE 
            WHEN COUNT(DISTINCT invoice_no) >= 10 THEN 3
            WHEN COUNT(DISTINCT invoice_no) >= 5 THEN 2
            ELSE 1
        END AS f_score,

        CASE 
            WHEN SUM(item_total) >= 10 THEN 3
            WHEN SUM(item_total) >= 5 THEN 2
            ELSE 1
        END AS m_score

    FROM online_retail_data
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) t
GROUP BY r_score, f_score, m_score
ORDER BY customers DESC;

SELECT 
    segment,
    COUNT(*) AS customers
FROM (
    SELECT *,
        CASE 
            WHEN r_score=3 AND f_score=3 AND 
m_score=3 THEN 'Champions'
            WHEN r_score>=2 AND f_score>=2
THEN 'Loyal Customers'
            WHEN r_score=3 AND f_score=1 THEN 
'New Customers'
            WHEN r_score=1 THEN 'Lost Customers'
            ELSE 'Average'
        END AS segment
    FROM (
        SELECT 
            customer_id,

            CASE 
                WHEN DATEDIFF((SELECT
MAX(invoice_date) FROM online_retail),
MAX(invoice_date)) <= 30 THEN 3
                WHEN DATEDIFF((SELECT
MAX(invoice_date) FROM online_retail), 
MAX(invoice_date)) <= 90 THEN 2
                ELSE 1
            END AS r_score,

            CASE 
                WHEN COUNT(DISTINCT invoice_no) >= 10 THEN 3
                WHEN COUNT(DISTINCT invoice_no) >= 5 THEN 2
                ELSE 1
            END AS f_score,

            CASE 
                WHEN SUM(item_total) >= 1000 THEN 3
                WHEN SUM(item_total) >= 500 THEN 2
                ELSE 1
            END AS m_score

        FROM online_retail_data
        WHERE customer_id IS NOT NULL
        GROUP BY customer_id
    ) x
) y
GROUP BY segment
ORDER BY customers DESC;

