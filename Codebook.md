Codebook - Class Project: Getting & Cleaning Data - July, 2014
========================================================



This document is the codebook for the class project assignment in Johns Hopkins' "Getting and Cleaning Data" class. Within this I describe the data sources, transformations, data output and other data aspects of the project. Information on running the associated R script are included in the README.md file in the same repository.

## Data Sources ##

This project involves a variety of movement information collected from persons wearing a Samsung Galaxy S smartphone. A full description of the data collection process can be found here:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The dataset itself was downloaded using this URL:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The downloaded zip file creates a directory containing a variety of files. This project utilized a subset of the available files:

### Download Files Utilized ###
#### Data files ####
1. X_test.txt
2. y_test.txt
3. subject_test.txt
4. X_train.txt
5. y_train.txt
6. subject_train.txt

#### Reference files ####
1. README.txt
2. features.txt
3. features_info.txt
4. activity_labels.txt

## Data File Manipulations ##

The data files encompass a pair of 3-set files. The pairs are train and test. Train and test are subsets of the full data set, likely used for regression or other types of statistical testing. My first manipulations involved combining the datasets back into a single data table. This was done is two steps; first the test and train sets were combined into a pair of tables using column manipulations and then the resulting two data frames were combined into a single data frame, named "consolidated" using a row-related function. The consolidated file was 10,299 x 563 in size.

### Column manipulations ###
```{r}
testCombined = cbind(testSubject, testY, testX)
trainCombined = cbind(trainSubject, trainY, trainX)
```
### Row based combination ###
```{r}
consolidated = rbind(trainCombined, testCombined)
```
The first two columns of the consolidated file represent the study subject and their activity for the row of data. These columns were relabled to Subject and Activity respectively using:
```{r}
colnames(consolidated)[1:2] = c("Subject", "Activity")
```
Column 2, Activity, is a numeric factor representing the activity for the row of measurements. The coding of this factor is identified in the "activity_labels.text" file mentioned above. There were six distinct activities. The numeric values in the column were coded to the text values using this command:
```{r}
consolidated$Activity = factor(consolidated$Activity,
                               labels = c("WALKING", "WALKING_UPSTAIRS",
                                          "WALKING_DOWNSTAIRS", "SITTING",
                                          "STANDING", "LAYING"))
 ```                                         
The phase ended with a single data.frame, "consolidated". The next step involved selecting which feature columns to include in the final file and the identification and selection of those columns.

## Feature Identification and Selection ##

There are a total of 563 variables available for analysis of which 561 are measurements associated with the specified patient and activity. The columns involved various statistical measures, such as mean, std. deviation and median, of a set of core movement measurements. A discussion of these variables is found in the features_info.txt file which is included at the end of this document. The core measurements are:
### Core Measurements ###
1. tBodyAcc-XYZ 
2. tGravityAcc-XYZ 
3. tBodyAccJerk-XYZ
4. tBodyGyro-XYZ
5. tBodyGyroJerk-XYZ
6. tBodyAccMag
7. tGravityAccMag
8. tBodyAccJerkMag
9. tBodyGyroMag
10. tBodyGyroJerkMag
11. fBodyAcc-XYZ
12. fBodyAccJerk-XYZ
13. fBodyGyro-XYZ
14. fBodyAccMag
15. fBodyAccJerkMag
16. fBodyGyroMag
17. fBodyGyroJerkMag

These are identified in the features.txt file and described in the features_info.txt file. The leading character, t or f, codes whether the measures were originally processed using time domain or frequency domain based techniques. Variables with a trailing "-XYZ" indicate that 3 separate features, representing a three dimensional axis, are associated with the measure. 

Our assignment called for using only the columns associated with the mean and standard deviation for each measurement. Using this constraint I extracted 6 features each for measures 1-5 & 11-13 and 2 features for measures 6-10 and 14-17 for a total feature set of 66. 

