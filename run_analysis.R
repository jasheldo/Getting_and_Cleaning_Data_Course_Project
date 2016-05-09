#Getting and Cleaning Data

#course Project

#Submitted by: James Sheldon

#Date: 09/May/2016

#This file assumes the data has already been downloaded and the zip file contents extracted.
#It futher assumes the data has been extracted in the same hierarchal format as in the zip file but within the 
#directory /data in your present working directory.  If this is not the case then the script will fail.

#We will be using a few non-default packages.  Check to see whether or not they're installed.  If they're not installed,
#then we need to get them.
if (!require("data.table")) { 
    install.packages("data.table")
    }

if (!require("reshape2")) {
    install.packages("reshape2")
    }

#Attach data.table and reshape2
library(data.table)
library(reshape2)

#store the activity labels to an R object.  The actual labels are in the second column.  We don't
#need to keep the first column.
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]

#Similarly, store the features table to an R object.  Again, we only need the second column.
features <- read.table("./data/UCI HAR Dataset/features.txt")[,2]

#Store the X_test, y_test and subject_test files each to an R object
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#Store the training data to R objects
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#Assign meaningful variable names to the columns of X_test and X_train [length(X_test) = length(features) = 561]
names(X_test) <- features
names(X_train) <- features

#Create a logical vector with only the mean or standard deviation variables ID'ed as TRUE.
features_logical <- grepl("mean|std", features)

#Now that we have the meaningful measures we wish to pull we can extract them from the test and training datasets.
#This reduces X_test and X_train to 79 variables.
X_test <- X_test[,features_logical]
X_train <- X_train[,features_logical]

#Append the activity labels onto the y_test and y_train datasets
y_test[,2] <- activity_labels[y_test[,1]]
y_train[,2] <- activity_labels[y_train[,1]]

#Assign meaninigful names to the activities in the datasets
names(y_test) <- c("ActivityID", "Activity")
names(y_train) <- c("ActivityID", "Activity")

#While we're at it, give a meanininful name to the subject_test data as well.
names(subject_test) <- "Subject"
names(subject_train) <- "Subject"

#With the separate elements cleaned and labeled, it's time to put the pieces together.
merged_test_data <- cbind(as.data.table(subject_test),y_test,X_test)
merged_training_data <- cbind(as.data.table(subject_train),y_train,X_train)

#Finally, merge the training and testing datasets
merged_data <- rbind(merged_test_data,merged_training_data)

#Perform our analytics

labels <- c("Subject", "ActivityID", "Activity") 
merged_data_labels <- setdiff(colnames(merged_data), labels)
merged_melt_data <- melt(merged_data, id = labels, measure.vars = merged_data_labels) 

#Apply the mean and output the tidy data file.
tidy_data <- dcast(merged_melt_data, Subject + Activity ~ variable, mean)
write.table(tidy_data, file = "./data/tidy_data.txt")