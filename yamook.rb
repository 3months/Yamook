class Yamook < Sinatra::Base
  set :cache, Dalli::Client.new

  get '/' do
    redirect 'https://github.com/3months/yamook'
  end

  post '/' do
    @message = message_from_payload(params[:payload])
    broadcast_on(:yammer, @message)
  end

  private
  
  def message_from_payload(payload = [])
    @payload = JSON.parse(payload)
    @template = Liquid::Template.parse(ENV['message_template'])
    @template.render({
      :repository => @payload["repository"]["name"],
      :user => @payload["commits"].last["author"]["name"],
      :message => @payload["commits"].last["message"],
      :url => @payload["commits"].last["url"]
    })
  end

  def broadcast_on(provider = :yammer, message)
    #Do the actual broadcasting here, for now, just print the message
    render message
  end
end
