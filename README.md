# Ecommerce Sales & Profit Analysis Dashboard  
### Power BI • SQL • Python • Data Modeling

A complete business intelligence project analyzing ecommerce revenue, profit, negative profit behavior, category performance, and monthly sales targets using **Power BI**, **SQL**, and **Python preprocessing**.

This project demonstrates a full analytics workflow:

**Raw Data → Python Cleaning → SQL Analysis → Power BI Modeling → Dashboard**

---

## 📊 Dashboard Pages

### **1. Executive Summary**
- Revenue vs Target (Line + Column)
- Negative Profit %
- Top Seller per Month (RANKX)
- KPI overview

### **2. Profitability Deep Dive**
- Negative Profit Trend
- Category & Sub‑Category Loss Breakdown
- Loss‑Leader Detection
- Top Negative Profit Item (RANKX)

---

## 🧠 Key Features
- Clean star‑schema data model
- Month dimension table for proper time intelligence
- Many‑to‑many category handling
- Advanced DAX (RANKX, moving averages, negative profit logic)
- SQL preprocessing for order‑level analytics
- Python scripts for data cleaning and normalization

---

## 🛠 Tech Stack
- **Power BI** — data modeling, DAX, visualization  
- **SQL** — CTEs, conditional aggregation, ranking  
- **Python (Pandas)** — data cleaning, dtype normalization, preprocessing  
- **GitHub** — version control & documentation  

---

## 📁 Repository Structure

data/
raw/
cleaned/
README_DATA.md

python_dataCleaning/
ecommerce_datacleaning.ipynb

sql_queries/
ecommerce_db.session.sql

powerBI/
ecommerce_BI.pbix

images/
ecommerce_dashBoard.pdf

README.md
LICENSE


---

## 🔧 How to Reproduce

1. Clone the repository  
2. Run the Python cleaning notebook in `/python_dataCleaning`  
3. Load cleaned CSVs from `/data/cleaned` into Power BI  
4. Open the PBIX file in `/powerBI`  
5. Explore the dashboard pages  

---

## 📈 Insights

- Negative profit is concentrated in specific sub‑categories  
- Loss‑leaders appear consistently across multiple months  
- Revenue often diverges from monthly targets  
- RANKX identifies top sellers and top negative‑profit items  

---

## 📬 Contact

Created by **Jerick Osoria**  
jerickos77@gmail.com
Phoenix, AZ  

