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

    # The api key for this koha server is missing.
    return nil unless koha_api_key

    response = get_koha_user(:uristring => uristring,
                              :userid => userid,
                              :sessionid => sessionid,
                              :apikey => koha_api_key)



    # Anything except '200' from the api means a failed call.
    return nil unless response.code == '200'

    koha_user = JSON.parse(response.body)

    auth_info = {
                :firstname => koha_user['firstname'],
                :lastname => koha_user['lastname'],
                :mail => koha_user['mail'],
                :auth_source_id => self.id
             } if(onthefly_register?)
    return auth_info if auth_info

  end


  # Does a Koha REST-API-call to test whether the given Koha session was valid
  # and returns the http response object. See
  def rest_api_call(settings = {})

    userid = settings['userid']
    apikey = settings['apikey']
    uristring = settings['uristring']
    sessionid = settings['sessionid']

    http_verb = 'GET'
    date = DateTime.now
    digest = OpenSSL::Digest.new('sha256')
    message = http_verb + ' ' + userid + ' ' + date.to_s
    hmac = OpenSSL::HMAC.hexdigest(digest, apikey, message)
    auth_header = 'Koha ' + userid + ':' + hmac.to_s

    uri = URI('http://' + uristring + '/v1/auth/session')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path)
    request.add_field('X-Koha-Date', date)
    request.add_field('Authorization', auth_header)
    request.add_field('Cache-Control', 'no-cache')
    request.add_field('sessionid', sessionid)

    return http.request(request)

  end

  private :rest_api_call

  def auth_method_name
    'Koha'
  end
end

