library(dplyr)

## check presence of the file, download and unzip the file

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- 'HARUS.zip'
if(!file.exists(fileName)) {download.file(fileUrl, destfile = "C:\\Users\\Qingliang\\Desktop\\course 3-Data cleaning\\data\\HARUS.zip", method = "curl")}
unzip(fileName)

## read each file, name each col

feat <- read.table("UCI HAR Dataset/features.txt", col.names = c("num","estimated"))
acti <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subje_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
test_x <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = feat$estimated)
test_y <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subje_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
train_x <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = feat$estimated)
train_y <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

## combine test and train

x <- rbind(test_x, train_x)
y <- rbind(test_y, train_y)
subject <- rbind(subje_test, subje_train)
data <- cbind(subject, x, y)
data <- as_tibble(data)

# extracts the colname containing "mean" and "std"

extr_data <- select(data, subject, code, contains("mean"), contains("std"))

# link the "code" in extr_date to "activities" in acti

extr_data$code <- acti[extr_data$code, 2]

# rename the col names in extr_data

names(extr_data)[2] <- "activity"
names(extr_data) <- gsub("^t", "Time", names(extr_data))
names(extr_data) <- gsub("^f", "Frenquency", names(extr_data))
names(extr_data) <- gsub("Acc", "Accelerometer", names(extr_data))
names(extr_data) <- gsub("Gyro", "Gyroscope", names(extr_data))
names(extr_data) <- gsub("Mag", "Magnitude", names(extr_data))
names(extr_data) <- gsub("Freq", "Frequency", names(extr_data))
names(extr_data) <- gsub("tBody", "TimeBody", names(extr_data))

# tidy data with the average of each variable for each activity and each subject

group_data <- group_by(extr_data, subject, activity)
tidy_data <- summarize_all(group_data, funs(mean))
write.table(tidy_data, "TidyData.txt", row.name=FALSE)
