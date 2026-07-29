# GOOGLE-MERCHANDISE-STORE-E-COMMERCE-ANALYSIS
🛍️ Google Merchandise Store E-commerce Analysis
📌 Project Objective

Analyze the Google Merchandise Store GA4 ecommerce dataset to identify the customer, marketing, product, device, and user journey factors that influence conversions and purchase revenue. The project aims to transform raw event-level data into actionable business insights using SQL, Google BigQuery, and Tableau.

🎯 Business Problem

The Google Merchandise Store generates substantial website traffic, but management lacks clear visibility into:

Which marketing channels generate the highest purchase revenue
Which customer segments contribute most to conversions
Which products drive the strongest sales performance
Which devices generate the most revenue
Where users abandon the purchase journey

Without these insights, marketing investment, product strategy, and user experience improvements cannot be effectively prioritized.

⚡ Actions Performed
Data Analysis
Analyzed 4.3M+ GA4 ecommerce events in Google BigQuery
Performed 13 SQL analyses covering:
Marketing Channel Analysis
Customer Analysis
Product Performance Analysis
Device Performance Analysis
Funnel Analysis
Data Validation
SQL Techniques
Common Table Expressions (CTEs)
Window Functions
Conditional Aggregation
CASE Expressions
Data Cleaning & Validation
Aggregation Functions
Dashboard Development

Built an interactive Tableau dashboard featuring:

Total Users
Purchase Revenue
Purchase Conversion Rate
Average Order Value
Marketing Channel Performance
Product Performance
Device Performance
Customer Behavior
Purchase Funnel
🛠️ Tools & Technologies
Category	Tools
Database	Google BigQuery
Query Language	SQL
Visualization	Tableau
Dataset	Google Analytics 4 (GA4) Public Sample Ecommerce Dataset
📊 Key Insights
Marketing Channels
Organic Search generated the highest purchase revenue ($95.8K).
Referral traffic achieved the highest average order value.
Paid Search produced the lowest revenue, highlighting opportunities to optimize paid marketing campaigns.
Customer Behavior
Purchase behavior varied significantly across customer segments, helping identify high-value audiences for targeted marketing.
Device Performance
Desktop generated the highest purchase revenue ($208.8K), indicating stronger purchase intent compared to other devices.
Product Performance
A small group of products contributed a significant share of total purchase revenue, suggesting opportunities for product promotion and cross-selling.
Conversion Funnel
Only 7.21% of users who viewed a product completed a purchase.
The largest drop-off (45.49%) occurred between Begin Checkout and Purchase, indicating checkout friction.
💼 Business Impact

This analysis provides data-driven insights that can help business teams:

Prioritize high-performing acquisition channels.
Improve marketing return on investment.
Identify valuable customer segments.
Optimize product merchandising.
Improve the checkout experience.
Monitor ecommerce KPIs through an interactive dashboard.
Support faster, evidence-based decision-making.
💡 Recommendations
Optimize the checkout process to reduce abandonment between checkout and purchase.
Increase investment in high-performing acquisition channels, particularly Organic Search.
Reassess Paid Search campaigns to improve efficiency and return on investment.
Promote high-performing products through targeted marketing campaigns.
Improve the mobile shopping experience if further device analysis identifies usability issues.
Continuously monitor conversion, revenue, and customer behavior using the Tableau dashboard.
📈 Dashboard Preview

(Insert your Tableau dashboard screenshots here.)

📁 Repository Structure
Google-Merchandise-Store-Analysis/
│
├── SQL/
│   ├── Marketing_Channel_Analysis.sql
│   ├── Customer_Analysis.sql
│   ├── Product_Performance.sql
│   ├── Device_Performance.sql
│   ├── Funnel_Analysis.sql
│   └── Data_Validation.sql
│
├── Tableau/
│   └── Google_Merchandise_Store_Dashboard.twbx
│
├── Images/
│   ├── Dashboard.png
│   └── SQL_Output.png
│
└── README.md
🎯 Skills Demonstrated
SQL
Google BigQuery
Tableau
Data Cleaning
Data Validation
Exploratory Data Analysis (EDA)
Marketing Analytics
Customer Analytics
Product Analytics
Funnel Analysis
KPI Development
Dashboard Design
Data Storytelling
Business Problem Solving
Business Recommendations
