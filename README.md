Project Overview
-------------------
Company: AsiaAnalytics (formerly SPSS China)

Client: Oriental Cable TV Network Co., Ltd.

## Content

1. Project Overview

    -Content
  
    -Bakcground
  
    -Goals
  
    -Project Privacy
  
2. Project Technical Plan
    -Business Understanding
  
    -Data Understanding
  
    -Data Preprocessing
  
    -Building Models
  
    -Model Evaluation
  
    -Taking Actions
  

## Background

Since the establishment of the data warehouse platform and data analysis application system in 2007, Oriental Cable TV Network Co., Ltd. has formed a comprehensive supply and demand system for marketing data and statistical analysis reports, and explored statistical models such as churn warning, database marketing, and customer views, and became a great power in company operation. With the rapid development of the company's business, the original resources can not meet the needs of comprehensive and detailed marketing activities. Various marketing business activities are carried out sporadically, the procedures are complicated, and it is inconvenient for managers to follow. The workload of the user screening process is large. There are human errors. There are no key lines in sales links, there is no overall management, or a unified assessment system in place. There is a urgent need for a platform that can accommodate, assist, and display all aspects of marketing activities.


## Goals

The core objective of the marketing application system project is to integrate the existing system construction results with machine learning technology. Specifically, we aim to integrate the customer view, product recommendation, and churn prediction into the system, establish a complete customer characteristic market, form a complete and comprehensive system for tracking marketing activities, and statistical analysis. The system should enable the standardized and systematic marketing activities of the public value-added services.

The specific business goals include:

(1) Optimize the integration and reconstruction of machine learning models (including customer views, product recommendations, churn prediction, etc.), emphasize the concept of "precision marketing," and achieve targeted marketing:

* Build a customer characteristic market, portray of customer characteristics in depth, achieve market management and maintenance automatically, minimize manual intervention;

* Make customer view model better identify the customer base, understand the customer's contribution level, grasp the customer's life cycle, explore their key features and preferences, and explore the relationship between customers, so that it is easier to focus on loyal customers and high Value customers, and allocate marketing resources more effectively;

* Make the churn prediction model find the key factors affecting customers' churn to recover as many high-quality customers as possible. The purposes of churn retention are, on the one hand, to maintain customers who are about to churn; on the other hand, to recover users who have churned;

* Make the product recommendation model identify potential customer needs, provide customers with precise product or service combinations, increase their own operating income, reduce market costs, and maximize profits;

* The model construction needs to be scalable for the introduction of user behavior data in the future.

(2) Construct marketing system platform, realize controllability and integrity of active marketing process, and optimize tracking statistics for marketing activities:

* Build a marketing management platform with functions such as report display, activity progress tracking, system monitoring and maintenance;

* Implement the full process of closed-loop management and control of marketing activities from initiation to completion, and build a secure channel for user data delivery, feedback, and query;

* The platform construction must be expandable, and the entrance of user behavior data should be reserved.


## Project Privacy

* Important: For business privacy issues, I cannot disclose the raw data, the data preprocessing code, as well as some of the modeling code.


Project Technical Plan
--------------------

## Business Understanding

With the rapid development of the company's business and the accumulation of large amounts of data, the original resources of Oriental Cable TV Network Co., Ltd. are gradually unable to adapt to the needs of comprehensive and detailed marketing activities. As a result, the marketing process has become cluttered, channel management has been scattered, and there is a lack of system support. The procedures are so complex that it is difficult to manage tracking or carry out follow-up analysis.

In summary, the core issues faced by this project lie in two aspects. First, the process is not concise enough so that a single business need cannot be responded quickly; Second, the system is not integrated so that many analysis were scattered, there is even duplicate work from time to time. Both of these factors lead to the inability of the backstage to support marketing effectively and efficiently.

Based on the above conditions, the current demand of Oriental Cable TV Network Co., Ltd. is to establish a complete and comprehensive system for assisting, tracking marketing activities, and statistical analysis. Although it is described as an auxiliary system, but in terms of current requirements, the positioning of the project system is actually different from the general IT functional system, and it is more inclined to be the engine. It is not simply a supporting system, but more. It need to be the driving power and is not to passively complete functional point one by one. Instead, it need to actively establish a system to effectively use the data, to explore the content, and effectively apply to marketing support.


## Data Understanding

The Customer Feature Bazaar is a comprehensive in-depth portrait of the customers. It aims to fully characterize customers from all core dimensions to accurately pinpoint customer preferences and efficiently evaluate customer value. Its quality will not only affect the results of BI display, but also determine the accuracy of our perception of customers. At the same time, it will also affect the construction of machine models and the application of business activities, and determine the effectiveness of the company's consequent marketing activities.

