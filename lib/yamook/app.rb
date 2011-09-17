module Yamook
  class App < Sinatra::Base

    configure do
      DataMapper.setup(:default, "postgres://localhost/yammook_dev")
      set :root, File.dirname(__FILE__)
    end

    configure :production do
      DataMapper.setup(:default, ENV['DATABASE_URL'])
    end


    # Configure settings
    get '/' do
      if session[:github_access_token]
        haml :settings
      else
        haml :login
      end
    end

    # Receive github's post-receive hook
    post '/' do

    end

    ##### AUTHENTICATION #####
    get '/auth/github' do
      redirect oauth_client.authorize_url({
        :redirect_uri => redirect_uri,
      })
    end

    get '/auth/github/callback' do
      begin
        access_token = oauth_client.get_token(params[:code], :redirect_uri => redirect_uri)
        session[:github_access_token] = access_token.to_s
        redirect '/'
      rescue OAuth2::HTTPError
        %(<p><a href="/auth/github">Oops, something went wrong. Please try again.</a></p>)
      end
    end

    private

    def oauth_client
      OAuth2::Client.new(ENV['GITHUB_APP_ID'], ENV['GITHUB_APP_SECRET'],
        :site => "https://github.com",
        :authorize_path => "/login/oauth/authorize",
        :access_token_path => "/login/oauth/access_token"
      )
    end

    def redirect_uri(path = "/auth/github/callback", query = nil)
      uri = URI.parse(request.url); uri.path = path; uri.query = query; uri.to_s
    end
  end
end

