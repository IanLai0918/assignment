mergeData=merge(test,train,by.x="X_test",by.y="X_train",all=TRUE)
dataMean=subset(mergeData$mean)
dataSd=subset(mergeData$sd)
