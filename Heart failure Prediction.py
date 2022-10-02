#!/usr/bin/env python
# coding: utf-8

# In[22]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split

from sklearn.metrics import accuracy_score,classification_report,plot_confusion_matrix
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import StandardScaler


from sklearn.linear_model import LogisticRegression
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree  import DecisionTreeClassifier

import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots


# In[23]:


#loading dataset
data=pd.read_csv(r'C:\Users\sharm\OneDrive\Documents\datasets\heart_failure_clinical_records_dataset.csv')


# In[24]:


data.head()


# In[25]:


data.describe().T


# In[26]:


data.describe().T.sort_values(ascending=0,by="mean")


# In[27]:


data.shape


# In[28]:


data.columns


# In[29]:


#ANALYSING DATA
#finding number of unique values in each column and the count of each value present in each column
column=['age', 'anaemia', 'creatinine_phosphokinase', 'diabetes',
       'ejection_fraction', 'high_blood_pressure', 'platelets',
       'serum_creatinine', 'serum_sodium', 'sex', 'smoking', 'time',
       'DEATH_EVENT']
for i in column:
    print(i.capitalize()) #to capitalize each column name and print it
    print("Number of unique values = ",data[i].nunique())
    print("Value Count")
    print(data[i].value_counts())
    print(" ")
    print("-------------------------------------------")
    print("")


# In[30]:


#Finding correlation between columns
co=data.corr()
co


# In[31]:


# plotting heatmap for correlation
plt.figure(figsize=(10,10))
sns.heatmap(co,annot=True,annot_kws={'size':5},square=True,cmap='Oranges')


# In[32]:


co['DEATH_EVENT'].sort_values()


# In[33]:


#DATA VISUALIZATION

#Preparing subplot area with 5 rows and 3 columns
fig=make_subplots(
rows=5, cols=3,
    column_widths=[1,1,1],
    row_heights=[6,5,5,8,4],
    specs=[
        [{'type':'histogram'},{'type':'bar'},{'type':'histogram'}],
         [{'type':'pie'},{'type':'histogram'},{'type':'histogram'}],
         [{'type':'bar'},None,{'type':'pie'}],
        [{'type':'histogram'},{'type':'histogram'},{'type':'bar'}],
        [{'type':'bar'},{'type':'bar'},None]
    ]
)
fig.add_trace(go.Histogram(x=data['age'],name='Age'),row=1,col=1)

fig.add_trace(go.Bar(x=['0','1'],y=data['anaemia'].value_counts(),name='Anaemia',marker=dict(color="crimson")),row=1,col=2)

fig.add_trace(go.Histogram(x=data['ejection_fraction'],name='Ejection_fraction'),row=1,col=3)

fig.add_trace(go.Pie(
     labels=data['high_blood_pressure'].value_counts().index,values=data['high_blood_pressure'].value_counts().values,
     
     name="High_blood_pressure",hoverinfo="label+percent+name"),row=2, col=1)

fig.add_trace(go.Histogram(x=data['platelets'],name='Platelets'),row=2,col=2)


fig.add_trace(go.Histogram(x=data['serum_creatinine'],name='Serum_Creatinine'),row=2,col=3)

fig.add_trace(go.Bar(y=data['serum_sodium'].value_counts().values,x=data['serum_sodium'].value_counts().index,name="Serum_Sodium"),row=3,col=1)

fig.add_trace(go.Pie(
     labels=data['smoking'].value_counts().index,values=data['smoking'].value_counts().values,
     
     name="Smoking",hoverinfo="label+percent+name"),row=3, col=3)

fig.add_trace(go.Histogram(x=data['time'],name='Time'),row=4,col=1)

fig.add_trace(go.Histogram(x=data['creatinine_phosphokinase'],name='Creatinine_Phosphokinase'),row=4,col=2)

fig.add_trace(go.Bar(y=data['diabetes'].value_counts().values,x=['0','1'],name="Diabetes",marker=dict(color="orange")),row=4,col=3)

fig.add_trace(go.Bar(y=data['DEATH_EVENT'].value_counts().values,x=['0','1'],name="Death",marker=dict(color="brown")),row=5,col=1)

fig.add_trace(go.Bar(y=data['sex'].value_counts().values,x=['0','1'],name="Sex",marker=dict(color="pink")),row=5,col=2)

fig.update_xaxes(tickangle=45)

fig.update_layout(
    template="plotly_dark",
    margin=dict(r=50, t=30, b=50, l=50),
    
)


# In[34]:


#splitting data into training and testing
x=data.drop(['DEATH_EVENT'],axis=1)
y=data['DEATH_EVENT']
x_train,x_test,y_train,y_test=train_test_split(x,y,test_size=0.2,random_state=23)


# In[35]:


#APPLYING DIFFERENT MODELS
#LINEAR REGRESSION
ln=LinearRegression() #creating linear regressor
ln.fit(x_train,y_train)#training model 

#finding train score and test score
ln_train_score=round(ln.score(x_train,y_train),2)
ln_test_score=round(ln.score(x_test,y_test),2)