The Customer Feature Bazaar is constructed from the company's data warehouse. It is comprised of three levels:
First-Level Feature Labels, Second-Level Feature Labels, and Third-Level Feature Labels.

(1) Demographic Features

    1.Personal Natural Features:
    
        Age, Sex, Constellation, Nationality, etc.
        
    2. Social Features:
    
        Place of Household Registration, Stable Renter? Education, Occupation, Marital Status, etc.
        
    3. Personality Features:
    
        Type of Personality, etc.
        
    4. Family Features:
    
        Family Structure, Have kids? Gender of Kids, Age Group of Kids, Live with Parents? etc.
        
    5. Community Features:
    
        Range of House Price in the Community, Year of House Estate, etc.
        
    6. Area Features:
    
        Downtown? Area, etc.
        
(2) Economic Features

    1. Purchasing Power Features:
    
        Have House? Have Car? Salary Level, etc.
        
    2. Consuming Willingness Features:
    
        Average of Monthly Total Bills, Average of Monthly Base Bills, Average of Monthly Value-added Bills, etc.
        
    3. Sensitiveness Features:
    
        Proportion of Monthly Base Bills, Change in Proportion of Monthly Base Bills, Arrears? etc.
        
    4. Sensitivity to Promotion Features:
    
        Ratio of Response to Promotion, Ratio of Response to Highly Effective Promotion, etc.
        
(3) Service Status Features:

    1. Customer Rank Labels:
    
        Customer Rank, Customer Type, etc.
        
    2. Service Content Features:
    
        Service Content, HDTV? Type of Payment, etc.
        
    3. Customer Life Cycle Features:
    
        Duration, Change in Contract, Expiration of Contract, etc.
        
    4. Complaint Features:
    
        Number of Complaints in 3 months, Change in Number of Complaints, Time Since Last Complaint, etc.
        
    5. Customer Satisfiction Features:
    
        Product Satisfiction, Service Satisfiction, etc.
        
(4) Preference Features:

    1. Product Viscosity Features:
    
        History of Ending Contract? etc.
        
    2. Product Preference Features:
    
        Number of Current Ordered Products, Speed of Broadband, etc.
        
    3. Cable TV Viscosity Features:
    
        Number of Month Using Cable TV, Monthly Number of Usage, Monthly Number of Playback, etc.
        
    4. Cable TV Content Preference Features:
    
        ...
        
    5. Cable TV Time Preference Features:
    
        ...
        
    6. Channel Preference Features:
    
        Ratio of Successful Promotions via Channel 1, etc.
        
    7. Time Preference Features:
    
        Ratio of Successful Promotions in Timeslot 1, etc.
        
    ...

The Customer Feature Bazaar would be used for feature selection and the source where new features are derived.


## Data Preprocessing

The major workload in data preprocessing lies in:

    (1) Merge data from different sources

    (2) Uniform data format

    (3) Dealing with categorical data (e.g. One-hot Encoding)
    
    (4) Dealing with threshold
    
    (5) Dealing with incorrect data entries
    
    (6) Dealing with missing values
    
    (7) Derive new variables, etc.


## Building Models

Overview

| Model Type | Model | Objective |
|------------|-------|-----------|
| Customer View | Baisc Clustering | Classify customers into multiple representative subdivisions based on customer attribute characteristics and behavior patterns, and refine typical characteristics. |
| Customer View | Customer Value Evaluation | Assess customer’s current level of contribution and predict customer’s potential future value. | 
| Customer View | Customer Stickiness Evaluation | Assess customer's viscous level for each product based on customer's business conditions and behavior patterns. |
| Product Recommendation | Customer Product Preference | Based on customer business conditions and behavior patterns, identify customer product/business preferences and potential consumer demand. |
| Product Recommendation | Customer Content Preference | Explore customer preferences in content based on customer business conditions and behavior patterns. |
| Product Recommendation | Customer Channel Preference | Based on customer behavior patterns and feedback, explore customer preferences in contact channels and contact time. |
| Product Recommendation | Product Relevance Recommendation | Based on sales, look for product/business sales relationships and make recommendations. | 
| Churn Prediction and Recover | Churn Warning | Summarize the characteristics of churned customers and accurately locating customers in high risk of churning. |
| Churn Prediction and Recover | Churn Maintain and Recover | Based on customer characteristics, reasons for churning, and customer value, give targeted strategies. |

(1) Customer View

1. Baisc Clustering

The clustering model algorithms used in the Basic Clustering Model mainly involve TWO-STEP clustering and K-MEANS clustering. The TWO-STEP algorithm is often used to try to find a reasonable number of intrinsic subgroups before the number of refined customer groups has been determined. Then, using the estimated number of subgroups as parameters, K-MEANS is used to train clustering groups. Its output is compared with the results of TWO-STEP clustering. At the same time, during the clustering model training process, the basic clustering model involves the data of all aspects of the customers, the original input variables are quite large, which is not conducive to the training of the model. It is often necessary to manually filter, combine, and adjust input variables to maximize modeling performance.

2. Customer Value Evaluation

The algorithms commonly used in predictive models are mainly time series models and general linear models. The algorithms need to be optimized based on the specific data and model effects. Especially in the time series model, different algorithms differ greatly. The structural adjustment of the model also needs to consider a variety of form combinations.

(2) Product Recommendation

1. Customer Product Preference

The product preference model algorithms is mainly divided into two categories. The standard practice uses an association algorithm model in machine learning, such as APRIORI or CARMA. Look for frequent sets in the flow record data prepared previously, and calculate the support and confidence levels of each frequent set accordingly. Finally, according to a preset threshold, the qualified frequent set is selected as an implicit rule. Another model algorithm uses the constructed relational matrix to use SVD matrix degradation or corresponding analysis algorithms to calculate the relationships between rows and columns and the coefficient weights of the linear transformations on each row and column. Using the conversion matrix caculated, you can obtain the conversion relationship between the original user attributes to the core attributes, and the conversion relationship between the original product attributes to the core product attributes. Through these conversion relationships, a new layer of associated attributes (possibly price/performance, service volume, etc.) can be calculated in an abstract manner. The relationship between the customer attributes and the product service attributes can be calculated through the correlation attributes.

2. Product Relevance Recommendation

The product association model mainly uses two core algorithms. The first is the association algorithm that is also used in the user preference model, namely the APRIORI and CARMA algorithms. It can be used to find that the same user has used two or more services in the subscription history. If the same ordering combination is found on enough customers, it can be seen as finding an association rule. Another algorithm is the SEQUENCE algorithm. Its calculation principle is very similar to the correlation algorithm, but the difference is that the sequence algorithm considers the order of the orders, for example, that B products are ordered after A productsis is different from that A products are ordered after B products will be Treat as different rules. So it is more demanding and more precise than the association rules.

(3) Churn Prediction and Recover

1. Churn Warning

After the sample data is prepared, it is necessary to properly divide the training set and the test set. The training set is used to train the model parameters, while the independent test set is used to test whether the trained model can correctly predict new samples. When training the Churn Warning Model, the decision tree algorithms and the logistic regression algorithms are usually prioritized. The principles of these two types of algorithms are relatively intuitive, and it is easier to find the implicit correlation between the churn probability and the variables.

2. Churn Maintain and Recover

The clustering model algorithms used by the silent maintenance model does not need to perform random segmentation on the sample data set. The entire amount of samples will be used for clustering model training. The main algorithms involved in training are TWO-STEP and K-MEANS. The TWO-STEP algorithm is often used to find a reasonable number of intrinsic subgroups before the number of refined customer groups can be determined. Then, using the estimated number of subgroups as parameters, the K-MEANS algorithm is used to train clustering groups to compare the output of the two clustering algorithms. It is often necessary to manually filter, combine, and adjust input variables to maximize modeling performance.


## Model Evaluation

Evaluation Used

1. Accuracy = # of samples that really churned among those predicted as churn/# of samples that are predicted as churn

2. Recall = # of samples that really churned among those predicted as churn/# of samples that really churned

3. Evaluation Charts

These are predictive model application tools. Graphical representation of forecasting results include gain charts, lift charts, response charts, profit charts, and ROI charts. They are used to illustrate how to use model predictions to flexibly and effectively screen and predict customer churn for better results. A high recall reduces inefficiencies or unnecessary work.

4. Silhouette Value

The silhouette value is used to measure the clustering combination and separation, and then to statistically evaluate the clustering models. It ranges between -1 (for poorly modelled models) and 1 (for excellent models). It can be averaged at the level of the overall observation (generally Silhouette), or averaged at the level of the cluster (Cluster Silhouette). The distance can be calculated using the Euclidean distance. The default value is 0, because a value less than 0 (that is, a negative value) indicates that the average distance between the observations in the cluster they are assigned to and the point is greater than the minimum average distance of another cluster. Therefore, models with negative Silhouette values can be safely discarded.


(1) Customer View

1. Baisc Clustering

Since there are no hard model evaluation metrics for the clustering model, although silhouette value and other indicators are used to evaluate the approximate performance of clustering model, the actual judgement of whether the model is good or not depends on the distribution of the final customer subgroups. The differences of indicators (ie, customer characteristics) among various subgroups, etc., are considered to comprehensively assess the usefulness of the model. In addition, it is also necessary to combine actual business conditions, such as the basic subgroups found, whether the customer portraits is convenient for business colleagues to come up with marketing strategies, or to develop new service products.

