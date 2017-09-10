#! /bin/perl

use Getopt::Std;
$opt{t} = 0.0;
getopts('t:T:', \%opt);

$f1 = shift @ARGV;
$f2 = shift @ARGV;

open F1, $f1;
open F2, $f2;

#@l1s = (<F1>); $n1 = @l1s;
#@l2s = (<F2>); $n2 = @l2s;
if (abs($n1 - $n2) > $opt{t}) {
  print "$f1: $n1 lines vs. $f2: $n2 lines\n";
}
#for $n (0..$#l1s) {
$n = "0";
while ($l1 = <F1>) {
  #$l1 = $l1s[$n];
  #$l2 = $l2s[$n];
  $l2 = <F2>;
  #print $l1;
  @w1s = split /\s+/, $l1; $n1 = @w1s;
  @w2s = split /\s+/, $l2; $n2 = @w2s;

  if (abs($n1-$n2) > $opt{t}) {
    print "$f1:$n: $n1 words vs. $f2:$n: $n2 words\n";
  }

  for $i (0..$#w1s) {
    next if /GROUND_ZERO|LOAD_PT/;
    $w1 = $w1s[$i];
    $w2 = $w2s[$i];
    next if $w1 eq $w2;
    $dw = $w2 - $w1;
    $rw = $w1==0 ? 1 : abs($dw/$w1);
    if ($opt{T}) {
      if (abs($dw) > $opt{T}) {
        print "$f1:$n:$i: $w1 vs. $f2:$n:$i: $w2\tdiff=$dw\trel=$rw\n";
      }
    } elsif ($rw > $opt{t}) {
      print "$f1:$n:$i: $w1 vs. $f2:$n:$i: $w2\tdiff=$dw\trel=$rw\n";
    }
  }

  $n++;
}
