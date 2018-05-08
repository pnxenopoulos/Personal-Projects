####################
#### Tim Boudreau
#### Machine Learning Practice
#### May 2017
####################

from __future__ import division
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from sklearn.cluster import KMeans
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import scale
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression


################
## Set up for models
################


# import data, iris

iris = datasets.load_iris()


# set colormap for comparing predicted to actual

colormap = np.array(['red', 'lime','blue'])


# break up iris into 20% test, 80% train

x_train, x_test, y_train, y_test = train_test_split(iris.data, iris.target, test_size = .2)



################
## K Means Modeling
################


# clustering algorithms don't need test and train data, so prepare data normally

x = pd.DataFrame(iris.data)
x.columns = ['Sepal_Length','Sepal_Width','Petal_Length','Petal_Width']

y = pd.DataFrame(iris.target)
y.columns = ['Targets']

names = pd.DataFrame(iris.target_names)
names.columns = ['Species']
species = list(names.Species.values)

"""
# to visually see the data. unnecessary, so commented out.

plt.figure()

plt.subplot(1,2,1)
plt.scatter(x.Sepal_Length, x.Sepal_Width, c=colormap[y.Targets], s=40)
plt.xlabel('Sepal Length (cm)')
plt.ylabel('Sepal Width (cm)')
plt.title('Sepal')

plt.subplot(1,2,2)
plt.scatter(x.Petal_Length, x.Petal_Width, c=colormap[y.Targets], s=40)
plt.xlabel('Petal Length (cm)')
plt.ylabel('Petal Width (cm)')
plt.title('Petal')

plt.tight_layout()
plt.show()


"""
# create and run the model - using three clusters because I know there are three flowers

model = KMeans(n_clusters = 3)
model = model.fit(scale(x))

# plot predicted vs actual based on Petal and Sepal information on subplots

plt.figure()

plt.subplot(2,2,1)
plt.scatter(x.Petal_Length, x.Petal_Width, c=colormap[y.Targets], s=40)
plt.xlabel('Petal Length (cm)')
plt.ylabel('Petal Width (cm)')
plt.title('Real Classification, Petals')

plt.subplot(2,2,2)
plt.scatter(x.Petal_Length, x.Petal_Width, c=colormap[model.labels_], s=40)
plt.xlabel('Petal Length (cm)')
plt.ylabel('Petal Width (cm)')
plt.title('K Means Classification, Petals')

plt.subplot(2,2,3)
plt.scatter(x.Sepal_Length, x.Sepal_Width, c=colormap[y.Targets], s=40)
plt.xlabel('Sepal Length (cm)')
plt.ylabel('Sepal Width (cm)')
plt.title('Real Classification, Sepals')

plt.subplot(2,2,4)
plt.scatter(x.Sepal_Length, x.Sepal_Width, c=colormap[model.labels_], s=40)
plt.xlabel('Sepal Length (cm)')
plt.ylabel('Sepal Width (cm)')
plt.title('K Means Classification, Sepals')

plt.suptitle('K Means Results')
plt.tight_layout()
plt.show()



################
## Naive Bayes
################


# choosing my NB classifier. Here, multinomial, because we are looking at frequency of an event
# (being a type of flower)

classifier = MultinomialNB()


# fit the model and run the model on our test data

classifier.fit(x_train, y_train)
predictions = classifier.predict(x_test)


# view our predictions vs the actual flower classes

print predictions 
print y_test


# do it again for the entire iris data set

iris_pred = classifier.predict(iris.data)


# plot the results!

plt.figure()

plt.subplot(2,2,1)
plt.scatter(iris.data[:,2], iris.data[:,3], c=colormap[iris.target], s=40)
plt.xlabel('Petal Length (cm)')
plt.ylabel('Petal Width (cm)')
plt.title('Real Classification, Petals')

plt.subplot(2,2,2)
plt.scatter(iris.data[:,2], iris.data[:,3], c=colormap[iris_pred], s=40)
plt.xlabel('Petal Length (cm)')
plt.ylabel('Petal Width (cm)')
plt.title('Naive Bayes Classification, Petals')

plt.subplot(2,2,3)
plt.scatter(iris.data[:,0], iris.data[:,1], c=colormap[iris.target], s=40)
plt.xlabel('Sepal Length (cm)')
plt.ylabel('Sepal Width (cm)')
plt.title('Real Classification, Sepals')

plt.subplot(2,2,4)
plt.scatter(iris.data[:,0], iris.data[:,1], c=colormap[iris_pred], s=40)
plt.xlabel('Sepal Length (cm)')
plt.ylabel('Sepal Width (cm)')
plt.title('Naive Bayes Classification, Sepals')

plt.suptitle('Naive Bayes Results')
plt.tight_layout()
plt.show()



################
### Logit
################


# set up the model. using a logit regresison, for probabilities of being a flower

logit = LogisticRegression()


# fit the data with the model, and test it

logit.fit(x_train, y_train)
predictions = logit.predict(x_test)


# print predictions and actual flower classifications, to visually see results

print predictions
print y_test


# run the model on the entire iris data set

iris_pred = logit.predict(iris.data)


# plot the results!!

plt.figure()

plt.subplot(2,2,1)
plt.scatter(iris.data[:,2], iris.data[:,3], c=colormap[iris.target], s=40)
plt.xlabel('Petal Length (cm)')
plt.ylabel('Petal Width (cm)')
plt.title('Real Classification, Petals')


plt.subplot(2,2,2)
plt.scatter(iris.data[:,2], iris.data[:,3], c=colormap[iris_pred], s=40)
plt.xlabel('Petal Length (cm)')
plt.ylabel('Petal Width (cm)')
plt.title('Logit Classification, Petals')

plt.subplot(2,2,3)
plt.scatter(iris.data[:,0], iris.data[:,1], c=colormap[iris.target], s=40)
plt.xlabel('Sepal Length (cm)')
plt.ylabel('Sepal Width (cm)')
plt.title('Real Classification, Sepals')

plt.subplot(2,2,4)
plt.scatter(iris.data[:,0], iris.data[:,1], c=colormap[iris_pred], s=40)
plt.xlabel('Sepal Length (cm)')
plt.ylabel('Sepal Width (cm)')
plt.title('Logit Classification, Sepals')

plt.suptitle('Logit Regression Results')
plt.tight_layout()
plt.show()



