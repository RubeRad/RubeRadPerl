#! /bin/perl

use Getopt::Std;
%opt = (t=>1);
getopts('ht', \%opt);

$usage .= "Creates ./name.pl\n";
$usage .= "Usage: newscript.pl [-h] name[.pl]";
$usage .= "  -h   _h_elp (this message)\n";
#$usage .= "  -t   _t_est switch included in name.pl\n";
if ($opt{h}) {
  print $usage;
  exit;
}

$fname = shift @ARGV;
$fname =~ s!\.pl$!!; # strip .pl if any
$fname .= '.pl';

$options = $opt{t} ? 'htv' : 'hv';

$script .= qq[#! /bin/perl\n];
$script .= qq[\n];
$script .= qq[use FindBin;\n];
$script .= qq[use lib \$FindBin::Bin;\n];
$script .= qq[use Rube;\n];
$script .= qq[use Getopt::Std;\n];
$script .= qq[\%opt = ();\n];
$script .= qq[getopts('$options', \\\%opt);\n];
$script .= qq[\n];
$script .= qq[STDOUT->autoflush(1);\n];
$script .= qq[\$usage .= "Usage: $fname [-$options]\\n";\n];
$script .= qq[\$usage .= "  -h   _h_elp (this message)\\n";\n];
if ($opt{t}) {
  $script .= qq[\$usage .= "  -t   _t_est (print, but don't execute cmds)\\n";\n];
}
$script .= qq[\$usage .= "  -v   _v_erbose\\n";\n];
$script .= qq[if (\$opt{h}) {\n];
$script .= qq[  print \$usage;\n];
$script .= qq[  exit;\n];
$script .= qq[}\n];

open  PL, ">$fname";
print PL $script;
close PL;
