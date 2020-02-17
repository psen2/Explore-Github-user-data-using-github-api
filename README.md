# Explore-Github-user-data-using-github-api
## GitHub User Description and User Page URL
Mike Slinn - Avid scala and Play Framework user & developer. According to his bio on Github he is a "Voyager of inner space". Mike is the founder of Micronautics Research Corporation. He has has sixty-two (193) repos and fifty-five (69) followers. Mike Slinn’s GitHub page url https://github.com/mslinn.
## User's Basic Information
* Data for user **mslinn** is read from github api. This list format data is the stored in  **user**.   
* List data is extracted into a dataframe **user_df** 
## Followers’ Basic Information
* Followers data is read from github api. This list format data is  stored in **user_followers**.   
* **Map()** function used to get the user details of each follower.
* Lastly a For loop is run to capture the id, name, public_repos, followers for each follower.
* For some followers name is not blank, they have been replaced by **"NA"**
## User's Repositories Information
* Repository data is read from github api. This list format data is  stored in **user_repos**.   
* For loop is run to capture the name, language, size, forks_count, stargazers_count, watchers_count and open_issues_count for each repository.
* For repositories with language as null, it is replaced with **"Unknown"**.
## Summary of Issues by Repository
* Issue data is read from user repository and stored in dataframe **mslinn_repos_df**
* For loop is run to capture the total no. of open and closed issues within each repository, and also to calculate the average duration for an issue to close.
## Data Exploration
