#! /bin/perl

use Getopt::Std;
%opt = ();
getopts('tvsSh', \%opt);
$usage  = "Usage:\n";
$usage .= "subinplace.pl [-htv] 'before_pat' 'after_pat' files...\n";
$usage .= "     -h    _h_elp\n";
$usage .= "     -t    _t_est (print changed lines, but don't modify any files)\n";
$usage .= "     -v    _v_erbose (print lines as they are being modified)\n";
$usage .= "NOTE: in before_pat, you can use . for one wildcard or .* for multiple\n";
$usage .= "\n";
if ($opt{h}) {
    print $usage;
    exit;
}

$bef = shift @ARGV;
$aft = shift @ARGV;

# special undocumented switches to override either the entire before or after pattern with 
if ($opt{S}) { $bef = "\\" }
if ($opt{s}) { $aft = "\\" }

@files = map glob, @ARGV;

for $f (@files) {
  open IN, $f;
  @lines = (<IN>);
  close IN;

  open OUT, ">$f"             unless $opt{t};
  for (@lines) {
      if (s!$bef!$aft!g) { 
	  print STDOUT           if ($opt{t} or $opt{v});
      }
      print OUT               unless $opt{t};
  }
  close OUT                   unless $opt{t};
}
