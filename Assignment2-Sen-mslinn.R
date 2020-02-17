
#install.packages("httr")
#install.packages("devtools")
#install.packages("httr")
#install.packages("tidyverse")
#devtools::install_github("r-lib/gh")
#install.packages("ggplot2")

# Libraries used
library(httr)
library(devtools)
library(gh)
library(tidyverse)
library(curl)
library (purrr)
library (doParallel)
library(knitr)
library(kableExtra)
library(ggplot2)
library(lubridate)
library(stringr)
library(RColorBrewer)
library(ggthemes)

#Set github token
my_token = "154dd284f7b8c8a2f8eb3ca8804c13896fac4af6"
Sys.setenv(GITHUB_TOKEN = my_token)

#1. User's Basic Information

user <- gh("/users/mslinn", .limit = Inf)

user_df <- data.frame(user_id = user$id,user_name = user$name,
                      pub_repos = user$public_repos, followers = user$followers)

#This table shows the user's id, name, public_repos, followers
kable(user_df,caption = "This table shows the user's id, name, public_repos, followers") %>%
  kable_styling(bootstrap_options = "striped", full_width = F, position = "left",
                fixed_thead = T)  


#2. Followers' Basic Information

#followers data is read from github api
user_followers <- gh("/users/mslinn/followers", .limit = Inf)

# All details of followers of dunglas user
user_followers = map_df(
  user_followers, magrittr::extract, names(user_followers[[1]]))


# user details of each follower
followers_details = 
  map(user_followers$login, ~gh(paste0("/users/", .)))

followers_df = NULL

#For loop is run to capture the id, name, public_repos, followers for each follower
for (i in seq_along(followers_details)){
  id <- followers_details[[i]]$id
  public_repos <- followers_details[[i]]$public_repos
  followers <- followers_details[[i]]$followers
  if (is.null(followers_details[[i]]$name)){
    name = "NA"
  }
  else{
    name = followers_details[[i]]$name
  }
  followers_df = rbind(followers_df, data.frame(id, name, public_repos, followers))
}

#This table summarizes followers' id, name, public_repos and followers.
kable(followers_df,
      caption = "This table summarizes followers' id, name, public_repos and followers.") %>%
  kable_styling(bootstrap_options = "striped", full_width = F, position = "left",
                fixed_thead = T)


#3. User's Repositories Information 

#repository data is read from github api
user_repos <- gh("/users/mslinn/repos", .limit = Inf)

repos_df = NULL

#For loop is run to capture the name,language,size,forks_count,stargazers_count,
#watchers_count,open_issues_count for each follower
for (i in seq_along(user_repos)){
  name <- user_repos[[i]]$name
  size <- user_repos[[i]]$size
  forks_count <- user_repos[[i]]$forks_count
  stargazers_count <- user_repos[[i]]$stargazers_count
  watchers_count <- user_repos[[i]]$watchers_count
  open_issues_count <- user_repos[[i]]$open_issues_count
  if (is.null(user_repos[[i]]$language)){
    language = "Unknown"
  }
  else{
    language = user_repos[[i]]$language
  }
  repos_df = rbind(repos_df, data.frame(name,language,size,forks_count,stargazers_count,
                                        watchers_count,open_issues_count))
}

#This table summarizes the repositories' name, language, size, forks_count, 
#stargazers_count, watchers_count and open_issues_count".

kable(repos_df,
      caption = "This table summarizes the repositories' name, language, size, 
      forks_count, stargazers_count, watchers_count, open_issues_count") %>%
  kable_styling(bootstrap_options = "striped", full_width = F, position = "left",
                fixed_thead = T)


#4. Summary of Issues by Repository

# collect repository data into a dataframe
mslinn_repos_df <-
  data_frame(
    repo = user_repos %>% map_chr("name"),
    issue = repo %>%
      map(~ gh(repo = .x, endpoint = "/repos/mslinn/:repo/issues?state=all",.limit = #Inf)
      )
      ))

issue_df = NULL

# For loop run to get counts of open and closed issues for each repository 
#and also the average duration to close an issue

for(i in 1:length(mslinn_repos_df$issue)){
  open = 0
  closed = 0
  duration = 0
  if(length(mslinn_repos_df$issue[[i]])>0){
    for(j in 1:length(mslinn_repos_df[[2]][[i]]))
      if(mslinn_repos_df[[2]][[i]][[j]][["state"]]=='open'){
        open = open+1
      }else{
        closed = closed+1
        duration = duration + ymd_hms(mslinn_repos_df[[2]][[i]][[j]][["closed_at"]]) - ymd_hms(mslinn_repos_df[[2]][[i]][[j]][["created_at"]])
      }
  }
  duration = duration / closed
  duration = as.duration(duration)
  repo = mslinn_repos_df$repo[[i]]
  issue_df = rbind(issue_df, data.frame(repo,open,closed,duration))
}

#This table summarizes the issues and include columns: repo name, 
#the number of open issues, the number of closed issues, 
#the average duration to close an issue

kable(issue_df,
      caption = "This table summarizes the issues and include columns: 
      repo name, the number of open issues, the number of closed issues, 
      the average duration to close an issue") %>%
  kable_styling(bootstrap_options = "striped", full_width = F, position = "left",
                fixed_thead = T)


#Plots
#Plot1- shows Mike's followers with more than 100 public_repos and their followers

plot1 <- ggplot(followers_df%>% filter(public_repos>100) %>% filter(name != 'NA') , aes(x=followers, y=name))+
  geom_point()+
  labs(title="Name of followers VS their follower")+
  xlab("Name")+
  ylab("Followers")

plot1

#Plot2- summarizes open issues in each of Mike's repositories.
plot2 <- issue_df %>% filter( open > 0 ) %>%
  ggplot(aes(x=repo, y=open)) + 
  geom_bar(stat="identity", width=.5, fill="blue") + 
  theme(axis.text.x = element_text(angle=90, vjust=0.6))+
  labs(title="Bar Plot",
       subtitle="Summary of count of Language based on repositories")+
  xlab("Repo_Name")+
  ylab("No. of open issues")

plot2

#Plot3- Summarizes the count for each language used in Mike's repositories. 

plot3 <- ggplot(repos_df, aes(language)) + 
  geom_bar() +
  theme_economist()+
  labs(title="Bar Plot",
       subtitle="Summary of count of Language based on repositories")+
  xlab("Language")+
  ylab("Count")

plot3

#Plot4- Summarizes the largest repositories by size and language.
#The top 3 repositories are spark,	playframework, scala.

options(scipen = 999)

plot4 <- repos_df %>%
  filter(size > 20000) %>%
  ggplot(aes(language, size, color = name)) + geom_point() +
  labs(title="Largest repositories by size and language") +
  xlab("Language")+
  ylab("Size")+
  theme_gdocs()+
  scale_color_gdocs()

plot4

