class Authentication
  include Datamapper::Resource

  property :id, Serial
  property :username, String, :required => true
  property :access_token, String, :required => true

end
