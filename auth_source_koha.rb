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
    uristring = Setting.plugin_sso_koha['koha_auth_script_url']
#    uristring = 'http://kohapreprod3:8080/cgi-bin/koha/svc/OPLIB/redmineSSOAuthCheck'
    uri = URI.parse(uristring)
    http = Net::HTTP.new(uri.host, uri.port)
#    http.use_ssl = true
#    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({
      :kohauser => login,
      :kohasessionid => password
      })
    response = http.request(request)
    body = JSON.parse(response.body)
#    logger.debug(body)
    return nil if body.key?('badsessionid') || body.key?('paramsmissing')

#    if AuthSource.find_by_name('Koha').nil?
#      as = AuthSource.new {
#        |as| as.type = 'AuthSourceKoha', as.name = 'Koha',
#        as.host = 'renki.vaarakirjastot.fi', port = 3306, as.account = 'dbuser',
#        as.password = 'dbpass', as.base_dn = 'mysql:dbname', as.attr_login = 'name',
#        as.attr_firstname = 'firstName', as.attr_lastname = 'lastName',
#        as.attr_mail = 'email', as.onthefly_register = 1, as.tls = 0,
#        as.filter = nil, as.timeout = nil
#      }
#      as.save
#    end

    retVal = {  :firstname => body['firstname'],
                :lastname => body['surname'],
                :mail => body['emailaddress'],
                :auth_source_id => self.id
             } if(onthefly_register?)
    return retVal
  end

  def auth_method_name
    'Koha'
  end
end

