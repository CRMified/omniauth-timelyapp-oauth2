require 'omniauth-oauth2'
require 'openssl'
require 'base64'

module OmniAuth
  module Strategies
    class Timelyapp < OmniAuth::Strategies::OAuth2

      option :client_options, {
        :site          => 'https://api.timelyapp.com',
        :authorize_url => '/1.1/oauth/authorize',
        :token_url     => '/1.1/oauth/token',
        :grant_type    => 'authorization_code'
      }
      option :authorize_options, [
        :redirect_uri,
        :grant_type
      ]
      
      def callback_url
        full_host + script_name + callback_path
      end

      uid { raw_info['id'] }

      info do
        unless @info
          @info = raw_info
        end

        @info
      end

      def token
        access_token.token
      end

      credentials do
        hash = {'token' => access_token.token}
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.refresh_token
        hash
      end

      def raw_info
        access_token.options[:mode] = :header
        if @raw_info.nil?
          acct = access_token.get('/1.1/accounts').parsed.last
          acct_id = acct['id'] 
        end
        @raw_info ||= access_token.get("/1.1/#{acct_id}/users/current").parsed.merge({account: acct})
      end

      extra do
        accts =  access_token.get('/1.1/accounts').parsed
        acctid = accts.first['id']
        {
          'account_id' => acctid,
          'accounts' => accts
         }
      end
      

    end

  end
end
OmniAuth.config.add_camelization "app", "App"
