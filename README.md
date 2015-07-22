# sso_koha
Redmine plugin that implements a simple SSO authentication scheme between Koha and Redmine.

Requires creating an authentication source entry in the Redmine auth_sources table. For this plugin, the auth source name must be 'Koha' (e.g.):

insert into auth_sources values( null, 'AuthSourceKoha', 'Koha', 'renki.vaarakirjastot.fi', 1234, 'dbuser', 'dbpass', 'mysql:dbname', 'name', 'firstName', 'lastName', 'email', 1, 0, null, null);
