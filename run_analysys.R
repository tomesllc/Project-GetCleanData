## Project for Coursera "Getting and Cleaning Data" course
# July, 2014

# Call data.table for later use
library(data.table)

# Read in test data sets
# Subject identifier 
testSubject = read.table("subject_test.txt")
# Actual data measurements
testX = read.table("X_test.txt")
# Activity identifier
testY = read.table("y_test.txt")

# Combine test data by column
testCombined = cbind(testSubject, testY, testX)

# Read in train data sets
# Subject identifiers
trainSubject = read.table("subject_train.txt")
# Actual data measurements
trainX = read.table("X_train.txt")
# Activity identifier
trainY = read.table("y_train.txt")

# Combine train data by column
trainCombined = cbind(trainSubject, trainY, trainX)

# Create consolidated file by combining test and training files using rbind
consolidated = rbind(trainCombined, testCombined)

# Relabel the first 2 columns to Subject and Activity
colnames(consolidated)[1:2] = c("Subject", "Activity")

# Convert the Activity column to a factor and change its value to the appropriate
# text string from activities_labels.txt file
consolidated$Activity = factor(consolidated$Activity,
                               labels = c("WALKING", "WALKING_UPSTAIRS",
                                          "WALKING_DOWNSTAIRS", "SITTING",
                                          "STANDING", "LAYING"))

# Read in features file to identify columns for extractions
features = read.table("features.txt")

# Analysis of the provided data and its codebook led me to extract only those
# features with "mean()" in their titles. See my.codebook in repository. The 
# parenthesis were escaped using the \\ operator. 
meanColumns = grep("mean\\(\\)", features$V2)

# Identify features column numbers with "std()" in their titles. The parenthesis
# were escaped using the \\ operator
stdColumns = grep("std\\(\\)", features$V2)

# Combine the two feature vectors of column numbers and order it so the tidy 
# file will more closely follow the order of the original features file. 
desiredColumns = sort(c(meanColumns, stdColumns))


# Extract desired columns from consolidated file. Add 2 to account for presence
# of Subject and Activity columns. Make it a data.table to use setnames and 
# "by" functionality for summarizing
tempData = data.table(consolidated[, c(1, 2, desiredColumns+2)])[order(Subject, Activity)]

# Set column names to values in features file for review and verification.
# Will reset after summarizing data into final tidy data table
setnames(tempData, old = 3:68, new = as.character(features[desiredColumns,2]))

# Set feature column names, except Subject & Activity, to more human readable
# values. See codebook for more detailed explanation of meanings.
setnames(tempData, old = 3:68, 
         new = c("MeanTimeDomBodyAcc_X", "MeanTimeDomBodyAcc_Y", "MeanTimeDomBodyAcc_Z",
                 "StdTimeDomBodyAcc_X", "StdTimeDomBodyAcc_Y", "StdTimeDomBodyAcc_Z",
                 "MeanTimeDomGravityAcc_X", "MeanTimeDomGravityAcc_Y", "MeanTimeDomGravityAcc_Z",
                 "StdTimeDomGravityAcc_X", "StdTimeDomGravityAcc_Y", "StdTimeDomGravityAcc_Z",
                 "MeanTimeDomBodyAccJerk_X", "MeanTimeDomBodyAccJerk_Y", "MeanTimeDomBodyAccJerk_Z",
                 "StdTimeDomBodyAccJerk_X", "StdTimeDomBodyAccJerk_Y", "StdTimeDomBodyAccJerk_Z",
                 "MeanTimeDomBodyGyro_X", "MeanTimeDomBodyGyro_Y", "MeanTimeDomBodyGyro_Z",
                 "StdTimeDomBodyGyro_X", "StdTimeDomBodyGyro_Y", "StdTimeDomBodyGyro_Z",
                 "MeanTimeDomainBodyGyroJerk_X", "MeanTimeDomainBodyGyroJerk_Y", "MeanTimeDomainBodyGyroJerk_Z",
                 "StdTimeDomainBodyGyroJerk_X", "StdTimeDomainBodyGyroJerk_Y", "StdTimeDomainBodyGyroJerk_Z",
                 "MeanTimeDomBodyAccMag", "StdTimeDomBodyAccMag",
                 "MeanTimeDomGravityAccMag", "StdTimeDomGravityAccMag",
                 "MeanTimeDomBodyAccJerkMag", "StdTimeDomBodyAccJerkMag",
                 "MeanTimeDomBodyGyroMag", "StdTimeDomBodyGyroMag",
                 "MeanTimeDomBodyGyroJerkMag", "StdTimeDomBodyGyroJerkMag",
                 "MeanFreqDomBodyAcc_X", "MeanFreqDomBodyAcc_Y", "MeanFreqDomBodyAcc_Z",
                 "StdFreqDomBodyAcc_X", "StdFreqDomBodyAcc_Y", "StdFreqDomBodyAcc_Z",
                 "MeanFreqBodyAccJerk_X", "MeanFreqBodyAccJerk_Y", "MeanFreqBodyAccJerk_Z",
                 "StdFreqBodyAccJerk_X", "StdFreqBodyAccJerk_Y", "StdFreqBodyAccJerk_Z",
                 "MeanFreqDomBodyGyro_X", "MeanFreqDomBodyGyro_Y", "MeanFreqDomBodyGyro_Z",
                 "StdFreqDomBodyGyro_X", "StdFreqDomBodyGyro_Y", "StdFreqDomBodyGyro_Z", 
                 "MeanFreqBodyAccMag", "StdFreqBodyAccMag",
                 "MeanFreqBodyAccJerkMag", "StdFreqBodyAccJerkMag",
                 "MeanFreqBodyGyroMag", "StdFreqBodyGyroMag",
                 "MeanFreqBodyGyroJerkMag", "StdFreqBodyGyroJerkMag"))

# Now summarize by Subject and Activity, create final tidyData table
tidyData = tempData[, lapply(.SD, mean), by = c("Subject", "Activity")]


# Finally write out the tidy data table into a space delimited text file in the 
# currrent working directory
write.table(tidyData, file = "Project_Tidy_Data.txt")

