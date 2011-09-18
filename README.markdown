`
	____    ____  ___      .___  ___.   ______     ______    __  ___ 
	\   \  /   / /   \     |   \/   |  /  __  \   /  __  \  |  |/  / 
	 \   \/   / /  ^  \    |  \  /  | |  |  |  | |  |  |  | |  '  /  
	  \_    _/ /  /_\  \   |  |\/|  | |  |  |  | |  |  |  | |    <   
	    |  |  /  _____  \  |  |  |  | |  `--'  | |  `--'  | |  .  \  
	    |__| /__/     \__\ |__|  |__|  \______/   \______/  |__|\__\ 
`
---

Yamook is a post-recieve hook designed for Github. It's not designed to be SaaS-y at all - the idea is for you to fork or download a copy, pop it on the server (it's been optimized for [Heroku](http://heroku.com)), and change config values as required to suit your needs.

## How it works ##

Yamooks got three routes - one to recieve the JSON from Github upon a push, and two to handle authentication with Yammer as a particular user. Yamook uses [Liquid](https://github.com/Shopify/liquid) to generate a message (See 'Usage' below), and then posts that generated message on Yammer as the authenticated user.

## Usage ##

There are two areas that are important for Yamook to work. The first is a message template, and the next is a valid Yammer access token. 

### Templating ###

Yamook uses Liquid to generate the message from the Github JSON, offering the following replacements:
* `{{ message }}` - the commit message
* `{{ user }}` - the author of the commit
* `{{ url }}` - a link to the commit on Github
* `{{ repository }}` - the name of the repository committed to

These values can get interpolated into the template message, which is retrieved from the ENV hash. You can set this in one of two ways:
* Heroku server: use `heroku config:add message_template="{{ user }} pushed to {{ repository }}: {{ message }} ({{ url }})"`
* Non-heroku server: set `message_template` somewhere, probably your shell config: `export message_template=( as above )`

### Authentication ###

In order to post to Yammer, a valid access token with write access is required. To facilitate this, two routes are provided that allow you to login to Yammer as the user account you wish to post as. Once you have done this, the access token will be securely stored in Memcache (on Heroku or your server), and used by the application as needed. It's important that you set the user ID of the Yammer user you are logging in as in the environment as well - this is to prevent any Yammer user from taking over as the broadcaster.

Setting this up is easy - just go to `/auth/yammer` to set yourself up as the broadcaster.


---

## License ##
Created in 2011 by @sudojosh
MIT License
