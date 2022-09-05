#!/usr/bin/env python
# coding: utf-8

# In[57]:


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
df=pd.read_csv(r'C:\Users\sharm\OneDrive\Documents\datasets\Cars_Data.csv')


# In[58]:


df.isnull().sum() #to check for null values


# In[59]:


df=df.fillna('NaN') #TO FILL null values with NaN


# In[60]:


#types of car brands
df['Make'].unique()


# In[61]:


#count of total car brands
df['Make'].nunique()


# In[62]:


#count of each type of brands
df['Make'].value_counts()


# In[63]:


#show all records where origin is asia or europe
df[df['Origin'].isin(['Europe','Asia'])]


# In[71]:


#remove all records where weight is above 4000

#changing the type to float first
df=df.astype({'Weight':float})
df.info()

df[~(df['Weight']> 4000)]


# In[76]:


#Increase all the values of 'MPG_City' column by 3

df=df.astype({'MPG_City':float})
df['MPG_City']=df['MPG_City'].apply(lambda x:x+3)
df


