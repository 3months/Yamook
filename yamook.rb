class Yamook < Sinatra::Base

  set :cache, Dalli::Client.new
  set :permitted_broadcasters, (ENV['permitted_broadcasters'].split(',').map { |broadcaster| broadcaster.strip } rescue [])
  set :permitted_owner, ENV['permitted_owner']
  set :message_matcher, ENV['message_matcher']

  use Rack::Session::Cookie
  use OmniAuth::Strategies::Yammer, ENV['yammer_consumer_key'], ENV['yammer_consumer_secret']

  get '/' do
    redirect 'https://github.com/3months/yamook'
  end

  post '/' do
    @message = message_from_payload(params[:payload])
    return unless @message
    broadcast_on(:yammer, @message)
  end

  #### Yammer Authentication ###
  get '/auth/yammer/callback' do
    auth_hash = request.env['omniauth.auth']
    set_broadcaster(auth_hash)
  end 

  get '/auth/failure' do
    "<h1>Failed to authorize: #{params[:reason]}</h1>"
  end

  private

  def set_broadcaster(auth)
    if settings.permitted_broadcasters.include?(auth['uid'].to_s)
      settings.cache.set('yammer_access_token', auth['credentials']['token'])
      "<h1>You're the broadcaster</h1>" +
      "<p>Thanks #{auth['user_info']['name']}, you've set your account as the broadcaster.</p>"
    else
      "<h1>This account is not authorized to broadcast</h1>" +
      "<p>Your Yammer User ID is #{auth['uid']}. Maybe you forgot to add this to the permitted_broadcasters setting?"
    end
  end

  def message_from_payload(payload = [])
    @payload = JSON.parse(payload)
    @message = @payload["commits"].last["message"]
    @owner = @payload["repository"]["owner"]["name"]
    return unless @message = should_send(@message, @owner)
    @template = Liquid::Template.parse(ENV['message_template'])
    @template.render({
      'repository' => @repository,
      'user' => @payload["commits"].last["author"]["name"],
      'message' => @message,
      'url' => @payload["commits"].last["url"]
    })
  end

  def should_send(msg, own)
    return nil unless settings.permitted_owner == own.strip
    matcher = /\A#{settings.message_matcher}/
    return nil unless msg =~ matcher
    return msg.gsub(matcher, "").strip
  end

  def broadcast_on(provider = :yammer, message)
    raise "No broadcaster set up" if settings.cache.get('yammer_access_token').nil?
    begin
      RestClient.post "https://www.yammer.com/api/v1/messages.json?access_token=#{settings.cache.get('yammer_access_token')}", :body => message
    rescue Exception => exp
      "<h1>Failed to post message</h1><p>#{exp.message}</p>"
    end
  end
end
