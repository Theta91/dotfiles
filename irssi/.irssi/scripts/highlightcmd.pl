use strict;
use Irssi;

use vars qw($VERSION %IRSSI);

$VERSION = '1.0';
%IRSSI = (
  authors     => 'Matt "f0rked" Sparks',
  contact     => 'ms+irssi@quadpoint.org',
  name        => 'hilightcmd',
  description => 'Executes command on hilight',
  license     => 'Public domain',
  url         => 'http://quadpoint.org',
  changed     => '2005-06-16',
);

# Run the command when away?
my $run_cmd_when_away = 1;
my $cmd_to_run = "~/irssi/notify.sh";


sub sig_printtext
{
  my($dest, $text, $stripped) = @_;
  my $server = $dest->{server};

  # Run the command if we're hilighted
  if (($dest->{level} & (MSGLEVEL_HILIGHT)) &&
      ($dest->{level} & MSGLEVEL_NOHILIGHT) == 0) {
    system($cmd_to_run, $text);
  }
}


Irssi::signal_add("print text", \&sig_printtext);