2. Customer Value Evaluation

The strengths and weaknesses of the prediction model are usually judged based on the error between the fitted value and the actual value. Specifically, the judged indicators usually include adjusted R-squares — how much of the variance in historical data has the evaluation model explained; the mean and maximum of the residuals, etc. — estimate the possible errors of the future forecasts; whether the residuals are white noise or not. Judge whether the model correctly disassembles the internal link of the data. There are also some more subjective forms of judgment such as the goodness of the fit values, etc.

(2) Product Recommendation

1. Customer Product Preference

The product recommendation model can usually only use the recommendation accuracy rate as an indicator. For historical data verification, the top-ranking customer-preferred product or service recommended by the model is usually compared with the customer's actual choice of products and services. If the customer actually selects the item within the forecast recommendation range, the forecast can be considered as accurate. If none of the first few prediction items (usually 2 or 3) contain actual user options, the model prediction can be considered to have failed. This model can also be used for model validation of actual measured data.

2. Product Relevance Recommendation

The evaluation of the product association model is also based on the accuracy of the model recommendation, that is, in the limited model recommended items, whether the customer actually chooses one of them as a service ordered later. The pros and cons of the model depend on the number of its recommendations that can achieve this standard. In actual use, it is also necessary to continuously verify the validity of the model through new data.

(3) Churn Prediction and Recover

1. Churn Warning

Whether the model obtained by the training is good or bad is usually measured by multiple indicators. The main indicator is the overall accuracy of the model on the test set. This indicator means that when the model predicts a group of new customers, it can make accurate predictions about whether these customers are silent in the later period. The higher the overall accuracy, the better the model can correctly predict the silence of a customer. However, in addition to the overall accuracy, it is also necessary to consider the recall and hit rate of the model. The so-called recall rate is the proportion of all future silent customers whose success is recognized by the model at the moment, which determines the marketing activities. Will you miss too many potential customers. The hit rate indicates that among the potential silent customers selected by the model, it will actually become silent after the observation period. This indicator will influence whether the marketing activities will generate excessive unnecessary input. In the actual modeling process, various indicators need to be considered in various aspects to select the final model.

2. Churn Maintain and Recover

Since there are no hard model evaluation indicators for the clustering model, although the silhouette value and other indicators are used to evaluate the approximate performance of the clustering models, the actual judgement of whether the model is good or not depends on the distribution of the final customer subgroups. The difference in indicators among subgroups, etc., is used to comprehensively assess the availability of the model. In addition, it is also necessary to combine actual business conditions, such as subgroups of features, whether the features are suitable for cutting into specific marketing activities, or customer cultivability, etc. to decide whether to retain the results of the cluster model for maintaining the strategy.


## Taking Actions

(1) Customer View

1. Baisc Clustering

The Baisc Clustering Model will output the customer group labels corresponding to each customer and the degree to which the customer is featured in the group. In addition, as a training result of the clustering model, the distribution differences of clustering key variables in their respective clusters are also given. Model interpretation can translate these data differences into business feature descriptions.

2. Customer Value Evaluation

The cash flow forecast given by the machine learning model is mainly for individuals. For the remaining years in the future, the forecasted consumption amount is given in each year. If the user is considered to churn after a specific year, after the corresponding year Cash flow is recorded as zero. The longest duration of life cycle is determined after a comprehensive balance of data and business requirements.

(2) Product Recommendation

1. Customer Product Preference

The result of the product preference model output is both the mapping of customer attributes to product attributes and a set of complete rules. For each customer, according to the customer feature variables dismantled in their customer data, they can map to the corresponding product features. According to these product features, from the existing service list, they can find the most suitable recommendation for the customer.

2. Product Relevance Recommendation

The output of the product association model is consistent with the customer preference model and is a complete set of rules. For each customer, according to their historical ordering records, the service products recommended for that customer are matched.

(3) Churn Prediction and Recover

The output of the Churn Warning model is the churn probability calculated for each customer based on the current data and the label that is churn or not according to the predetermined threshold. After marking the time stamp, the corresponding data can be pushed back to the data warehouse directly. The data can be used by the displaying system or other related systems. When the subsequent churn maintaining business strategy is made, the calculation result can also be easily invoked for the post-calculation.

2. Churn Maintain and Recover

The output of the Churn Maintain and Recover Model is mainly the labels of the churn group of the target customers and the significance of the characteristics of each customer in the corresponding subgroup. However, the more important result is the relevant description of each subgroup. Business colleagues can use these model results to design maintenance plans and estimate activity costs, and ultimately make final business decisions based on the outcomes of the Churn Warning Model and Customer Value.

