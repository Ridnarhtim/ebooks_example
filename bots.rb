require 'twitter_ebooks'

#based on the bot example found at https://github.com/mispy/ebooks_example

# Information about a particular Twitter user we know
class UserInfo
  attr_reader :username

  # @return [Integer] how many times we can pester this user unprompted
  attr_accessor :pesters_left

  # @param username [String]
  def initialize(username)
    @username = username
    @pesters_left = 1
  end
end

def top100; @top100 ||= model.keywords.take(100); end
def top20;  @top20  ||= model.keywords.take(20); end

class CloneBot < Ebooks::Bot
  attr_accessor :original, :model, :model_path

  def configure
    # Configuration for all CloneBots
    self.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
    self.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
    # Users to block instead of interacting with
    self.blacklist = []
    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
    @userinfo = {}
  end

  def on_startup
    generate_config_file!
    load_model!
   # Tweet every hour
    scheduler.cron '0 * * * *' do  
      tweet(model.make_statement)
    end
	
	# Reload model every 24h (at 5 minutes past 1am)
    scheduler.cron '5 1 * * *' do  
      load_model!
    end
  end

  def on_message(dm)
    delay do
      reply(dm, model.make_response(dm.text))
    end
  end

  def on_mention(tweet)
    # Become more inclined to pester a user when they talk to us
    userinfo(tweet.user.screen_name).pesters_left += 1

    delay do
      reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
    end
  end

  def on_timeline(tweet)
    return if tweet.retweeted_status?
    return unless can_pester?(tweet.user.screen_name)

    tokens = Ebooks::NLP.tokenize(tweet.text)

    interesting = tokens.find { |t| top100.include?(t.downcase) }
    very_interesting = tokens.find_all { |t| top20.include?(t.downcase) }.length > 2

    delay do
      if very_interesting
        favorite(tweet) if rand < 0.5
        retweet(tweet) if rand < 0.1
        if rand < 0.01
          userinfo(tweet.user.screen_name).pesters_left -= 1
          reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
        end
      elsif interesting
        favorite(tweet) if rand < 0.05
        if rand < 0.001
          userinfo(tweet.user.screen_name).pesters_left -= 1
          reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
        end
      end
    end
  end

  # Find information we've collected about a user
  # @param username [String]
  # @return [Ebooks::UserInfo]
  def userinfo(username)
    @userinfo[username] ||= UserInfo.new(username)
  end

  # Check if we're allowed to send unprompted tweets to a user
  # @param username [String]
  # @return [Boolean]
  def can_pester?(username)
    userinfo(username).pesters_left > 0
  end

  # Only follow our original user or people who are following our original user
  # @param user [Twitter::User]
  def can_follow?(username)
    @original.nil? || username.casecmp(@original) == 0 || twitter.friendship?(username, @original)
  end

  def favorite(tweet)
    if can_follow?(tweet.user.screen_name)
      super(tweet)
    else
      log "Unfollowing @#{tweet.user.screen_name}"
      twitter.unfollow(tweet.user.screen_name)
    end
  end

  def on_follow(user)
    if can_follow?(user.screen_name)
      follow(user.screen_name)
    else
      log "Not following @#{user.screen_name}"
    end
  end

  private

  def generate_config_file!
    log "generating config file at #{ENV['HOME']}/.ebooksrc"
    config_path = "#{ENV['HOME']}/.ebooksrc"
    jsonstring =  "{\"consumer_key\": \"#{ENV["CONSUMER_KEY"]}\"," + 
                  "\"consumer_secret\": \"#{ENV["CONSUMER_SECRET"]}\"," + 
                  "\"oauth_token\": \"#{ENV["ACCESS_TOKEN"]}\"," + 
                  "\"oauth_token_secret\": \"#{ENV["ACCESS_TOKEN_SECRET"]}\"}"
    File.write(config_path, jsonstring)
  end

  def load_model!
    corpus_path = "corpus/#{original}.json"
    @model_path ||= "model/#{original}.model"

    Ebooks::Archive.new(original, corpus_path).sync
    Ebooks::Model.consume(corpus_path).save(model_path)
    
    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

# Make bot
CloneBot.new(ENV["BOT_NAME"]) do |bot|
  bot.access_token = ENV["ACCESS_TOKEN"] # Token connecting the app to this account
  bot.access_token_secret = ENV["ACCESS_TOKEN_SECRET"] # Secret connecting the app to this account
  bot.original = ENV["BOT_ORIGINAL_USER"]
end
