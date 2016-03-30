library(Rfacebook)
library(tm)
library(ggplot2)
library(slam)
library(wordcloud)
fb_oauth <- fbOAuth(app_id="xxxxx", app_secret="xxxxxxxx",
                    extended_permissions = TRUE)
fb <- getUsers("me", token=fb_oauth)

access_token<-("xxxxxx")

facebook <- function(query,token){
  myresult <- list()
  i <- 0 
  next.path<-sprintf( "https://graph.facebook.com/v2.2/%s&access_token=%s",query, access_token)
 
  while(length(next.path)!=0) {
    i<-i+1
    
    myresult[[i]]<-fromJSON(getURL(next.path, ssl.verifypeer = FALSE, useragent = "R" ),unexpected.escape = "keep")
    next.path<-myresult[[i]]$paging$'next'
  }   
  return (myresult)  
}
myposts<-
  facebook("me/posts?fields=story,message,comments.limit(1).summary(true),likes.limit(1).summary(tr
ue),created_time",access_token)

parse.master <- function(x, f)
  sapply(x$data, f)
parse.likes <- function(x) if(!is.na(unlist(x)['likes.summary.total_count'])) (as.numeric(unlist(x)['likes.summary.total_count'])) else 0
mylikes <- unlist(sapply(myposts, parse.master, f=parse.likes))
parse.comments <- function(x) if(!is.na(unlist(x)['comments.summary.total_count'])) (as.numeric(unlist(x)['comments.summary.total_count'])) else 0
mycomments <- unlist(sapply(myposts, parse.master, f=parse.comments))
parse.messages <- function(x) if(!is.null(x$message)){ x$message} else{if(!is.null(x$story)){x$story} else {NA}}
mymessages <- unlist(sapply(myposts, parse.master, f=parse.messages))
parse.id <- function(x) if(!is.null(x$id)){ x$id} else{NA}
myid <- unlist(sapply(myposts, parse.master, f=parse.id))
parse.time <- function(x) if(!is.null(x$created_time)){x$created_time} else{NA}
mytime <- unlist(sapply(myposts, parse.master, f=parse.time))
mytime<-(as.POSIXlt(mytime,format="%Y-%m-%dT%H:%M:%S"))
#put everything into a data.frame
fbPosts<-data.frame(postId=myid,message=mymessages,likes.count=mylikes,comments.count=mycomments,time=mytime,year=mytime$year+1900,
                    dom=mytime$mday,hour=mytime$hour,wd=weekdays(mytime),month=months(mytime))
#most commented
fbPosts[which.max(fbPosts$comments.count),]
#most liked
fbPosts[which.max(fbPosts$likes.count),]
#all posts
fbPosts[(fbPosts$comments.count),]$message

Cf= fbPosts[(fbPosts$comments.count),]$message
write.csv( cf, 'cf.csv')
tb<-read.csv('cf.csv')

myCorpus <- Corpus(VectorSource(tb))
myCorpus <- tm_map(myCorpus, content_transformer(tolower))
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))

myCorpus <- tm_map(myCorpus, stripWhitespace)
 myCorpusCopy <- myCorpus
 myCorpus <- tm_map(myCorpus, stemDocument)
 tdm <- TermDocumentMatrix(myCorpus,  control=list(wordLengths = c(1, Inf)))
 term.freq <- rowSums(as.matrix(tdm))
 term.freq <- subset(term.freq, term.freq >= 10)
df <- data.frame(term = names(term.freq), freq = term.freq)
 ggplot(df, aes(x = term, y = freq)) + geom_bar(stat = "identity")+xlab("Terms") + ylab("Count") + coord_flip()
wordcloud(words = names(word.freq), freq = word.freq, min.freq = 3,
           random.order = F)
