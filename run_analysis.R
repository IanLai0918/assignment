# 20-6-2018

## Mission: Read, merge and clean the data, extract mean and SD

# step 1: read the data features
features <- read.table("UCI HAR Dataset/features.txt")

# step 2 : read and combine the test data
test_X <- read.table("UCI HAR Dataset/test/X_test.txt",col.names = features[,2])
test_Y <- read.table("UCI HAR Dataset/test/Y_test.txt",col.names = "y")
testsub <- read.table("UCI HAR Dataset/test/subject_test.txt",col.names ="subject")
test <- cbind(testsub,test_X,test_Y)

# step 3 : read and combine the training data
training_X <- read.table("UCI HAR Dataset/train/X_train.txt",col.names = features[,2])
training_Y <- read.table("UCI HAR Dataset/train/Y_train.txt", col.names = "y")
trainingsub <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
training <- cbind(trainingsub,training_X, training_Y)


# step 4 : merge the 2 data
whole <- rbind(training,test)

# step 5 : subset only the columns containing mean and SD 
all <-whole[,c(1,grep("(.*)mean|std(.*)",colnames(whole)),ncol(whole))]

# step 6 : label the descriptive appropriate activity names 
act <- read.table("UCI HAR Dataset/activity_labels.txt",colClasses = "character")
all[,"activity"] <-all$y
for (nn in 1:6)
{ 
  all$activity[which(all$y==nn)] <- act[nn,2]
}


# step 7 : find mean for each variable for each activity (need to split by activity and subject)

ok <- split(all, list(whole$subject,all$y))

# step 8 : find average
dummy <- sapply(ok,function(x){colMeans(x[,c(-1,-ncol(x),-ncol(x)-1)], na.rm = T)})
avg <- aperm(dummy,2:1)

# sstep 9 : add columns for activity and subject
sub <- aperm(sapply(rownames(avg),function(x){strsplit(x,"\\.")[[1]]}),2:1)
rownames(sub) <- NULL
colnames(sub) <- c("subject","activity")

#step 10 : finish it 
final <- data.frame(cbind(sub,avg))

# step 11 : rename the variables
colnames(final) <- gsub("\\.\\.\\.","_", colnames(final))
colnames(final) <- gsub("\\.\\.","", colnames(final))
colnames(final) <- gsub("\\.","_", colnames(final))
colnames(final) <- gsub("^t","", colnames(final))
colnames(final) <- gsub("^f","FFT", colnames(final))
colnames(final) <- gsub("fBody","freq. body ", colnames(final))
colnames(final) <- gsub("BodyBody","Body", colnames(final))
colnames(final)[ncol(final)] <- "activity factor"

# Write data to a txt file
write.table(final,file = "final_averages.txt", row.names = F)
