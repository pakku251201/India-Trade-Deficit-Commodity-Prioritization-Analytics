# 🇮🇳 India Trade Deficit & Commodity Prioritization Analytics

An end-to-end **business analytics project** analyzing India's import, export, and trade-deficit trends across **97 HS-2 commodity groups** using official UN Comtrade data from 2020–2024.

The project combines **Excel, Power Query, PostgreSQL, SQL, and Power BI** to identify the major drivers of India's trade deficit and prioritize commodity categories based on import exposure, deficit deterioration, and import growth.

---

## 📊 Project Overview

This project demonstrates a complete analytics workflow — from raw international trade data and data profiling to SQL-based analysis, commodity prioritization, scenario modelling, and business intelligence reporting.

The analysis uses **970 trade records covering 97 HS-2 commodity groups**, with India as the reporter and the World as the trading partner.

### 🎯 Key Outcome

The analysis found that **five commodity groups accounted for 83.3% of the $170.82B increase in India's commodity trade deficit between 2020 and 2024.**

---

## 🎯 Objectives

- 📥 Collect and prepare official India trade data from UN Comtrade
- 🧹 Profile, validate, and transform the raw dataset
- 📊 Analyze India's import, export, and trade-balance trends
- 🔍 Identify major commodity-level trade-deficit drivers
- 📈 Analyze import growth and import exposure
- 🎯 Develop a Trade Priority Score for commodity prioritization
- 💡 Model a 10% import-substitution scenario
- 📊 Build interactive Power BI dashboards for business reporting

---

## 🛠️ Tools & Technologies

| Tool | Usage |
|---|---|
| 🐘 **PostgreSQL** | Data storage and analytical querying |
| 💻 **SQL** | Business analysis, CTEs, subqueries & window functions |
| 📗 **Excel** | Data profiling, validation & pivot analysis |
| 🔄 **Power Query** | Data cleaning and transformation |
| 📊 **Power BI** | Dashboarding and visualization |
| 🌐 **UN Comtrade** | Official trade data source |
| 🔧 **Git & GitHub** | Version control |

---

## 🧠 Methods & Analysis

- 📋 Data Profiling
- 🧹 Data Cleaning & Validation
- 📊 Exploratory Data Analysis
- 📈 Year-over-Year Analysis
- ⚖️ Trade Balance Analysis
- 🔍 Commodity-Level Analysis
- 🏆 Ranking & Prioritization
- 🔗 SQL CTEs & Subqueries
- 🪟 SQL Window Functions
- 💡 Scenario Modelling
- 📊 Business Intelligence Reporting

---

## 🌐 Data Source

**United Nations Comtrade Database**

🔗 https://comtradeplus.un.org/

### Dataset Configuration

- 🇮🇳 Reporter: **India**
- 🌎 Partner: **World**
- 📦 Product: **Goods**
- 📅 Frequency: **Annual**
- 🏷️ Classification: **HS**
- 🔢 Commodity level: **HS 2-digit**
- 🔄 Trade flows: **Imports & Exports**
- 📆 Period: **2020–2024**
- 📊 Commodity groups: **97**
- 🧾 Records: **970**

The analysis uses the UN Comtrade `primaryValue` field as the trade-value measure.

---

## 🔄 Project Workflow

🌐 UN Comtrade
      ↓
📥 Raw Trade Data
      ↓
📗 Excel / Power Query
      ↓
🧹 Data Cleaning & Validation
      ↓
🐘 PostgreSQL
      ↓
💻 SQL Analysis
      ↓
🔍 Commodity Analysis
      ↓
🎯 Trade Priority Score
      ↓
💡 Scenario Modelling
      ↓
📊 Power BI Dashboard
