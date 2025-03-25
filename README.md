# Food Delivery orders [Case Study]

## Table of contents
-[Project Overview](#project-overview)

-[Data source](#data-source)

-[Tools](#tools)

-[Data cleaning](#data-cleaning)

-[Outcome](#outcomes)

-[Recommendations](#recommendations)

-[Limitations](#limitations)

## Project Overview
To analyze the cost structure and profitability of a food delivery service using a dataset of 1,000 food orders.
The goal is to identify strategic opportunities to optimize costs and improve overall profitability.

![food orders](https://github.com/user-attachments/assets/eaca8e55-7da5-4696-a976-987779e9db0f)

### Data source
Food Ordes: The primary dataset used for the analysis is the 'food_orders.csv' file containing detail information about each sales.

### Tools
- Microsoft Excel Data Inspection by direct observation.
- PostgresSQL ( Data Analysis and Cleaning).
- Power Bi Reporting

### Data cleaning
In the initial data preparation phase, i performed the following task
- Data cleaning and inspection
- Handling duplicate and missing values
- Data cleaning and formatting

### EDA
1. How do discounts and promotions impact customer behavior and profitability across different order sizes?
2. What are the primary factors driving high costs in food delivery operations?
3. What is the relationship between commission fees and order profitability for the food delivery service?

### Data Analysis
```sql
select sum(fo."Order Value" ) as total_order_cost, fo.standardized_delivery_cost
from food_orders fo 
group by  standardized_delivery_cost 
order by total_order_cost  desc
```

### Outcomes
1. Missing Delivery Charges: Delivery charges of 20 (amount) were frequently missing, leading to significant financial losses.
2. Profit from Promotions: When a 15% promo was applied, there was substantial profit generated through commission fees compared to total costs.
3. Impact Simulation Results: Adjusting the commission fee by a 12% increase, while decreasing discounts and recharge rates by 1%, led to a 2-4% profit increment, effectively eliminating losses.

### Recommendation
1. Implement automated checks in the system to ensure delivery fees are always recorded.
2. Optimize promotional campaigns like the 15% discount to strike a balance between attracting customers and maintaining profitability.
3. Regularly analyze how these adjustments affect customer satisfaction, order volumes, and profitability.

#### Limitations
1. Had to standardize the discount and recharge columns due to mixed data types (integer and character).
2. Calculated profit by subtracting standardized commission fee and delivery fee from the order value.
3. Adjusted profit by increasing the commission fee by 12% and decreasing the discount by 1%.

### References 
- Stack Overflow
  








   
