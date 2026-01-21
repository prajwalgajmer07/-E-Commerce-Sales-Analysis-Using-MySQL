# 🛒 E-Commerce Sales Analysis Using MySQL

## 📌 Project Overview
This project focuses on designing a complete relational e-commerce database in
MySQL and performing detailed business-driven sales analysis using SQL.

The database was fully self-created using SQL scripts, including table creation,
relationships, and manual data insertion based on structured course datasets.
The analysis aims to evaluate sales performance across products, categories,
customers, and regions.

---

## 🎯 Project Goal
Analyze the sales performance of products, categories, and regions to support
data-driven business decision-making.

---

## 🧱 Database Design

The database consists of **5 relational tables**:

- **customers**  
  (CustomerId, CustomerName, Email, Phone, Region, CreateDate)

- **orders**  
  (OrderId, CustomerId, OrderDate, IsReturned)

- **orderdetails**  
  (OrderDetailID, OrderId, ProductId, Quantity)

- **products**  
  (ProductId, ProductName, Category, Price)

- **region**  
  (RegionID, RegionName, Country)

Relationships between tables were implemented using primary and foreign keys
to accurately represent real-world e-commerce transactions.

An ER Diagram is included in the repository to visualize schema design and
table relationships.

---

## 🛠 Tools & Technologies
- MySQL
- SQL
- Relational Database Design
- ER Modeling

---

## 🔍 Analysis Objectives & Business Questions

### 1. General Sales Insights
- Total revenue generated over the entire period  
- Revenue excluding returned orders  
- Revenue by year and month  
- Revenue by product and category  
- Average Order Value (AOV) overall  
- AOV by year and month  
- Average order size by region  

### 2. Customer Insights
- Top 10 customers by total revenue  
- Repeat customer rate  
- Average time between consecutive orders (region-wise)  
- Customer segmentation based on total spend:  
  - Platinum: Total Spend > 1500  
  - Gold: 1000 – 1500  
  - Silver: 500 – 999  
  - Bronze: < 500  
- Customer Lifetime Value (CLV)

### 3. Product & Order Insights
- Top 10 products by quantity sold  
- Top 10 products by revenue  
- Products with highest return rate  
- Return rate by product category  
- Average product price by region  
- Sales trend by product category  

### 4. Temporal Trends
- Monthly sales trends over the past year  
- Monthly and weekly Average Order Value (AOV) trends  

### 5. Regional Insights
- Regions with highest and lowest order volume  
- Revenue comparison across regions  

### 6. Return & Refund Insights
- Return rate by product category  
- Return rate by region  
- Customers with frequent returns  

---

## ▶ How to Use This Project

1. Execute SQL scripts in the **database_setup** folder in sequence:
   - Table creation
   - Data insertion
   - Constraints and indexes (if applicable)

2. After the database is populated, run SQL scripts from the
   **analysis_queries** folder to perform business analysis.

3. Query output screenshots are available in the screenshots folder
   for visual verification of results.

---

## 📂 Repository Structure

📁 **database_setup/**  
→ SQL scripts for creating tables, inserting data, and applying constraints  

📁 **analysis_queries/**  
→ SQL files containing business analysis queries  

📁 **screenshots/**  
&nbsp;&nbsp;📁 **ER_Diagram/** → Database schema image  
&nbsp;&nbsp;📁 **query_results/** → Output screenshots of SQL queries  

📁 **project_objective/**  
→ Business problem statement and objectives document  

📝 **README.md**  
→ Project documentation

---

## ✅ Skills Demonstrated
- Relational database design
- ER diagram modeling
- Data insertion using SQL scripts
- Writing complex analytical SQL queries
- Joins, aggregations, filtering, and grouping
- Business-focused data analysis
- Professional GitHub project structuring

---
