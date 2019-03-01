require 'clonk'
require 'jwt'
require 'sinatra'

SSO_PORT = 8080
APP_PORT = ENV['APP_PORT'] || 8081
SSO_INTERNAL_NAME = 'sso'.freeze
REALM = 'test_realm'.freeze
CLIENT = 'test_client'.freeze

get '/' do
  @login_url = Clonk.login_url(
    base_url: "http://localhost:#{SSO_PORT}",
    realm_id: REALM,
    redirect_uri: "http://localhost:#{APP_PORT}/callback",
    client_id: CLIENT
  )
  erb :login
end

get '/callback' do
  # exchange code
  code = params[:code]
  data = {
    'grant_type' => 'authorization_code',
    'code' => code,
    'client_id' => CLIENT,
    'redirect_uri' => "http://localhost:#{APP_PORT}/callback"
  }
  response = sso_connection(json: false).post "/auth/realms/#{REALM}/protocol/openid-connect/token", data
  session[:access_token] = JSON.parse(response.body)['access_token']
  decoded_token = JWT.decode session[:access_token], nil, false
  decoded_token.to_s
end

def sso_connection(token: nil, json: true)
  Faraday.new(url: "http://#{SSO_INTERNAL_NAME}:8080") do |faraday|
    faraday.request (json ? :json : :url_encoded)
    faraday.authorization :Bearer, token if token
    # faraday.use Faraday::Response::RaiseError
    faraday.adapter Faraday.default_adapter
  end
end
