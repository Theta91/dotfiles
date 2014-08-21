use Irssi 20010120.0250 ();
$VERSION = "2";
%IRSSI = (
    authors     => 'David Leadbeater',
    contact     => 'dgl@dgl.cx',
    name        => 'remote',
    description => 'Lets you run commands remotely via /msg and a password',
    license     => 'GNU GPLv2 or later',
    url         => 'http://irssi.dgl.cx/',
    changes     => 'Uses /sets and now has (basic) command limiting',
);

# Usage:
# /set remote_password UNIXCRYPT
# generate with: /script exec print crypt("password", "ok")
# /set remote on (to enable)
# Then from another client:
# /msg user remote login password
# then /msg user remote command
# it will execute the command on the same server...
# so you can do mode #channel +o whoever

# By default all commands are allowed.
# To limit commands do (for example) /set remote_allowed_commands msg|say|ctcp
# (It's a perl regular expression)
# Allowing commands such as alias, exec, set and eval and maybe others will
# allow access to all commands anyway, so be careful.
# No guarantee this works totally either ;)

use strict;
my $login;

sub event{
   my($server,$text,$nick,$hostmask)=@_;
# if you're really paranoid change this....
   if($text =~ s/^remote\s+//i){
	  my $ok;
     $ok = 1 if $login eq "$nick!$hostmask";
	  $ok = 0 unless Irssi::settings_get_bool('remote');
	  my($command,$options) = split(/ /,$text,2);
	  if($command eq "login"){
       my $password = Irssi::settings_get_str('remote_password');
		 if($password eq $password){
			$login = $nick."!".$hostmask;
         Irssi::print("Remote login from $nick ($hostmask)");
		 }else{
			Irssi::print("Invalid login attempt from $nick ($hostmask): $text");
		 }
       Irssi::signal_stop;
	  }elsif(!$ok){
		 Irssi::print("Invalid remote use from $nick ($hostmask): $text");
	  }elsif($ok){
       if($command eq 'logout') {
          $login = undef;
          return;
       }
       my $allowed = Irssi::settings_get_str('remote_allowed_commands');
       if($allowed && $command !~ /^($allowed)$/)
       {
          $server->command("^notice $nick Command $command is not allowed");
          Irssi::print("Invalid command: $command from from $nick ($hostmask)");
          return;
       }
		 $server->command($text);
	  }
   }
}

Irssi::settings_add_bool("misc", "remote", 0);
Irssi::settings_add_str("misc", "remote_password", "");
Irssi::settings_add_str("misc", "remote_allowed_commands", "");

Irssi::signal_add_last("message private", "event");

