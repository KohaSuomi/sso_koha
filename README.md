# sso_koha
Redmine plugin that implements a simple SSO authentication scheme between Koha and Redmine.

Installation:

Standard plugin installation, but note the requirements below.

Requires creating an authentication source entry in the Redmine auth_sources table. For this plugin, the auth source name must be 'Koha' (e.g.):

insert into auth_sources values( null, 'AuthSourceKoha', 'Koha', 'renki.vaarakirjastot.fi', 1234, 'dbuser', 'dbpass', 'mysql:dbname', 'name', 'firstName', 'lastName', 'email', 1, 0, null, null);

* redmineSSOAuthCheck: this file resides in your kohaclone-folder.
* auth_source_koha.rb: this file is loaded by Redmine core automatically and needs to reside in redmine/app/models -folder (i.e. not in the plugins-folder)


Configuration options (under /settings/plugin/sso_koha in Redmine):

* Koha auth script url: this is the url of the redmineSSOAuthCheck -script.
* Login redirect url: this is the url you want to redirect users succesfully authenticating through Koha.
