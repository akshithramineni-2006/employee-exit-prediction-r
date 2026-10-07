# PACKAGES
library(data.table)
library(ggplot2)
library(caret)
library(rpart)
library(nnet)
library(e1071)


# 1. DATASET EXPLORATION AND CLEANING

df <- fread("data/employee_data.csv")

cat("========== DATASET INFORMATION ==========\n")
cat("Rows:", nrow(df), "\n")
cat("Columns:", ncol(df), "\n")
cat("Missing values:", sum(is.na(df)), "\n")
cat("Duplicate records:", sum(duplicated(df)), "\n")

# Remove duplicates
df <- unique(df)

cat("Records after cleaning:", nrow(df), "\n\n")

# Exit distribution
cat("========== EMPLOYEE EXIT ==========\n")
print(table(df$left))
print(round(prop.table(table(df$left)) * 100, 2))



# GRAPH 1: EMPLOYEE EXIT DISTRIBUTION
p1 <- ggplot(df, aes(x = factor(left))) +
  geom_bar() +
  labs(
    title = "Employee Exit Distribution",
    x = "Exit (0 = Stayed, 1 = Left)",
    y = "Number of Employees"
  ) +
  theme_minimal()

print(p1)


# 2. SATISFACTION LEVEL VS EXIT

cat("\n========== SATISFACTION VS EXIT ==========\n")

print(
  aggregate(
    satisfaction_level ~ left,
    df,
    mean
  )
)

p2 <- ggplot(
  df,
  aes(
    x = factor(left),
    y = satisfaction_level
  )
) +
  geom_boxplot() +
  labs(
    title = "Satisfaction Level vs Employee Exit",
    x = "Exit (0 = Stayed, 1 = Left)",
    y = "Satisfaction Level"
  ) +
  theme_minimal()

print(p2)


# 3. WORKING HOURS VS EXIT
cat("\n========== WORKING HOURS VS EXIT ==========\n")

print(
  aggregate(
    average_montly_hours ~ left,
    df,
    mean
  )
)

p3 <- ggplot(
  df,
  aes(
    x = factor(left),
    y = average_montly_hours
  )
) +
  geom_boxplot() +
  labs(
    title = "Working Hours vs Employee Exit",
    x = "Exit (0 = Stayed, 1 = Left)",
    y = "Average Monthly Hours"
  ) +
  theme_minimal()

print(p3)


# GRAPH 4: SATISFACTION + WORKING HOURS
p4 <- ggplot(
  df,
  aes(
    x = average_montly_hours,
    y = satisfaction_level,
    color = factor(left)
  )
) +
  geom_point(alpha = 0.3) +
  labs(
    title = "Satisfaction and Working Hours vs Employee Exit",
    x = "Average Monthly Hours",
    y = "Satisfaction Level",
    color = "Exit"
  ) +
  theme_minimal()

print(p4)


# 4. DEPARTMENT, SALARY AND PROMOTION

df$Department <- as.factor(df$Department)
df$salary <- as.factor(df$salary)

# DEPARTMENT 
department_exit <- aggregate(
  left ~ Department,
  df,
  mean
)

department_exit$Exit_Rate <-
  department_exit$left * 100

cat("\n========== DEPARTMENT EXIT RATE ==========\n")
print(department_exit)


# GRAPH 5: DEPARTMENT EXIT RATE
p5 <- ggplot(
  department_exit,
  aes(
    x = Department,
    y = Exit_Rate
  )
) +
  geom_col() +
  labs(
    title = "Employee Exit Rate by Department",
    x = "Department",
    y = "Exit Rate (%)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x =
      element_text(
        angle = 45,
        hjust = 1
      )
  )

print(p5)


#SALARY 
salary_exit <- aggregate(
  left ~ salary,
  df,
  mean
)

salary_exit$Exit_Rate <-
  salary_exit$left * 100

cat("\n========== SALARY EXIT RATE ==========\n")
print(salary_exit)


# GRAPH 6: SALARY EXIT RATE
p6 <- ggplot(
  salary_exit,
  aes(
    x = salary,
    y = Exit_Rate
  )
) +
  geom_col() +
  labs(
    title = "Employee Exit Rate by Salary",
    x = "Salary Level",
    y = "Exit Rate (%)"
  ) +
  theme_minimal()

print(p6)


# PROMOTION
promotion_exit <- aggregate(
  left ~ promotion_last_5years,
  df,
  mean
)

promotion_exit$Exit_Rate <-
  promotion_exit$left * 100

cat("\n========== PROMOTION EXIT RATE ==========\n")
print(promotion_exit)


# GRAPH 7: PROMOTION EXIT RATE
p7 <- ggplot(
  promotion_exit,
  aes(
    x = factor(promotion_last_5years),
    y = Exit_Rate
  )
) +
  geom_col() +
  labs(
    title = "Employee Exit Rate by Promotion",
    x = "Promotion in Last 5 Years (0 = No, 1 = Yes)",
    y = "Exit Rate (%)"
  ) +
  theme_minimal()

print(p7)

# 5. MACHINE LEARNING DATA PREPARATION
df$left <- factor(
  df$left,
  levels = c(0, 1)
)

model_matrix <- model.matrix(
  left ~
    satisfaction_level +
    last_evaluation +
    number_project +
    average_montly_hours +
    time_spend_company +
    Work_accident +
    promotion_last_5years +
    Department +
    salary,
  data = df
)

