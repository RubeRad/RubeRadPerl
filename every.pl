#! /bin/perl

use Getopt::Std;
%opt = ();
getopts('hs:', \%opt);
$usage  = "every.pl [options] N [file(s)]\n";
$usage .= "Print every Nth line\n";
$usage .= "   -s skip   Number of lines to skip at first\n";
$usage .= "   -h        Help; this message, then quit\n";

if ($opt{h}) {
    print $usage;
    exit;
}

$every = shift @ARGV;

$plus = 0;
for $i (1..9) {
  if ($opt{$i}) { $plus += $i }
}
$plus += $opt{p};


while (<>) {
  $modulus = ($line - $plus + $every) % $every;
  print unless $modulus;
  $line++;
}


