library(plyr)

#download and unzip the UCI Human Activity Recognition Data
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("Getting and Cleaning Data")){
        dir.create("Getting and Cleaning Data")
}
download.file(url,destfile="./Getting and Cleaning Data/UCI Har.zip")
unzip("./Getting and Cleaning Data/UCI Har.zip",exdir="./Getting and Cleaning Data")

#read in all the relevant files
Xtrain<-read.table("./Getting and Cleaning Data/UCI HAR Dataset/train/X_train.txt")
ytrain<-read.table("./Getting and Cleaning Data/UCI HAR Dataset/train/y_train.txt")
Xtest<-read.table("./Getting and Cleaning Data/UCI HAR Dataset/test/X_test.txt")
ytest<-read.table("./Getting and Cleaning Data/UCI HAR Dataset/test/y_test.txt")
features<-read.table("./Getting and Cleaning Data/UCI HAR Dataset/features.txt")
activity<-read.table("./Getting and Cleaning Data//UCI HAR Dataset/activity_labels.txt")
subjecttrain<-read.table("./Getting and Cleaning Data/UCI HAR Dataset/train/subject_train.txt")
subjecttest<-read.table("./Getting and Cleaning Data/UCI HAR Dataset/test/subject_test.txt")

#rename the variables
colnames(subjecttrain)=c("subjectID")
colnames(activity)=c("activityID","activityType")
colnames(ytrain)=c("activityID")
colnames(Xtrain) = features[,2]
colnames(Xtest)=features[,2]
colnames(ytest)=c("activityID")
colnames(subjecttest)=c("subjectID")

#merge train and test sets together
train<-cbind(subjecttrain,ytrain,Xtrain)
test<-cbind(subjecttest,ytest,Xtest)
Data<-rbind(train,test)

#extract only those measurements on the mean and the standard deviation for each measurement
colnames<-colnames(Data)
DataMStd<-Data[,grep("[Mm]ean|std",colnames(Data))]
IDs<-Data[,c(1,2)]
DataF<-cbind(IDs,DataMStd)

#Clean up variables names and use more descriptive variable names
names(DataF)<-gsub("tGravity","timeGravity",names(DataF),fixed=TRUE)
names(DataF)<-gsub("fBody","frequencyBody",names(DataF),fixed=TRUE)
names(DataF)<-gsub("BodyBody","Body",names(DataF),fixed=TRUE)
names(DataF)<-gsub("tBody","timeBody",names(DataF),fixed=TRUE)
names(DataF)<-gsub("-mean()","_Mean",names(DataF),fixed=TRUE)
names(DataF)<-gsub("-std()","_StDev",names(DataF),fixed=TRUE)
names(DataF)<-gsub("-meanFreq()","_Meanfrequency",names(DataF),fixed=TRUE)
names(DataF)<-gsub("-X","_X",names(DataF),fixed=TRUE)
names(DataF)<-gsub("-Y","_Y",names(DataF),fixed=TRUE)
names(DataF)<-gsub("-Z","_Z",names(DataF),fixed=TRUE)


#take average of each variable for each subject and each activity
DataG<-aggregate(.~subjectID+activityID,DataF,mean)

#include activity types matched with activityID
DataH= merge(DataG,activity,by='activityID',all.x=TRUE)

#reorder columns so subjectID, activityID,and activityType are at beginning
DataI=DataH[,c(2,1,89,3:88)]

#reorder by subjectID and then by activityID
DataJ<-DataI[order(DataI$subjectID,DataI$activityID),]

#produce final clean data set
write.table(DataJ,file="TidyData.txt",row.name=FALSE)
