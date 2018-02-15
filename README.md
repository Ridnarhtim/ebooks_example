# simple_heroku_twitter_ebooks

Designed to make it as simple as possible to create your bot and run it in the cloud (using Heroku).
Based on https://github.com/mispy/ebooks_example

## Prerequisites

Set up your bot's Twitter account by following steps 1-3 here:
https://medium.com/science-friday-footnotes/how-to-make-a-twitter-bot-in-under-an-hour-259597558acf


Create a Heroku account on http://heroku.com/.
If asked for a Primary Development Language, select Ruby.
You'll need to add a credit card to your account (you won't be billed though) https://dashboard.heroku.com/account/billing

## Set up

Download this repository by clicking the green Clone or Download button near the top of this page, then Download Zip. Extract the archive to a folder (I'd recommend somewhere in My Documents where you can keep the folder long-term)

Follow the steps to create a heroku app here:
https://devcenter.heroku.com/articles/git

You'll need to fullfill the prerequisites, then follow the steps under
- Tracking your app in Git
- Creating a Heroku remote -> For a new Heroku app
- Deploying code (just the first paragraph, ignore the bit about branches)

If you're under Windows and don't know how to use the linux command line, check the section *Additional Help Running Commands in Windows* at the bottom of this page


Then go to
https://dashboard.heroku.com/apps
You should see your app here, with a randomly generated name. Click it, then go to settings and click reveal config vars.
You'll need to add the following keys and values here (make sure everything is spelled and capitalised correctly, including Twitter usernames)

KEY | VALUE |
--- | --- |
CONSUMER_KEY | (Your consumer key from the Twitter app)
CONSUMER_SECRET | (Your consumer secret from the Twitter app)
ACCESS_TOKEN | (Your access token from the Twitter app)
ACCESS_TOKEN_SECRET | (Your access token secret from the Twitter app)
BOT_NAME | (Your bot's @)
BOT_ORIGINAL_USER | (The @ for the account to imitate)

Finally, start your bot:
Select the Resources tab; under Free Dynos, you should see something like
```bash
worker bundle exec ebooks start
```

Click the pencil icon on the right of that, flip the switch so it's "on", then click confirm.

Your bot should now be running; it might take a minute or so to start up and build its model, so wait a bit then try tweeting at it.


## Additional Help Running Commands in Windows

In Windows, it's easiest to run the commands for Heroku in Git Bash, which gets installed as part of git.
Open the Git Bash program, then instead of "cd myapp", replace myapp with the full path to the folder containing the code, **in single quotes**; for example:
```bash
cd 'C:\Users\<username>\Documents\simple_heroku_twitter_ebooks'
```
You can find out this path by right clicking any file in the folder and selecting properties; you can copy the path to the folder next to Location, then right click in git bash and paste (ctrl+v won't work!)