This extraction was done by first reading in the features file and then greping the column names for the strings of "mean()" and "std()" and using the column numbers to extract the subset from the consolidated file. The associated R commands are:
```{r}
features = read.table("features.txt")
meanColumns = grep("mean\\(\\)", features$V2)
stdColumns = grep("std\\(\\)", features$V2)
desiredColumns = sort(c(meanColumns, stdColumns))
tempData = data.table(consolidated[, c(1, 2, desiredColumns+2)])[order(Subject, Activity)]
 ``` 
There are 6 additional measures at the end of the file that contain the string "Mean". These did not seem to be appropriate for our analysis and I did not include them. The resultant table, tempData, is a data.table to enable a few functions used subsequently and to improve speed.

The selected features columns were then renamed to make them more readable. I prefaced each feature with either "Mean" or "Std" to indicate whether it is an mean or standard deviation feature. The t and f for replaced with TimeDom or FreqDom to indicate time domain or frequency domain processed features. The string "Acc" represents measures from the device accelerometer, "Gyro" measures from teh device gyroscope, Jerk represents linear and angular velocities. More detail on these measures can be found in the features_info.txt file. It is included in its entirety at the end of this document. Finally an X, Y or Z was included at the end for those 3 axis related measures. The command for this used the data.table function setnames:
```{r}
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
``` 

## Data Summarization ##
The project specified "Creates a second, independent tidy data set with the average of each variable for each activity and each subject.". This collapses the data set into one row per subject and activity. There are a total of 30 subjects and each subject has 6 activities. This gives the resulting tidy table a total length of 30 x 6 or 180 rows. We have the same number of columns; Subject, Activity, and the average of 66 measures variables for a total of 68 columns. Our final tidy table is 180 x 68 in size. I accomplished the summarization by Subject and Activity using the data.table form:
```{r}
tidyData = tempData[, lapply(.SD, mean), by = c("Subject", "Activity")]
```

## Data Output ##
An output file named "Project_Tidy_Data.txt" was written to the working directory using the command:
```{r}
write.table(tidyData, file = "Project_Tidy_Data.txt")
```

# features_info.txt file #

Feature Selection 

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

 * tBodyAcc-XYZ 
 * tGravityAcc-XYZ 
 * tBodyAccJerk-XYZ 
 * tBodyGyro-XYZ 
 * tBodyGyroJerk-XYZ 
 * tBodyAccMag 
 * tGravityAccMag 
 * tBodyAccJerkMag 
 * tBodyGyroMag 
 * tBodyGyroJerkMag 
 * fBodyAcc-XYZ 
 * fBodyAccJerk-XYZ 
 * fBodyGyro-XYZ 
 * fBodyAccMag 
 * fBodyAccJerkMag 
 * fBodyGyroMag 
 * fBodyGyroJerkMag 

The set of variables that were estimated from these signals are: 

 * mean(): Mean value 
 * std(): Standard deviation 
 * mad(): Median absolute deviation 
 * max(): Largest value in array 
 * min(): Smallest value in array 
 * sma(): Signal magnitude area 
 * energy(): Energy measure. Sum of the squares divided by the number of values.  
 * iqr(): Interquartile range  
 * entropy(): Signal entropy 
 * arCoeff(): Autorregresion coefficients with Burg order equal to 4 
 * correlation(): correlation coefficient between two signals 
 * maxInds(): index of the frequency component with largest magnitude 
 * meanFreq(): Weighted average of the frequency components to obtain a mean frequency 
 * skewness(): skewness of the frequency domain signal  
 * kurtosis(): kurtosis of the frequency domain signal  
 * bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window. 
 * angle(): Angle between to vectors. 

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

 * gravityMean 
 * tBodyAccMean 
 * tBodyAccJerkMean 
 * tBodyGyroMean 
 * tBodyGyroJerkMean 

The complete list of variables of each feature vector is available in 'features.txt'
