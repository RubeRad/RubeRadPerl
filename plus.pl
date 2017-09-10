#! /bin/perl

$arg = shift @ARGV;
$addendum = eval($arg);

while (<>) {
  @oldwords = split;
  @newwords = ();
  for $word (@oldwords) {
    if ($word != 0.0) {
      $word += $addendum;
    }
    push @newwords, $word;
  }
  print "@newwords\n";
}
