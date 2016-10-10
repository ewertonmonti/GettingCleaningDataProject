## 1. Merges the training and the test sets to create one data set.

# Download and unzip data
if (!file.exists("data")){dir.create("data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./data/UCI HAR Dataset.zip")
dateDownloaded <- date()
unzip("./data/UCI HAR Dataset.zip", exdir = "./data")

# Read files
trainingSet <- read.table("./data/UCI HAR Dataset/train/X_train.txt", sep = "")
testSet <- read.table("./data/UCI HAR Dataset/test/X_test.txt", sep = "")
trainingLabels <- read.table("./data/UCI HAR Dataset/train/y_train.txt", sep = "")
testLabels <- read.table("./data/UCI HAR Dataset/test/y_test.txt", sep = "")
trainingSubjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", sep = "")
testSubjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", sep = "")
columnsNames <- read.table("./data/UCI HAR Dataset/features.txt", sep = "")
activitiesList <- read.table("./data/UCI HAR Dataset/activity_labels.txt", sep = "")
colnames(activitiesList) <- c("activityCode", "activityName")

# Merge sets with activities and subjects
trainingSetActivitiesSubjects <- cbind(trainingSet, trainingLabels, trainingSubjects)
testSetActivitiesSubjects <- cbind(testSet, testLabels, testSubjects)

# Merge training and test sets
sets <- rbind(trainingSetActivitiesSubjects, testSetActivitiesSubjects)

# Add names to columns
colnames(sets) <- columnsNames[,2]
colnames(sets)[562] <- "activityCode"
colnames(sets)[563] <- "subject"



## 2. Extracts only the measurements on the mean and standard deviation for each measurement.

# Identify columns with mean or std
meanStdColumns <- grep("[Mm]ean|std", names(sets))

# Creates a dataset with the desired columns, including subjects and activities
setsMeanStd <- sets[,c(meanStdColumns, 562, 563)]



## 3. Uses descriptive activity names to name the activities in the data set

# Merge the previous data set with the list of activities
setsMeanStdActivities <- merge(setsMeanStd, activitiesList, by = "activityCode")


## 4. Appropriately labels the data set with descriptive variable names.

# IMPORTANT: It was done in step 1, in order to optimize steps 2 and 3 (see "Add names to columns")


## 5. From the data set in step 4, creates a second, independent tidy data set with the 
#    average of each variable for each activity and each subject.

# Call library used to reshape data
library(reshape2)

# Melt the data by subject and activity
meltData <- melt(setsMeanStdActivities,id=c("subject","activityName"))

# Cast the melted data, while calculating the average for each variable 
# for each activity and each subject
castData <- dcast(meltData, activityName + subject ~ variable, fun.aggregate = mean, na.rm = TRUE)

# Change the order of the columns "activityCode" and "subject", in order to place 
# "activityCode" next to "activityName".
castData <- castData[,c(1,3,2,4:89)]

# Write the txt file with the final tidy data set
write.table(castData, file = "./data/UCI HAR Dataset/final_data_set.txt", row.name=FALSE)

