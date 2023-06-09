library(ranger)
library(caret)
library(data.table)
library(caTools)
library(rpart)
library(rpart.plot)
library(gbm, quietly=TRUE)
library(pROC)


setwd("D:/R programming/creditcard")
df=read.csv("D:/R programming/creditcard/creditcard.csv")

head(df)

sum(is.na(df))
dim(df)
table(df$Class)
summary(df$Amount)

names(df)
var(df$Amount)
sd(df$Amount)

df$Amount=scale(df$Amount)
df_1=df[,-c(1)]
head(df_1)


set.seed(123)
split = sample.split(df_1$Class,SplitRatio=0.80)
train_data = subset(df_1,split==TRUE)
test_data = subset(df_1,split==FALSE)

dim(train_data)
dim(test_data)


lm=glm(Class~.,test_data,family=binomial())
summary(lm)

plot(lm)

lr_predict <- predict(lm,train_data, probability = TRUE)

cm = table(train_data[, 30], lr_predict > 0.5)
cm

lr_predict_test <- predict(lm,test_data, probability = TRUE)

cm = table(test_data[, 30], lr_predict_test > 0.5)
cm

decisionTree_model <- rpart(Class ~ . , df, method = 'class')
predicted_val <- predict(decisionTree_model, df, type = 'class')
probability <- predict(decisionTree_model, df, type = 'prob')

rpart.plot(decisionTree_model)


# Get the time to train the GBM model
system.time(
  model_gbm <- gbm(Class ~ .
                   , distribution = "bernoulli"
                   , data = rbind(train_data, test_data)
                   , n.trees = 500
                   , interaction.depth = 3
                   , n.minobsinnode = 100
                   , shrinkage = 0.01
                   , bag.fraction = 0.5
                   , train.fraction = nrow(train_data) / (nrow(train_data) + nrow(test_data))
  )
)


gbm.iter = gbm.perf(model_gbm, method = "test")
plot(model_gbm)


gbm_test = predict(model_gbm, newdata = test_data, n.trees = gbm.iter)
gbm_auc = roc(test_data$Class, gbm_test, plot = TRUE, col = "red")

print(gbm_auc)

# develop our credit card fraud detection model using machine learning.
# We used a variety of ML algorithms to implement this model and also plotted
# the respective performance curves for the models.
