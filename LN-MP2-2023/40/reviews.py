#importing libraries
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.feature_extraction.text import TfidfVectorizer
import re
from nltk.stem import WordNetLemmatizer

#Read file into df
file = pd.read_csv("train.txt", sep="	", header=None, names = ["Label","Review"])
df = file[['Review','Label']].copy()


#Read test_just_reviews into df and append it to main df
tjr = pd.read_csv("test_just_reviews.txt", sep="	",header = None, names = ["Review","Label"])
df = pd.concat([df, tjr], ignore_index=True)


#Make reviews and labels into lists
review_list = df["Review"].values.astype('U').tolist()
varietal_list = df["Label"].tolist()


#Create lemmatizer
lemmatizer = WordNetLemmatizer()

#Remove lemmatize the reviews
reviews = []
for i in range(0, len(review_list)):
    review = re.sub('[^a-zA-Z]', ' ', review_list[i])
    review = review.lower()
    review = review.split()
    review = [lemmatizer.lemmatize(word) for word in review]
    review = ' '.join(review)
    reviews.append(review)


#tf idf
tf_idf = TfidfVectorizer()
#applying tf idf to training data
X_train_tf = tf_idf.fit_transform(reviews)

#Train test split
TS = 0.125
X_train, X_test, y_train, y_test = train_test_split(X_train_tf, varietal_list, test_size = TS, shuffle = False)

#Support Vector
clf = SVC(kernel = "linear").fit(X_train, y_train)



#Make the predictions of test_just_reviews.txt
y_score = clf.predict(X_test)

#Write labels in file
file = open('results.txt','w')
for label in y_score:
	file.write(label+"\n")
file.close()


