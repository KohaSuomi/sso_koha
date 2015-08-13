# Redmine Koha Authentication Source
#
# Copyright (C) 2010 Andrew R Jackson
# Copyright (C) 2015 Vaarakirjastot
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'openssl'

# Subclass AuthSource
class AuthSourceKoha < AuthSource
  # authentication() implementation
  # - Redmine will call this method, passing the login and password entered
  #   on the Sign In form.
  #
  # +login+ : what user entered for their login
  # +password+ : what user entered for their password
  def authenticate(login, password)
    return nil if (login.blank? || password.blank?)

    password_parts = password.split('@')
    login_parts = login.split('@')

    # The password field must be like 'kohacgisessionid@fullhost'
    return nil if (password_parts[0].length === 0 || password_parts[1].length === 0 || login_parts[0].length === 0 || login_parts[1].length === 0)

    login_parts_userid = login_parts[0]
    login_parts_host_short = login_parts[1]
    password_parts_session_id = password_parts[0]
    password_parts_host_full = password_parts[1]

    uristring = password_parts_host_full
    userid = 'redmine'
    sessionid = password_parts_session_id
    koha_api_key = Redmine::Configuration['koha_api_key_' + login_parts_host_short]
    rest_path = '/v1/auth/session'

    # The api key for this koha server is missing.
    return nil unless koha_api_key

    response = rest_api_call(:uristring => uristring, :userid => userid,
                             :sessionid => sessionid, :apikey => koha_api_key,
                             :rest_path => rest_path)



    # Anything except '200' from the api means a failed call.
    return nil unless response.code == '200'

    koha_user = JSON.parse(response.body)
    login_auth_org_name = login_parts_host_short

    # Create a new auth organization with this user's hostname if it doesn't yet exist.
    unless AuthOrganization.exists?(:name => login_auth_org_name)
      auth_org = AuthOrganization.new
      auth_org.name = login_parts_host_short
      auth_org.save
    end

    auth_org = AuthOrganization.where(:name => login_auth_org_name).take

    auth_info = {
                :firstname => koha_user['firstname'],
                :lastname => koha_user['lastname'],
                :mail => koha_user['email'],
                :auth_organization_id => auth_org.id,
                :auth_source_id => self.id
             } if(onthefly_register?)
    return auth_info if auth_info

  end

  # Does a Koha REST-API-call to test whether the given Koha session was valid
  # and returns the http response object. See
  def rest_api_call(settings = {})

    @userid = settings[:userid]
    @apikey = settings[:apikey]
    @uristring = settings[:uristring]
    @sessionid = settings[:sessionid]
    @rest_path = settings[:rest_path]

    @payload = {
      :sessionid => @sessionid
    }.to_json

    http_verb = 'GET'
    date = DateTime.now
    digest = OpenSSL::Digest.new('sha256')
    message = http_verb + ' ' + @userid + ' ' + date.to_s
    hmac = OpenSSL::HMAC.hexdigest(digest, @apikey, message)
    auth_header = 'Koha ' + @userid + ':' + hmac.to_s

    uri = get_valid_uri('https', @uristring, @rest_path)
    http = Net::HTTP.new(uri.host, uri.port)

    # Attempt https and fall back to http if that fails.
    begin
      request = Net::HTTP::Get.new(uri.path)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request.body = @payload
      request.add_field('X-Koha-Date', date)
      request.add_field('Authorization', auth_header)
      request.add_field('Cache-Control', 'no-cache')
      http.request(request)
    rescue Exception => e
      logger.debug(e.inspect)
      uri = get_valid_uri('http', @uristring, @rest_path)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.path)
      request.body = @payload
      request.add_field('X-Koha-Date', date)
      request.add_field('Authorization', auth_header)
      request.add_field('Cache-Control', 'no-cache')
      http.request(request)
    end

  end

  private :rest_api_call

  def auth_method_name
    'Koha'
  end

  def get_valid_uri(protocol, uristring, rest_path)
    @protocol = protocol + '://'
    @uri = URI(@protocol + uristring + rest_path)
    return @uri
  end

end