X <- model_matrix[, -1]
y <- df$left

# 80/20 Train-Test Split
set.seed(42)

train_id <- createDataPartition(
  y,
  p = 0.80,
  list = FALSE
)

X_train <- X[train_id, ]
X_test <- X[-train_id, ]

y_train <- y[train_id]
y_test <- y[-train_id]

# Scale predictors
scale_model <- preProcess(
  X_train,
  method = c(
    "center",
    "scale"
  )
)

X_train_scaled <-
  predict(
    scale_model,
    X_train
  )

X_test_scaled <-
  predict(
    scale_model,
    X_test
  )

cat("\n========== MODEL DATA ==========\n")
cat(
  "Training records:",
  nrow(X_train),
  "\n"
)

cat(
  "Testing records:",
  nrow(X_test),
  "\n"
)


# 6. DECISION TREE
tree_data <- data.frame(X_train)

tree_data$left <- y_train

tree_model <- rpart(
  left ~ .,
  data = tree_data,
  method = "class"
)

tree_pred <- predict(
  tree_model,
  data.frame(X_test),
  type = "class"
)

cat("\nDecision Tree completed.\n")


# 7. ARTIFICIAL NEURAL NETWORK
set.seed(42)

ann_model <- nnet(
  X_train_scaled,
  class.ind(y_train),
  size = 8,
  decay = 0.001,
  maxit = 300,
  trace = FALSE
)

ann_prob <- predict(
  ann_model,
  X_test_scaled,
  type = "raw"
)

ann_pred <- factor(
  ifelse(
    ann_prob[, 2] > 0.5,
    1,
    0
  ),
  levels = c(0, 1)
)

cat("Artificial Neural Network completed.\n")


# 8. MAXIMUM MARGIN CLASSIFIER
set.seed(42)

svm_model <- svm(
  X_train_scaled,
  y_train,
  kernel = "linear",
  cost = 1,

  # Handle class imbalance
  class.weights = c(
    "0" = 1,
    "1" = 3
  )
)

svm_pred <- predict(
  svm_model,
  X_test_scaled
)

cat(
  "Maximum Margin Classifier completed.\n"
)


# 9. MODEL EVALUATION FUNCTION
get_metrics <- function(
  actual,
  predicted
) {

  cm <- table(
    Actual = actual,
    Predicted = predicted
  )

  TP <- cm["1", "1"]
  TN <- cm["0", "0"]
  FP <- cm["0", "1"]
  FN <- cm["1", "0"]

  accuracy <-
    (TP + TN) / sum(cm)

  precision <-
    TP / (TP + FP)

  recall <-
    TP / (TP + FN)

  f1 <-
    2 * precision * recall /
    (precision + recall)

  return(
    c(
      Accuracy = accuracy,
      Precision = precision,
      Recall = recall,
      F1 = f1
    )
  )
}


# 10. CALCULATE MODEL PERFORMANCE
tree_score <-
  get_metrics(
    y_test,
    tree_pred
  )

ann_score <-
  get_metrics(
    y_test,
    ann_pred
  )

svm_score <-
  get_metrics(
    y_test,
    svm_pred
  )


# 11. FINAL MODEL COMPARISON
comparison <- data.frame(

  Model = c(
    "Decision Tree",
    "Artificial Neural Network",
    "Maximum Margin Classifier"
  ),

  Accuracy = round(
    c(
      tree_score["Accuracy"],
      ann_score["Accuracy"],
      svm_score["Accuracy"]
    ),
    4
  ),

  Precision = round(
    c(
      tree_score["Precision"],
      ann_score["Precision"],
      svm_score["Precision"]
    ),
    4
  ),

  Recall = round(
    c(
      tree_score["Recall"],
      ann_score["Recall"],
      svm_score["Recall"]
    ),
    4
  ),

  F1_Score = round(
    c(
      tree_score["F1"],
      ann_score["F1"],
      svm_score["F1"]
    ),
    4
  )
)

cat("\n============================================\n")
cat("FINAL MODEL COMPARISON\n")
cat("============================================\n")

print(comparison)


# GRAPH 8: MODEL COMPARISON
comparison_long <- data.frame(

  Model = rep(
    comparison$Model,
    4
  ),

  Metric = rep(
    c(
      "Accuracy",
      "Precision",
      "Recall",
      "F1 Score"
    ),
    each = 3
  ),

  Score = c(
    comparison$Accuracy,
    comparison$Precision,
    comparison$Recall,
    comparison$F1_Score
  )
)

p8 <- ggplot(
  comparison_long,
  aes(
    x = Model,
    y = Score,
    fill = Metric
  )
) +
  geom_col(
    position = "dodge"
  ) +
  labs(
    title = "Machine Learning Model Comparison",
    x = "Model",
    y = "Score"
  ) +
  theme_minimal() +
  theme(
    axis.text.x =
      element_text(
        angle = 20,
        hjust = 1
      )
  )

print(p8)


# 12. BEST MODEL
best_model <-
  comparison$Model[
    which.max(
      comparison$F1_Score
    )
  ]

cat(
  "\n============================================\n"
)

cat(
  "BEST MODEL:",
  best_model,
  "\n"
)

cat(
  "============================================\n"
)


# 13. SAVE RESULTS
write.csv(
  comparison,
  "model_comparison.csv",
  row.names = FALSE
)

cat(
  "\nResults saved as model_comparison.csv\n"
)

