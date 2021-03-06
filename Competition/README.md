## Competition rules
### Teams
Teams should consist of 1-3 members. Please name the team - name will appear in the results table.

### Dataset and competition's goal
Goal of the competition is to achieve highest **accuracy** (percent of correctly classified observations [TP+TN/(TP+TN+FP+FN)]) in prediction of target variable **is_canceled**. To create a model please use **hotels_train.csv** and predict labels for **hotels_test.csv** data. Description of dataset features can be found in **hotels_description.txt**.

### Results
Please send the results to _lukasz.krainski123@gmail.com_ or _lkrain@sgh.waw.pl_. 

Deadlines: 
* Group 1 - 21:10 25.05.2021
* Group 2 - 23:00 25.05.2021

In the e-mail please specify name of the group and members. Required attachments are:
1. R/Python/Julia script or notebook with used code
2. CSV file named **[group_name]_Hotels_prediction.csv** with one column named **Prediction** containing 5000 predictions with values 1/0 or TRUE/FALSE for dataset **hotels_test.csv**. Please make sure predictions order is the same as rows in test data.  

Best team in each group will receive 5 points, next 4 points, etc.

### Ranking

**Groups taking part in first laboratory**

|Team             |Accuracy|Points|Model              |Language|
|-----------------|--------|------|-------------------|--------|
|BetterLateThanNever |98.70   |5|CatBoost      |Python       |
|Młode Wilki          |75.86    |4|Random Forest              |Python  |
|Czarodziejskie Cyferki           |59.52  |3|CART      |Python      |


**Groups taking part in second laboratory**

|Team             |Accuracy|Points|Model              |Language|
|-----------------|--------|------|-------------------|--------|
|lobo               |99.74   |5|Logistic Regression|Python  |
|TRY        |80.08   |4|CatBoost      |Python  |
|LiuKimCa|62.56   |3|Custom Random Forest     |Python  |
|NoTeamNameGiven  |45.02   |2|Logistic Regression      |R       |

All observations in test set are cancelled bookings, so you can easily check your score :). For `NoTeamNameGiven` only 5000 first observations from predictions were used in assessment. Congratulations for all teams!
