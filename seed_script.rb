# frozen_string_literal: true

require 'clonk'
def sso(realm_exists = true)
  @sso = Clonk::Connection.new(
    base_url: 'http://sso:8080',
    realm_id: 'master',
    username: 'user',
    password: 'password',
    client_id: 'admin-cli'
  )
  unless realm_exists
    @sso.create_realm(realm: 'test_realm')
  end
  @sso.realm = @sso.realms.find { |realm| realm.name ==  'test_realm' }
  @sso
end
user = sso(realm_exists = false).create_user(username: 'user1')
sso.set_password_for(user: user, password: 'password')
sso.create_client(clientId: 'test_client', publicClient: true, redirectUris: ['http://localhost:8081/callback'])