#model prediction on test data
y_pred_ln=ln.predict(x_test)

#accuracy score
y_pred_ln.flatten()
y_pred_ln = np.where(y_pred_ln > 0.5, 1, 0)
ln_acc = round(accuracy_score(y_pred_ln,y_test),2)

#to print train score, test score, accuracy score
print("LinearRegressionModel Train Score:",ln_train_score)
print("----------------------")
print("LinearRegressionModel Test Score:",ln_test_score)
print("----------------------")
print("LinearRegressionModel Accuracy Score:",ln_acc)
print("----------------------")

#getting testing accuracy,classification report s confusion matrix can't be plotted for it

ts_acc_ln = round(accuracy_score(y_test,y_pred_ln),4)
print("Testing Accuracy:",round(ts_acc_ln*100,2),"%")
print("----------------------")
print("Classification report for xtest data:-\n\n",classification_report(y_test,y_pred_ln),"\n")


# In[36]:


#LOGISTIC REGRESSION
lr=LogisticRegression(max_iter=3000) #creating logistic regressor
lr.fit(x_train,y_train)#training model 

#finding train score and test score
lr_train_score=round(lr.score(x_train,y_train),2)
lr_test_score=round(lr.score(x_test,y_test),2)

#model prediction on test data
y_pred_lr=lr.predict(x_test)

#accuracy score
lr_acc = round(accuracy_score(y_pred_lr,y_test),2)

#to print train score, test score, accuracy score
print("LogisticRegressionModel Train Score:",lr_train_score)
print("----------------------")
print("LogisticRegressionModel Test Score:",lr_test_score)
print("----------------------")
print("LogisticRegressionModel Accuracy Score:",lr_acc)
print("----------------------")

#getting testing accuracy,classification report and confusion matrix 

ts_acc_lr = round(accuracy_score(y_test,y_pred_lr),4)
print("Testing Accuracy:",round(ts_acc_lr*100,2),"%")
print("----------------------")
print("Classification report for xtest data:-\n",classification_report(y_test,y_pred_lr),"\n")
print("----------------------")
print("Cofusion matrix for xtest data:-\n\n",plot_confusion_matrix(lr,x_test,y_test))


# In[37]:


#DecisionTreeClassifier
dt= DecisionTreeClassifier(max_features=5 , max_depth=5)
dt.fit(x_train, y_train)

dt_train_score = dt.score(x_train, y_train)
dt_test_score= dt.score(x_test, y_test)

y_pred_dt = dt.predict(x_test)
dt_acc = accuracy_score(y_pred_dt,y_test)


print('DecisionTreeClassifier Train Score is : ' , dt_train_score)
print("----------------------------------------------------------------")
print('DecisionTreeClassifier Test Score is : ' , dt_test_score)
print("----------------------------------------------------------------")
print('DecisionTreeClassifier accuracy is : ', dt_acc)

ts_acc_dt = round(accuracy_score(y_test,y_pred_dt),4)
print("----------------------------------------------------------------")
print("Testing Accuracy is:-",round(ts_acc_dt*100,2),"%")
print("----------------------------------------------------------------")
print("Classification report for xtest data:-\n\n",classification_report(y_test,y_pred_dt),"\n")
print("----------------------------------------------------------------")
print("Confusin Matrix for xtest data:-\n\n",plot_confusion_matrix(dt,x_test, y_test))


# In[38]:


#RandomForestClassifier
rf= RandomForestClassifier(max_features=5 , max_depth=5)
rf.fit(x_train, y_train)

rf_train_score = rf.score(x_train, y_train)
rf_test_score= rf.score(x_test, y_test)

y_pred_rf = rf.predict(x_test)
rf_acc = accuracy_score(y_pred_rf,y_test)


print('RandomForestClassifier Train Score is : ' , rf_train_score)
print("----------------------------------------------------------------")

print('RandomForestClassifier Test Score is : ' , rf_test_score)
print("----------------------------------------------------------------")
print('RandomForestClassifier accuracy is : ', rf_acc)

ts_acc_rf = round(accuracy_score(y_test,y_pred_rf),4)
print("----------------------------------------------------------------")
print("Testing Accuracy is:-",round(ts_acc_rf*100,2),"%")
print("----------------------------------------------------------------")
print("Classification report for xtest data:-\n\n",classification_report(y_test,y_pred_rf),"\n")
print("----------------------------------------------------------------")
print("Confusin Matrix for xtest data:-\n\n",plot_confusion_matrix(rf,x_test, y_test))


# In[39]:


#Model Evaluation
models = ['LinearRegression','LogisticRegression'  , 'DecisionTree','RandomForest']
model_data = [ln_acc,lr_acc, dt_acc, rf_acc ]
cols = ["accuracy_score"]
compare=pd.DataFrame(data=model_data , index= models , columns= cols)
compare.sort_values(ascending= False , by = ['accuracy_score'])


# In[40]:


fig=px.bar(compare, x=models, y="accuracy_score")
fig.update_layout(
    template="plotly_dark")
fig


# In[ ]:





# In[ ]:




