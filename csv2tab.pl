#! /bin/perl

while (<>) {
  s/,/\t/g;
  print;
  print "\n";
}
