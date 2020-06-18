---
title: "Getting and Cleaning Data Course Project_CodeBook.md"
output: html_document
---

This is a code book for the "Getting and Cleaning Data" Course project assignment.  

The purpose of project is to *"demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected."* - from the course project instruction 

In this course assignment, one should create one R script called **"run_analysis.R"** that does following.  

1. Merges the training and the test sets to create one data set.  
2. Extracts only the measurements on the mean and standard deviation for each measurement.  
3. Uses descriptive activity names to name the activities in the data set  
4. Appropriately labels the data set with descriptive variable names.  
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.  

## The Data source and Data information
- The Dataset: 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
- The original study information is avaialble at:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  

## Description of the files
The original files (under "UCI HAR Dataset") used to complete the task above is as below:

- 'README.txt'  
- 'features_info.txt': Shows information about the variables used on the feature vector.  
- 'features.txt': List of all features.  
- 'activity_labels.txt': Links the class labels with their activity name.  
- 'train/X_train.txt': Training set.  
- 'train/y_train.txt': Training labels.  
- 'test/X_test.txt': Test set.  
- 'test/y_test.txt': Test labels.  

## Preparation 1. Download the Data 
```{r}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## Download the file from the fileURL above 
download.file(fileURL, "UCI HAR Dataset.zip", method = "curl")
## Unzip the dataset 
if(!file.exists("UCI HAR Dataset")){unzip(zipfile = "UCI HAR Dataset.zip", exdir = "./dataset")}
path <- file.path("./dataset/UCI HAR Dataset")
files <- list.files(path)
## Check if files are properly downloaded 
print(files)
```

## Preparation 2. Load all the data into the variables  
```{r}
## First, load all the data into variables (subjects: subjects, x: features, y: activity)
trainx <- read.table("./dataset/UCI HAR Dataset/train/X_train.txt")
trainy <- read.table("./dataset/UCI HAR Dataset/train/Y_train.txt")
testx <- read.table("./dataset/UCI HAR Dataset/test/X_test.txt")
testy <- read.table("./dataset/UCI HAR Dataset/test/Y_test.txt")
testsubjects <- read.table("./dataset/UCI HAR Dataset/test/subject_test.txt")
trainsubjects <- read.table("./dataset/UCI HAR Dataset/train/subject_train.txt")
activitylabels <- read.table("./dataset/UCI HAR Dataset/activity_labels.txt")
featuresname <- read.table("./dataset/UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
str(featuresname) ## has 561 observations of 2 variables (V1: integer, V2: character)
```

## Step 1. Create the combined dataframe of train and test datasets
```{r}
subjects <- rbind(trainsubjects, testsubjects)
features <- rbind(trainx, testx)
activity <- rbind(trainy, testy)

colnames(subjects) <- "Subject"
colnames(activity) <- "Activity"
colnames(features) <- featuresname$V2
completedata <- cbind(subjects, activity, features)
str(completedata) #data.frame, 10299 observations of 563 variables (subject, activity, and featuresname)
```

## Step 2. Extract only the measurements on the mean and standard deviation for each measurement 
```{r}
## Create a new character variable that includes features name including mean() and std() only 
extractedfeatures <- featuresname$V2[grep("mean\\(\\)|std\\(\\)", featuresname$V2)] #class(extractedfeatures) returns character
extracteddata <- completedata[c("Activity", "Subject", extractedfeatures)]
str(extracteddata) #returning data.frame of 10299 observations of 68 variables (activity, subject, and 66 features variable - including only mean and std)
```

## Step 3. Uses descriptvie activity names to name the activities in the data set 
```{r}
extracteddata$Activity <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LYING")[extracteddata$Activity]
str(extracteddata$Activity)
```

## Step 4. Appropriately labels the dataset with descriptive variable names
```{r}
names(extracteddata) <- gsub("^t", "Time", names(extracteddata))
names(extracteddata) <- gsub("^f", "Frequency", names(extracteddata))
names(extracteddata) <- gsub("Acc", "Accelerometer", names(extracteddata))
names(extracteddata) <- gsub("Gyro", "Gyroscope", names(extracteddata))
names(extracteddata) <- gsub("Mag", "Magnitude", names(extracteddata))
names(extracteddata) <- gsub("BodyBody", "Body", names(extracteddata))
str(extracteddata) #To check data appearance
```

## Step 5. From the dataset in step 4, creates a second, independent tidy data set with the average of each variable activity and each subject
```{r}
library(dplyr)
Subject <- as.factor("Subject")
Activity <- as.factor("Activity")
tidydata <- extracteddata %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))
write.table(tidydata, file = "tidydata.txt", row.name = FALSE)
print(write.table)
```