# Statistical Learning Methods
# Contact: lukasz.krainski123@gmail.com / lkrain@sgh.waw.pl
# Class 4

#### Tree-based ML algorithms:
#CART & C4.5,
#Random forests,
#Extremely random forests,
#Boosted Trees

dataset = read.csv("https://raw.githubusercontent.com/KrainskiL/SLM_S2021/main/Class4/Class4_data.csv",
                   header=T,stringsAsFactors = F)
head(dataset)

#Preprocessing
dataset$movie_title = gsub("?","",dataset$movie_title)
genres = strsplit(dataset$genres,split="\\|")
genres_binary = sapply(unique(unlist(genres)), function(x) sapply(genres, function(y) x%in%y))
dataset=cbind(dataset, genres_binary)
colnames(dataset) = gsub("-","",colnames(dataset))


dataset = dataset[!(apply(dataset,1,function(x) any(is.na(x)))),]
dataset = dataset[,apply(dataset,2,function(x) length(unique(x)))>1]
head(dataset)
colnames(dataset)
sapply(dataset, summary)

apply(dataset[,sapply(dataset,typeof)=="character"],2,function(x) length(unique(x)))
dataset = dataset[,-c(1, 2, 7, 10, 11, 12, 15, 17, 18, 20, 21, 22)]

#Spliting dataset
training = sample(1:nrow(dataset), 0.9*nrow(dataset))

trainingset = dataset[training,]
testset = dataset[-training,]

#### EDA ####

par(mfrow=c(3,5))
plotNumeric = function(x,x_nms){
  plot(x, trainingset$imdb_score, pch=20, ylab="imdb_score",xlab=x_nms)
  grid()
  lines(smooth.spline(x, trainingset$imdb_score),col=2,lwd=2)
  abline(lm(trainingset$imdb_score~x),col="blue")
}

invisible(mapply(plotNumeric, x=trainingset[,c(1:13, 15:16)], x_nms=colnames(trainingset)[c(1:13, 15:16)]))

par(mfrow=c(4,6))
plotBarplot = function(x,x_nms){
  barplot(tapply(trainingset$imdb_score,x,mean), ylab="imdb_score",names.arg=c("FALSE","TRUE"),xlab=x_nms,ylim=c(0,10))
}

mapply(plotBarplot, x=trainingset[,c(17:38)], x_nms=colnames(trainingset)[c(17:38)])
par(mfrow=c(1,1))

#### Classificaton and Regression Trees & C4.5 ####
# CART algorithm pick splitting variables using:
# for classification: minimization of homogeneity measure (Gini index/entropy)
# for regression: minimization of prediction error (e.g. SSE)
library(rpart)
rpart_initial = rpart(imdb_score~., data=trainingset,cp=0)
plot(rpart_initial)

#Picking optimal complexity based on CV error
rpart_initial$cptable
plotcp(rpart_initial)
cp_optimal = rpart_initial$cptable[which(rpart_initial$cptable[,"xerror"]==min(rpart_initial$cptable[,"xerror"])),"CP"]
rpart_optimal = prune(rpart_initial, cp_optimal)

#Tree visualization
plot(rpart_optimal)
text(rpart_optimal)

rpart_prediction = predict(rpart_optimal, newdata=testset)
plot(testset$imdb_score, rpart_prediction, xlim=c(0,10),ylim=c(0,10), pch=20); abline(0,1,col="red")
rpart_rmse = sqrt(1/nrow(testset) * sum((testset$imdb_score - rpart_prediction)^2))
rpart_rmse
#Confusion matrix
mt_rpart = table(round(predict(rpart_optimal,newdata = testset)), round(testset$imdb_score))

mt_rpart
diagonal_sum = 0
for (i in 3:8){
  diagonal_sum = diagonal_sum + mt_rpart[as.character(i),as.character(i)]
}
#Accuracy
diagonal_sum/sum(mt_rpart)

library(party)
ctree_initial = ctree(imdb_score~., data=trainingset,controls = ctree_control(teststat = "quad", testtype = "Bonferroni", mincriterion = 0.99))
summary(ctree_initial)
plot(ctree_initial)

ctree_prediction = predict(ctree_initial, newdata=testset)
ctree_rmse = sqrt(1/nrow(testset) * sum((testset$imdb_score - ctree_prediction)^2))
ctree_rmse
#### Random Forest ####
install.packages("randomForest")
library(randomForest)
rf_initial = randomForest(imdb_score~., data=trainingset, ntree=500, do.trace=T)
rf_initial
varImpPlot(rf_initial)
plot(rf_initial)

mtry=c(1:ncol(trainingset))
error=c()

for(i in 1:length(mtry)){
  print(i)
  error[i] = randomForest(imdb_score~., data=trainingset, ntree=50, mtry=mtry[i])$mse[50]
}

plot(mtry, error, type="l")

rf_optimal = randomForest(imdb_score~., data=trainingset, ntree=250, mtry=12, do.trace=T)

rf_prediction = predict(rf_optimal, newdata=testset)
plot(testset$imdb_score, rf_prediction, xlim=c(0,10),ylim=c(0,10), pch=20); abline(0,1,col="red")
rf_rmse = sqrt(1/nrow(testset) * sum((testset$imdb_score - rf_prediction)^2))
rf_rmse

#### Extra Trees ####
# extraTrees (Extremely Randomized Trees)
# Java needed to use the library!
# extraTrees don't do bagging
# Even less correlated trees compared to random forest

library(extraTrees)

et_model = extraTrees(x=data.matrix(trainingset[,-14]), y = data.matrix(trainingset[,14]),ntree=250, mtry=12)
et_prediction = predict(et_model, newdata=data.matrix(testset[,-14]))
plot(testset$imdb_score, et_prediction, xlim=c(0,10),ylim=c(0,10), pch=20); abline(0,1,col="red")
et_rmse = sqrt(1/nrow(testset) * sum((testset$imdb_score - et_prediction)^2))
et_rmse

#### Boosted Trees ####
# Gradient Boosting (XGBoost)
# Gradient boosting is an ensemble algorithm and may be mixed with decision trees
# Trees are build iteratively based on previous model characteristics
# Impact of new trees is controlled by learning rate (similar as in gradient-based algorithms e.g. neural networks)

library(xgboost)
colnames(trainingset)
xg_initial = xgboost::xgboost(data=data.matrix(trainingset[,-14]), label=trainingset[,14],nrounds=150,params=list(booster="gbtree", eta=0.10, max_depth = 3, subsample = 0.50, colsample_bytree=0.50))
xg_optimal = xg_initial

xg_prediction = predict(xg_optimal, newdata=data.matrix(testset[,-14]))
plot(testset$imdb_score, xg_prediction, xlim=c(0,10),ylim=c(0,10), pch=20); abline(0,1,col="red")
xg_rmse = sqrt(1/nrow(testset) * sum((testset$imdb_score - xg_prediction)^2))
xg_rmse

#### SUMMARY ####

results=matrix(c(rpart_rmse, ctree_rmse, rf_rmse, et_rmse, xg_rmse), ncol=1,dimnames=list(c("rpart","ctree","randomForest","extraTrees","xgboost"),"RMSE"))
print(results)
barplot(results[,1],ylim=c(0,1),border=F,main="RMSE error for different models",ylab = "RMSE",col=rgb(seq(0,1,length=100),seq(1,0,length=100),0)[pmax(5,round(100*(results[,1]-min(results[,1]))/(max(results)-min(results))))])
