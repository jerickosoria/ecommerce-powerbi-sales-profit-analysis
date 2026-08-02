# DAX Measures for Ecommerce Sales & Profit Analysis

This document contains all DAX measures used in the Ecommerce Sales & Profit Analysis Power BI dashboard.  
Measures are grouped by functional category for clarity.

---

## 📊 Revenue & Profit Measures

### Total Revenue
Total Revenue = SUM('Order Details'[amount])

### Total Profit
Total Profit = SUM('Order Details'[profit])

### Negative Profit Amount
Negative Profit Amount =
CALCULATE(
    SUM('Order Details'[profit]),
    'Order Details'[profit] < 0
)

### Negative Profit %
Negative Profit % =
DIVIDE(
    [Negative Profit Amount],
    [Total Profit],
    0
)

---

## 📅 Time Intelligence Measures

### Month
Month = STARTOFMONTH('Orders'[order_date])

### Revenue PM (Previous Month)
Revenue PM =
CALCULATE(
    [Total Revenue],
    DATEADD('Date'[Date], -1, MONTH)
)

### Revenue MoM % Change
Revenue MoM % =
DIVIDE(
    [Total Revenue] - [Revenue PM],
    [Revenue PM],
    0
)

---

## 🎯 Target vs Actual Measures

### Total Target
Total Target = SUM('Sales Target'[target])

### Target Achievement %
Target Achievement % =
DIVIDE(
    [Total Revenue],
    [Total Target],
    0
)

### Revenue - Target
Revenue - Target =
[Total Revenue] - [Total Target]

---

## 🏆 Ranking Measures

### Top Seller Rank
Top Seller Rank =
RANKX(
    ALL('Order Details'[sub_category]),
    [Total Revenue],
    ,
    DESC
)

---

## 📦 Category & Sub-Category Measures

### Revenue by Category
Revenue by Category = SUM('Order Details'[amount])

### Profit by Category
Profit by Category = SUM('Order Details'[profit])

### Is Negative Profit
Is Negative Profit =
IF('Order Details'[profit] < 0, 1, 0)

---

## 📈 KPI Measures

### Total Orders
Total Orders = DISTINCTCOUNT('Orders'[order_id])

### Total Customers
Total Customers = DISTINCTCOUNT('Orders'[customer_id])

### Negative Profit Count
Negative Profit Count =
CALCULATE(
    COUNTROWS('Order Details'),
    'Order Details'[profit] < 0
)
