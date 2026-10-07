# Employee Exit Prediction Using Machine Learning

## 1. Project Overview

This project analyzes employee data to understand factors related to employee exit and predicts whether an employee is likely to leave.

### Models Used
- Decision Tree
- Artificial Neural Network (ANN)
- Maximum Margin Classifier (Linear SVM)

---

## 2. Dataset

The dataset contains employee information such as:

- Satisfaction level
- Last evaluation
- Number of projects
- Average monthly hours
- Time spent in company
- Department
- Salary
- Promotion history
- Employee exit (`left`)

`left = 0` → Stayed  
`left = 1` → Left

---

## 3. Data Cleaning

First, the dataset was checked for:

- Missing values
- Duplicate records

There were **no missing values**.

**3,008 duplicate records** were removed.

Final dataset:

**11,991 records and 10 variables**

---

## 4. Exploratory Data Analysis

The following factors were analyzed:

### Satisfaction
Employees who left generally had lower satisfaction levels.

### Working Hours
Average monthly working hours were compared between employees who stayed and left.

### Department
Exit rates were calculated for different departments.

### Salary
Exit rates were compared across salary levels.

### Promotion
Exit rates were compared between employees who received and did not receive promotions.

Graphs were created using `ggplot2`.

---

## 5. Machine Learning

The data was divided into:

- 80% Training
- 20% Testing

The numerical variables were standardized before using ANN and SVM.

### Decision Tree
Used as an interpretable classification model.

### Artificial Neural Network
Used to identify nonlinear relationships between employee characteristics and exit.

### Maximum Margin Classifier
A linear SVM was used to find the best separating boundary between employees who stayed and left.

Class weighting was used because the employee-exit classes were imbalanced.

---

## 6. Model Results

| Model | Accuracy | Precision | Recall | F1 Score |
|---|---:|---:|---:|---:|
| **Decision Tree** | **98.04%** | **96.80%** | **91.21%** | **93.92%** |
| ANN | 96.25% | 90.96% | 85.93% | 88.37% |
| Maximum Margin Classifier | 81.07% | 45.82% | 77.14% | 57.49% |

### Best Model

**Decision Tree**

It achieved the highest overall performance with an **F1 Score of 93.92%**.

---

## 7. Conclusion

Employee exit is associated with factors such as:

- Satisfaction
- Working hours
- Salary
- Department
- Promotion
- Recent performance

The Decision Tree performed best among the three models and can be used as a decision-support tool for identifying potential employee attrition.

---

## 8. How to Run

1. Install R and VS Code.
2. Keep `employee_data.csv` and `project.R` in the same folder.
3. Open `project.R` in VS Code.
4. Run the complete script.
5. Check the graphs and final model comparison.

### Project Files

```text
Employee_Exit_Project/
├── employee_data.csv
├── project.R
├── model_comparison.csv
└── README.md