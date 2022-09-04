#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# In[4]:


df=pd.read_csv(r'C:\Users\sharm\OneDrive\Documents\datasets\Weather_Data.csv')


# In[5]:


df


# In[7]:


df.shape


# In[8]:


df.nunique() #to find total number of unique values


# In[10]:


df.isnull().sum() #to check if we have null values


# In[12]:


#find unique 'Wind Speed' values in the data
df['Wind Speed_km/h'].unique()


# In[17]:


#number of times when "Weather is exactly clear"
df[df['Weather']=='Clear'].count()
#another method
df.groupby('Weather').get_group('Clear').count()


# In[26]:


#number of times windspeed was exactly 4km/h
df[df['Wind Speed_km/h']==4].count()


# In[35]:


#rename column 'Weather' as 'Weather_Conditions'
df.rename(columns={'Weather':'Weather_Conditions'},inplace=True)


# In[36]:


#what is mean visibility
df['Visibility_km'].mean()


# In[37]:


#standard deviation of Pressure 
df['Press_kPa'].std()


# In[38]:


#variance of Relative Humidity
df['Rel Hum_%'].var()


# In[41]:


#all instances when 'Snow' was recorded
df[df['Weather_Conditions']=='Snow']


# In[49]:


#all instances when 'Wind speed is above 24' and 'Visibility is 25'
df[(df['Visibility_km']==25.0) & (df['Wind Speed_km/h'] >24)]


# In[50]:


#mean value of each column against each 'Weather Conditions'
df.groupby('Weather_Conditions').mean()


# In[51]:


#min and max value of each column against each 'Weather Condition'
df.groupby('Weather_Conditions').min()


# In[52]:


df.groupby('Weather_Conditions').max()


# In[55]:


#find all instances when:
#A weather is Clear and Relative Humidity is greater than 50
#or
#B visibility is above 40
df[(df['Weather_Conditions']=='Clear')&(df['Rel Hum_%']>50)|(df['Visibility_km']>40)]


# In[ ]:




