# Customer Segmentation Analysis

## Project Overview

The Customer Segmentation Analysis project aims to categorize customers into distinct groups based on their purchasing behavior and transaction history. Using RFM (Recency, Frequency, Monetary) Analysis, this project helps businesses identify their most valuable customers, re-engage lost ones, and tailor marketing strategies to improve customer retention and overall business performance.

The dataset contains over 391,000 online retail transactions from a UK-based retailer, covering the period from December 2010 to December 2011, across multiple countries.

---

## Project Goals

1. **Understand the customer base:** Analyze transactional data to uncover patterns in purchasing behavior, revenue contribution, and product preferences.
2. **Segment customers using RFM:** Apply Recency, Frequency, and Monetary scoring to classify customers into meaningful segments — Champions, Loyal Customers, New Customers, Average, and Lost Customers.
3. **Identify top performers:** Find the highest revenue-generating customers and best-selling products to support business decision-making.
4. **Visualize the insights:** Build an interactive Power BI dashboard to present findings in a clear and actionable format.
5. **Provide data-driven recommendations:** Offer strategic insights to help businesses prioritize marketing efforts and improve customer lifetime value.

---

## Methodology

### Data Collection

The dataset is an Online Retail CSV file containing transactional records from a UK-based e-commerce store. It includes fields such as Invoice Number, Stock Code, Product Description, Quantity, Invoice Date, Unit Price, Customer ID, Country, and Item Total. The raw data contained approximately 391,000 records before cleaning.

### Data Preprocessing (Excel)

Before conducting the analysis, the dataset was cleaned in Microsoft Excel. Key steps included:

1. **Removing null values:** Rows with missing Customer IDs were removed as they cannot be linked to any customer.
2. **Removing negative quantities:** Records with negative quantity values (returns and cancellations) were filtered out to retain only valid sales transactions.
3. **Data type formatting:** Invoice Date column was formatted as proper DateTime and numeric columns were set to correct number formats.

### Exploratory Data Analysis (SQL)

EDA was performed using MySQL to understand the data and extract business insights. This included:

- Calculating total revenue across all transactions.
- Analyzing monthly sales trends to identify peak and low revenue periods.
- Finding top 10 customers by total revenue.
- Finding top 10 products by total quantity sold.
- Country-level revenue breakdown.

### RFM Analysis (SQL)

RFM Analysis is a customer segmentation technique based on three dimensions:

- **Recency (R):** How recently did the customer make a purchase?
- **Frequency (F):** How many times did they purchase?
- **Monetary (M):** How much total money did they spend?

Each customer was scored on a scale of 1 to 3 for each RFM dimension:

| Metric | Score 3 | Score 2 | Score 1 |
|---|---|---|---|
| Recency | ≤ 30 days | ≤ 90 days | > 90 days |
| Frequency | ≥ 10 orders | ≥ 5 orders | < 5 orders |
| Monetary | ≥ £1,000 | ≥ £500 | < £500 |

Customers were then classified into segments based on their combined RFM scores:

| Segment | Condition |
|---|---|
| Champions | R=3, F=3, M=3 |
| Loyal Customers | R≥2, F≥2 |
| New Customers | R=3, F=1 |
| Lost Customers | R=1 |
| Average | All others |

### SQL Queries

**Total Revenue**
```sql
SELECT SUM(item_total) AS total_revenue
FROM online_retail_data;
```

**Monthly Sales Trend**
```sql
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    SUM(item_total) AS revenue
FROM online_retail_data
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month;
```

**Top 10 Customers by Revenue**
```sql
SELECT customer_id, SUM(item_total) AS revenue
FROM online_retail_data
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;
```

**Top 10 Products by Quantity Sold**
```sql
SELECT description, SUM(quantity) AS total_sold
FROM online_retail_data
GROUP BY description
ORDER BY total_sold DESC
LIMIT 10;
```

**RFM Scoring**
```sql
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
       WHEN monetary >= 500 THEN 2
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
) base;
```

**Customer Segmentation**
```sql
SELECT *,
    CASE
        WHEN r_score=3 AND f_score=3 AND m_score=3 THEN 'Champions'
        WHEN r_score>=2 AND f_score>=2 THEN 'Loyal Customers'
        WHEN r_score=3 AND f_score=1 THEN 'New Customers'
        WHEN r_score=1 THEN 'Lost Customers'
        ELSE 'Average'
    END AS segment
FROM scored;
```

---

## Tools Used

| Tool | Purpose |
|---|---|
| Microsoft Excel | Data cleaning and preprocessing |
| MySQL | Exploratory data analysis and RFM segmentation |
| Power BI | Interactive dashboard and data visualization |

---

## Power BI Dashboard

An interactive Power BI dashboard was built to visualize all findings. The dashboard includes:

- **KPI Cards** — Total Orders (18K), Total Revenue (£8.52M), Unique Customers (4,336), Avg Order Value (£461.59)
- **Monthly Revenue Trend** — Column chart from March 2010 to November 2011
- **Top Products Bar Chart** — Top 10 products by quantity sold
- **Revenue by Country Donut Chart** — UK leads at 82.01% of total revenue
- **Top 5 Countries Bar Chart** — Revenue comparison across top countries
- **Top Customers Table** — Top 10 customers by Total Revenue
- **RFM Segment Chart** — Customer count across all 5 segments
- **Country Slicer** — Interactive filter to drill down entire dashboard by country

---

## Insights and Recommendations

1. **United Kingdom dominates revenue** at 82%, but countries like Netherlands, Germany, and France show consistent purchasing — international marketing can be explored.
2. **Revenue peaks in October and November**, indicating strong holiday/gifting season demand. Stock and campaigns should be planned accordingly.
3. **Champions and Loyal Customers** are the most valuable segments. Loyalty rewards and exclusive offers should be prioritized for this group.
4. **Lost Customers form a large segment** — targeted win-back campaigns with discounts or personalized communication can help recover them.
5. **Top products are home décor and gift items**, confirming seasonal gifting as the main purchase driver.
6. **A small group of customers contributes a major share of revenue** — retaining these high-value customers should be a top business priority.

---

## Conclusion

This project demonstrates a complete end-to-end data analytics workflow — starting from data cleaning in Excel, to writing SQL queries for RFM analysis, and finally building an interactive Power BI dashboard. The RFM segmentation provides businesses with a practical and actionable way to understand their customer base and design targeted marketing strategies for each segment.
