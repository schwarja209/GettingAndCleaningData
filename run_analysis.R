library(dplyr) #initiate dplyr package

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","HARData.zip")
unzip("HARData.zip") #download and unzip data

xTest <- read.table("UCI HAR Dataset/test/X_test.txt") #extract primary data sets (as identified by README.txt)
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt")

subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt") #extract data on subject and activity labels
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt") #(as identified by README.txt)
yTest <- read.table("UCI HAR Dataset/test/y_test.txt")
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt")

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt") #extract activity and feature names
features <- read.table("UCI HAR Dataset/features.txt") #(as identified by README.txt)

names(subjectTest)<-"Subject.ID" #set names for subject and activity label data sets
names(subjectTrain)<-"Subject.ID"
names(yTest)<-"Activity.ID"
names(yTrain)<-"Activity.ID"

# Task #4: Column Labels
features$V2<-gsub("\\()","",features$V2) #normalize feature labels
features$V2<-gsub("-",".",features$V2)
names(xTest)<-features$V2 #set variable names for primary data (as identified by README.txt)
names(xTrain)<-features$V2

# Task #3: Activity Labels
activityLabels$V2<-as.factor(tolower(gsub("_",".",activityLabels$V2))) #normalize activity names
yTest<-mutate(yTest,Activity.ID=activityLabels[yTest$Activity.ID,2]) #set activity names based on IDs
yTrain<-mutate(yTrain,Activity.ID=activityLabels[yTrain$Activity.ID,2])

# Task #1: Merge Datasets 
test1 <- cbind(subjectTest, yTest, xTest) #combine primary data with Subject and Activity IDs
train1 <- cbind(subjectTrain, yTrain, xTrain)
complete1 <- rbind(train1, test1) #compile training and testing data sets into one table

# Task #2: Extract means and stds
meanStdCols <- grepl("(mean)|(std)|(\\.ID)", names(complete1)) #find all columns with mean/std/.ID in the name
completeMeanStds1<-complete1[,meanStdCols] #select only mean/std/ID columns

# Task #5: Tidy Data Set
meansTidy<-group_by(completeMeanStds1,Subject.ID,Activity.ID)%>% #group by the subject and activity factors
    summarise_each(funs(mean)) #summarize all numeric data into means by grouping
meansTidy1<-data.frame(meansTidy) #structure as data frame

write.table(meansTidy1, file="meansTidy.txt", row.name=FALSE)
