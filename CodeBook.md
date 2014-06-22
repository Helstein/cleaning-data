Code Book for the tidy dataset
=============
## Observations and Variables
The script produces a file "tidy.csv" that represents dataset with four columns, where each row represents mean of all the values in the original dataset for a combination of subject, activity and variable. This is a tall and skinny dataset with 11880 rows ('number of subjects' x 'number of activities' x 'number of std or mean features' = 30x6x66 = 11880) and four columns:
* subject - An identifier of the subject who carried out the experiment. Type: factor ("1", "2", ..., "30")
* activity - Activity label. Type: factor ("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")
* variable - Name of the summarized variable. Represents one of the standard deviation or mean features within the original dataset (ones that contain "-std()" or "-mean()" in their names). The name from the original dataset is transformed as described in section "Steps Performed by the Script". Type: factor (one of the transformed 66 names of std or mean features within the original dataset)
* mean - Mean of all the values for given subject, activity and variable in the original dataset. Type: numeric


## Steps Performed by the Script
1. Features file ("features.txt") is parsed into a table with two columns: integer index of the feature and transformed name of the feature. Only the features that represent std or mean measures are included (ones that contain "-std()" or "-mean()" in their names). The name is transformed such that they contain the following parts, in order:
	* "mean" or "std" depending on the original value name
	* name of the variable without the "t" or "f" prefix (e.g. "tBodyAcc-std()-Z" -> "BodyAcc")
	* one of "X", "Y" or "Z" if the original name had such suffix
	* if the original name had "f" prefix, the resulting name has "Frequency" suffix
2. Test and train observations from "train/X_train.txt", "test/X_test.txt" are merged vertically (train data then test data) and all the columns that are not identified by the feature table created previously are dropped
3.  Activity indexes are combined vertically ("train/y_train.txt" then "test/y_test.txt") and merged with the dataset horizontally (activity column then the remaining dataset). The activities are converted to factor, where the levels of the factor are set to strings in file "activity_labels.txt".
4. Subject files are combined vertically ("train/subject_train.txt" then "test/subject_test.txt"), converted to factor and combined with the rest of the dataset vertically (subject column then the rest of the dataset)
5. The dataset is melted using subject and activity columns as keys
6. The dataset is aggregated using subject, activity and variable columns as grouping key and value as aggregated using mean function
7. Resulting dataset is written to "tidy.csv"
