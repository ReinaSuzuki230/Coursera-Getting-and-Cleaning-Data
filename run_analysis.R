
## Create directory named "data" and set it as work directory
if(!dir.exists("./data")) dir.create("./data")
setwd("./data")
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## Download the file from the fileURL above 
download.file(fileURL, "UCI HAR Dataset.zip", method = "curl")
## Unzip the dataset 
if(!file.exists("UCI HAR Dataset")){unzip(zipfile = "UCI HAR Dataset.zip", exdir = "./dataset")}
path <- file.path("./dataset/UCI HAR Dataset")
files <- list.files(path)
## Check if files are properly downloaded 
print(files)

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

#Step 1. Create the combined dataframe of train and test datasets
## Concatenate test and train data 
subjects <- rbind(trainsubjects, testsubjects)
features <- rbind(trainx, testx)
activity <- rbind(trainy, testy)

colnames(subjects) <- "Subject"
colnames(activity) <- "Activity"
colnames(features) <- featuresname$V2
completedata <- cbind(subjects, activity, features)
str(completedata) #data.frame, 10299 observations of 563 variables (subject, activity, and featuresname)

#Step 2. Extract only the measurements on the mean and standard deviation for each measurement 
## Create a new character variable that includes features name including mean() and std() only 
extractedfeatures <- featuresname$V2[grep("mean\\(\\)|std\\(\\)", featuresname$V2)] #class(extractedfeatures) returns character
extracteddata <- completedata[c("Activity", "Subject", extractedfeatures)]
str(extracteddata) #returning data.frame of 10299 observations of 68 variables (activity, subject, and 66 features variable - including only mean and std)

#Step 3. Uses descriptvie activity names to name the activities in the data set 
extracteddata$Activity <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LYING")[extracteddata$Activity]
str(extracteddata$Activity)

#Step 4. Appropriately labels the dataset with descriptive variable names
names(extracteddata) <- gsub("^t", "Time", names(extracteddata))
names(extracteddata) <- gsub("^f", "Frequency", names(extracteddata))
names(extracteddata) <- gsub("Acc", "Accelerometer", names(extracteddata))
names(extracteddata) <- gsub("Gyro", "Gyroscope", names(extracteddata))
names(extracteddata) <- gsub("Mag", "Magnitude", names(extracteddata))
names(extracteddata) <- gsub("BodyBody", "Body", names(extracteddata))
str(extractedata) #To check data appearance

#Step 5. From the dataset in step 4, creates a second, independent tidy data set with the average of each variable activity and each subject 
library(dplyr)
Subject <- as.factor("Subject")
Activity <- as.factor("Activity")
tidydata <- extracteddata %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))
write.table(tidydata, file = "tidydata.txt", row.name = FALSE)
print(write.table)

