
# Helper method to download package, if necessary, and load it
usePackage <- function(p) {
        if (!is.element(p, installed.packages()[,1]))
                install.packages(p, dep = TRUE)
        require(p, character.only = TRUE)
}

usePackage('stringr')
usePackage('reshape')


# Reads tables from a list of files and returns list of data frames
readTables <- function(files, ...) {
        lapply(files, function(f) { 
                read.table(file=f, header=F, ...)
        })
}

# Files to merge
datasetBase <- "UCI HAR Dataset"
observationFiles <- file.path(datasetBase, c('train/X_train.txt', 'test/X_test.txt'))
labelFiles <- file.path(datasetBase, c('train/y_train.txt', 'test/y_test.txt'))
subjectFiles <- file.path(datasetBase, c('train/subject_train.txt', 'test/subject_test.txt'))
featuresFile <- file.path(datasetBase, "features.txt")
activitiesFile <- file.path(datasetBase, "activity_labels.txt")

# Regular expresion for matching names of features to extract
featureNameRegex <- "(\\d+) ([t|f])(\\w+)-(mean|std)\\(\\)-?([XYZ]?)"

# Extract features' information (the index of the feature within the dataset and name)
lines <- readLines(featuresFile)
numFeatures <- length(lines)
features <- str_match(lines, featureNameRegex)
features <- features[!is.na(features[,1]), seq(2, 6)]
features[,2] <- sapply(features[,2], function(x) { if(x == 'f') 'Frequency' else '' })
features <- data.frame(index = as.integer(features[,1]),
                       name = paste0(features[,4], features[,3], features[,5], features[,2]))


# Merge the files containing observations, extracting only the needed columns
# and naming the columns according to features table computed previously
colCls <- rep('NULL', numFeatures)
colCls[features$index] <- "numeric"
tables <- readTables(observationFiles, colClasses=colCls)
dataset <- do.call("rbind", tables)
colnames(dataset) <- features$name

# Add activity column to the dataset
activityLabels <- strsplit(readLines(activitiesFile), " ")
activityLabels <- sapply(activityLabels, function(x) { x[[2]] })
tables <- readTables(labelFiles, colClasses='factor')
activities <- do.call("rbind", tables)
levels(activities[,1]) <- activityLabels
dataset <- cbind(activity = activities[,1], dataset)

# Add subject column to the dataset
subjects <- unlist(readTables(subjectFiles))
dataset <- cbind(subject = as.factor(subjects), dataset)

# Create a tidy data set containing averages for all variables
# grouped by activity and subject
result <- melt(dataset, id = c('subject', 'activity'))
result <- aggregate(value ~ ., result, mean)
colnames(result)[[4]] <- 'mean'
write.csv(result, 'tidy.csv', row.names=F)
