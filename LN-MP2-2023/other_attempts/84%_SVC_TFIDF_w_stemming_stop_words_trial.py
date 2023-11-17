#importing libraries
import pandas as pd
from sklearn.model_selection import train_test_split

from sklearn.naive_bayes import MultinomialNB
from sklearn.svm import SVC
from sklearn.feature_extraction.text import TfidfVectorizer
import nltk
import re
from nltk.stem import WordNetLemmatizer


#Read file into df
file = pd.read_csv("train.txt", sep="	", header=None, names = ["Label","Review","N1","N2","N3"])
df = file[['Review','Label']].copy()


#Make reviews and labels into lists
review_list = df["Review"].values.astype('U').tolist()
varietal_list = df["Label"].tolist()


#Create lemmatizer and define the english stopwords
lemmatizer = WordNetLemmatizer()
nltk.download("stopwords")
nltk.download("wordnet")
stopwords = nltk.corpus.stopwords.words('english')
print(stopwords)


import itertools
def get_combinations(lst): # creating a user-defined method
   combination = [] # empty list 
   for r in range(1, len(lst) + 1):
      # to generate combination
      combination.extend(itertools.combinations(lst, r))
   return combination

all_combinations = get_combinations(stopwords[:20]) # method call

old_accuracy = 0
for j in all_combinations:
    print("\t\t\t working...")
    #Remove stop words and lemmatize the reviews
    reviews = []
    for i in range(0, len(review_list)):
        review = re.sub('[^a-zA-Z]', ' ', review_list[i])
        review = review.lower()
        review = review.split()
        review = [lemmatizer.lemmatize(word) for word in review if word not in j]
        review = ' '.join(review)
        reviews.append(review)


    #tf idf
    tf_idf = TfidfVectorizer()
    #applying tf idf to training data
    X_train_tf = tf_idf.fit_transform(reviews)
    TS = 0.3


    #Train test split
    X_train, X_test, y_train, y_test = train_test_split(X_train_tf, varietal_list, test_size = TS, shuffle = False)


    #Support Vector
    clf = SVC(kernel = "linear").fit(X_train, y_train)


    #Make the predictions
    y_score = clf.predict(X_test)



    #Calculate and print accuracy
    n_right = 0
    for i in range(len(y_score)):
        if y_score[i] == y_test[i]:
            n_right += 1
    
    accuracy = (n_right/float(len(y_test)) * 100)
    if accuracy > old_accuracy:
        print("Accuracy: %.2f%%" % ((n_right/float(len(y_test)) * 100)))
        print(j)
        old_accuracy = accuracy

# #Create datframe with Prediction Label/ Real Label / Review
# df_aux = pd.DataFrame({"Prediction":y_score, "Real": y_test, "Review":review_list[round((1-TS)*len(review_list)):]})
# df_filtered = df_aux[df_aux['Prediction'] != df_aux["Real"]]

# #Export wrong predictions to file
# df_filtered.to_csv(path_or_buf="wrong_predictions.csv", index = False, sep = "\t")