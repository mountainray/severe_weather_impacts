library("tm")
library("SnowballC")
library("wordcloud")

justevtype <- raw_us_storms %>% select(evtype) %>% distinct(evtype)
head(justevtype)
justevtype[63,]
str(as.vector(justevtype$evtype))
docs<-VCorpus(VectorSource(as.vector(as.character(justevtype$evtype))))
docs
inspect(stemDocument(docs[[63]]))
# docs<-VCorpus(DataframeSource(justevtype))
# docs
inspect(docs[[63]])

#docs<- tm_map(docs, stripWhitespace)

# toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
# 
# docs <- tm_map(docs, toSpace, "/")
# docs <- tm_map(docs, toSpace, "@")
# docs <- tm_map(docs, toSpace, "\\|")

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
#docs
# Remove numbers
docs <- tm_map(docs, removeNumbers)

# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))

# Remove your own stop word
# specify your stopwords as a character vector
###docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 

# Remove punctuations
docs <- tm_map(docs, removePunctuation)

# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

# Text stemming
docs <- tm_map(docs, stemDocument)
docs
inspect(docs[[63]])
dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)

set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

findAssocs(dtm, terms = "ice"
	   , corlimit = 0.01
	   )

findFreqTerms(dtm, 1)

inspect(removeSparseTerms(dtm, 0.4))

barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
        col ="lightblue", main ="Most frequent words",
        ylab = "Word frequencies")