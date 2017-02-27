## Tim Boudreau
## Machine Learning Example
## December 2016

# built-in data set iris
iris

# graphics package
library(ggvis)

# plot scatterplots based on flower characteristics
iris %>% ggvis(~Sepal.Length, ~Sepal.Width, fill = ~Species) %>% layer_points()
iris %>% ggvis(~Petal.Length, ~Petal.Width, fill = ~Species) %>% layer_points()

# data inspection
table(iris$Species)
round(prop.table(table(iris$Species)) * 100, digits = 1) # probabilities

summary(iris)
summary(iris[c("Petal.Width", "Sepal.Width")])

# machine learning package - k nearest neighbor
library(class)

# create a function that normalizes data - need to because mins/maxes 
# are inconsistent through variables... this gives same baseline throughout
normalize <- function(x) {
  num <- x - min(x, na.rm = T)
  denom <- max(x, na.rm = T) - min(x, na.rm = T)
  return (num/denom)
}
# iris doesn't need normalization - every variable is between .1 and 7.9, small range
iris.norm <- as.data.frame(lapply(iris[1:4], normalize)) # 1:4 because thats all we care about

# inspect normalized data
summary(iris.norm)

# set seed - keeps a set of random numbers the same throughout script
set.seed(1234)

# sample with replacement, generate an index to use for test/train splitting
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.67, 0.33))

# test and train subsets of iris, and labels
iris.training <- iris[ind==1, 1:4]
iris.test <- iris[ind==2, 1:4]

iris.trainLabels <- iris[ind==1, 5]
iris.testLabels <- iris[ind==2, 5]

# knn prediction
iris_pred <- knn(train = iris.training, test = iris.test, cl = iris.trainLabels, k=3)

# compare prediction to test set - package
library(gmodels)

CrossTable(x = iris.testLabels, y = iris_pred, prop.chisq=FALSE)

compare <- data.frame(iris_pred, iris.testLabels)

# the ultimate conclusion to the project - compare the model to actual.
compare


