Log in to developers.facebook.com
create a app
Get your app-id and secret-id
Request a access token at https://developers.facebook.com/tools/explorer
note this token is valid for 2 hours
test
retrieve facebook-id fb <- getUsers("me", token=fb_oauth)
Run the source code will get following results
  #most commented post
> fbPosts[which.max(fbPosts$comments.count),]
                            postId
26 994252620652989_249636501781275
                                                                                                                                                                                                                                                                                                      message
26 sarva sadharan ko soochit kiya jata hai ki sanju k janamdin k uplakshya me giddh bhoj avam.............. aayojit kiya jaa raha hai aap sammilit hokar  baki to samajh gaye hoge\n\nsthaan:     rana sana da dhaba\n\ntime: aapke aane se sab k ludhakane tak\nvisesh anurodh :kripya apna glass sath laaye
   likes.count comments.count                time year dom hour     wd    month
26          10             39 2012-02-06 17:17:41 2012   6   17 Monday February





All posts: fbPosts[(fbPosts$comments.count),]$message



