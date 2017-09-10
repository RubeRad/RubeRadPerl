#! /bin/perl

use FindBin;
use lib "$FindBin::Bin";
use STATS;
use Getopt::Std;
%opt = ();
getopts('hk:', \%opt);

$usage  = "Usage: average.pl [-h] [-k col,col,...]\n";
$usage .= "  -h             _h_elp\n";
$usage .= "  -k col,col,... comma-separated list of columns [DEF: 0]\n";
if ($opt{h}) {
  print $usage;
  exit;
}

if ($opt{k}) { @cols = split ',', $opt{k} }
else         { @cols = (0) }

while (<>) {
  @vals = (split)[@cols];
  for $k (0..$#cols) {
    STATS::Stat($vals[$k], $cols[$k]);
  }
}

print STATS::StatRpt;
