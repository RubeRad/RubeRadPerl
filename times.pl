#! /bin/perl

$pi = atan2(1,1)*4;

$multiplicand = shift @ARGV;
if      ($multiplicand =~ /r2d/i) {
  $factor = 180/$pi;
} elsif ($multiplicand =~ /d2r/i) {
  $factor = $pi/180;
} elsif ($multiplicand =~ /f2m/i) {
  $factor = 0.3048;
} elsif ($multiplicand =~ /m2f/i) {
  $factor = 1.0 / 0.3048;
} else {
  $factor = eval($multiplicand);
}

while (<>) {
  @oldwords = split;
  @newwords = ();
  for $word (@oldwords) {
    if ($word != 0.0) {
      $word *= $factor;
    }
    push @newwords, $word;
  }
  print "@newwords\n";
}
