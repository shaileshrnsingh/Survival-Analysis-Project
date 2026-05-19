# -*- coding: utf-8 -*-
"""
Created on Mon Mar 31 17:16:18 2025

@author: creative
"""

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# Load dataset (modify filename accordingly)
df = pd.read_csv(r"C:\Users\creative\Downloads\Final dataset relapse.csv")

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime

# Load the dataset


# Display basic information
print("=== Dataset Information ===")
print(df.info())
print("\n=== First 5 Rows ===")
print(df.head())

# Data Cleaning
# Convert date columns to datetime
date_cols = ['Date', 'exit_date', 'readmission_date']
for col in date_cols:
    if col in df.columns:
        df[col] = pd.to_datetime(df[col], errors='coerce')

# Handle missing values
print("\n=== Missing Values ===")
print(df.isnull().sum())

# Basic Statistics
print("\n=== Numerical Variables Summary ===")
print(df.describe())

print("\n=== Categorical Variables Summary ===")
cat_cols = ['Sex', 'Marital Status', 'Diagnosis', 'Qualification', 'Employment Status', 'relapse']
for col in cat_cols:
    if col in df.columns:
        print(f"\n{col}:\n{df[col].value_counts(dropna=False)}")

# Relapse Analysis
relapse_rate = df['relapse'].value_counts(normalize=True) * 100
print("\n=== Relapse Rate ===")
print(relapse_rate)

# Time till Relapse Analysis (for those who relapsed)
relapsed = df[df['relapse'] == 'Yes']
print("\n=== Time Till Relapse Summary ===")
print(relapsed['Time till Relapse (Days)'].describe())

# Visualization
plt.figure(figsize=(15, 20))

# 1. Relapse Distribution
plt.subplot(4, 2, 1)
sns.countplot(data=df, x='relapse')
plt.title('Relapse Distribution')

#pie chart 
# Calculate relapse rate
relapse_counts = df['relapse'].value_counts()
relapse_percent = df['relapse'].value_counts(normalize=True) * 100

# Create pie chart
plt.figure(figsize=(8, 6))
colors = ['#ff9999','#66b3ff']
explode = (0.05, 0)  # Explode the 'Yes' slice slightly

plt.pie(relapse_counts, 
        labels=relapse_counts.index, 
        autopct='%1.1f%%',
        startangle=90,
        colors=colors,
        explode=explode,
        shadow=True)

# Add title
plt.title('Relapse Rate Distribution', fontsize=16, pad=20)

# Equal aspect ratio ensures the pie chart is circular
plt.axis('equal')

# Add legend
plt.legend(title="Relapse Status",
          loc="upper right",
          labels=[f'{x} - {y:1.1f}%' for x,y in zip(relapse_counts.index, relapse_percent)])

plt.tight_layout()
plt.show()


# 2. Age Distribution
plt.subplot(4, 2, 2)
sns.histplot(data=df, x='Age', bins=20, kde=True)
plt.title('Age Distribution')

# 3. Time till Relapse Distribution
plt.subplot(4, 2, 3)
sns.histplot(data=relapsed, x='Time till Relapse (Days)', bins=30, kde=True)
plt.title('Time till Relapse Distribution (Days)')


# 5. Relapse by Marital Status
plt.subplot(4, 2, 5)
sns.countplot(data=df, x='Marital Status', hue='relapse')
plt.title('Relapse by Marital Status')

# 6. Relapse by Employment Status
plt.subplot(4, 2, 6)
sns.countplot(data=df, y='Employment Status', hue='relapse')
plt.title('Relapse by Employment Status')

# 7. Relapse by Qualification
plt.subplot(4, 2, 7)
sns.countplot(data=df, y='Qualification', hue='relapse', order=df['Qualification'].value_counts().index)
plt.title('Relapse by Qualification')

# 8. Age vs Time till Relapse
plt.subplot(4, 2, 8)
sns.scatterplot(data=relapsed, x='Age', y='Time till Relapse (Days)')
plt.title('Age vs Time till Relapse')

plt.tight_layout()
plt.show()

# Additional Analysis
# Correlation between numerical variables
numerical_cols = ['Age', 'Annual Income', 'Time till Relapse (Days)']
plt.figure(figsize=(10, 6))
sns.heatmap(df[numerical_cols].corr(), annot=True, cmap='coolwarm')
plt.title('Correlation Matrix')
plt.show()

# Time Series Analysis of Relapses
df['year_month'] = df['Date'].dt.to_period('M')
relapse_trend = df[df['relapse'] == 'Yes'].groupby('year_month').size()
plt.figure(figsize=(12, 6))
relapse_trend.plot(kind='line', marker='o')
plt.title('Monthly Relapse Trend')
plt.xlabel('Month')
plt.ylabel('Number of Relapses')
plt.grid()
plt.show()

# Analysis of frequent patients
frequent_patients = df['Registration Number'].value_counts().head(5)
print("\n=== Most Frequent Patients ===")
print(frequent_patients)

# Analyze the most frequent patient
most_frequent = df[df['Registration Number'] == 22100]
print("\n=== Details of Most Frequent Patient (Registration Number: 22100) ===")
print(most_frequent)