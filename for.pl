#! /bin/perl

# Parse command-line switches
use Getopt::Std;
%opt = ();
getopts('htq', \%opt);

$usage  = "Usage: for.pl [-htqt] 'do stuff with EACH file' [files]\n";
$usage .= "  -h   _h_elp\n";
$usage .= "  -t   _t_est (print, but don't execute cmds)\n";
$usage .= "  -q   _q_uiet operation (no STDERR)\n";
if ($opt{h}) {
  print $usage;
  exit;
}

$cmd   = shift @ARGV;
die $usage unless $cmd =~ /EACH/;
@files = map glob, @ARGV;

foreach $file (@files) {
  chomp $file;

  # construct the command-line
  ($command = $cmd) =~ s!EACH!$file!;

  @cmdlist = split ';', $command;
  for (@cmdlist) {
    # process the command-line
    print "$_\n"                  unless $opt{q};
    system($_)                    unless $opt{t};
  }
}
