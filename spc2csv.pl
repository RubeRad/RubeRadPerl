#! /bin/perl

while (<>) {
  s/\s+/,/g;
  print;
  print "\n";
}
