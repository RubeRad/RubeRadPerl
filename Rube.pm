package Rube;
use strict;
use warnings;
use Carp qw(carp croak);

require Exporter;

# by default nothing is exported
# use Rube qw(slurp getkwd setkwd); etc to import individually
# use Rube ':all';      to import all
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(slurp slrp spew
                                   find_unique look_for search_for
                                   txt2hsh getkwd getkwds setkwd 
                                   csvprintln
                                   fwdslash bakslash
                                 ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();

# provide one or more filenames or glob patterns, this will read everything in
# and return it either as an array of lines, or one whole blob of text
sub slurp {
  my @lns;
  for (@_) {
    if (-r) {
      open FILE, $_;
      push @lns, (<FILE>);
      close FILE;
    } else {
      my @files = glob;
      for (@files) {
        open FILE, $_;
        push @lns, (<FILE>);
        close FILE;
      }
    }
  }

  return wantarray ? @lns : (join '', @lns);
}


# this is just like slurp, but shorter. it omits #-comments and blank lines and
# trailing whitespace
sub slrp {
  my @lns;
  for (@_) {
    if (-r) {
      open FILE, $_;
      for (<FILE>) {
        s!\#.*!!;          # strip comments
        s!\s+$!!;          # strip trailing whitespace
        next unless /\S/;  # skip blanks
        push @lns, $_;
      }
      close FILE;
    } else {
      my   @files = glob;
      for (@files) {
        open FILE, $_;
        for (<FILE>) {
          s!\#.*!!;          # strip comments
          s!\s+$!!;          # strip trailing whitespace
          next unless /\S/;  # skip blanks
          push @lns, $_;
        }
        close FILE;
      }
    }
  }

  return wantarray ? @lns : (join '', @lns);
}

sub spew {
  my $fname = shift;
  open OUT, ">$fname" or croak "Can't write to '$fname'";
  for (@_) { print OUT }
  close OUT;
}

sub swap_extension {
  my $fname  = shift;
  my $oldext = shift;
  my $newext = shift;
  $fname =~ s!$oldext!$newext!;
  return $fname;
}

# provide one or more patterns (i.e. ("*.gpf", "*.atf")) and this will try to
# find the unique file that matches each pattern. Die if 0 or 2+ match any pattern
sub find_unique {
  my @rets = ();
  for my $pat (@_) {
    my @files = glob $pat;
    if (@files == 1) {
      push @rets, $files[0];
    } elsif (@files==0) {
      croak "find_unique: Pattern matched no files: '$pat'";
    } else {
      croak "find_unique: Pattern matched more than one file: '$pat'";
    }
  }
  return wantarray ? @rets 
                   : (@rets > 1 ? join "\n", @rets : $rets[0]);
}

# like find_unique, but die only if multiple matches are found; if none are
# found return ''. Only accepts one pattern
sub look_for {
  my $pat = shift;
  my @files = glob $pat;
  if (@files == 1 && -r $files[0]) {
    return $files[0];
  }
  if (@files==0) {
    return '';
  }
  # else @files > 1
  croak "find_unique: Pattern matched more than one file: '$pat'";
}

# Search multiple places for multiple files. Just pass in an array, anything
# which is -d will be a place to look, anything else will be a filename 
sub search_for {
  my (@dirs, @files);
  for (@_) {
    if (-d) { push @dirs,  $_ }
    else    { push @files, $_ }
  }
  for my $d (@dirs)  {
  for my $f (@files) {
    my $file = "$d/$f";
    if (-r $file) { return $file }
  }}
}

# Given a readable path, slurp it in, otherwise act on input array
# Parse a keyword/value file into a hash. Repeated keywords overwritten.
sub txt2hsh {
  my $arg = shift;
  my @lns;
  if (-r $arg) { @lns = slurp($arg) }
  else         { @lns = split /\n/, $arg  }
  my %hsh = ();
  for (@lns) {
    s!^\s+!!;
    next unless $_;
    my @ary = split;
    my $key = shift @ary;
    $hsh{$key} = join ' ', @ary;
  }

  return %hsh;
}

# Pass in a keyword, and keyword/value text (lines), fetch out the value  
sub getkwd {
  my $kw = shift;
  for (@_) {
    if (/\b$kw\s+(.*)/) {
      return $1;
    }
  }
}

# Pass in a keyword, and keyword/value lines, fetch out values for multiple
# occurrences of that keyword
sub getkwds {
  my $kw = shift;
  my @vals = ();
  for (@_) {
    if (/\b$kw\s+(.*)/) {
      push @vals, $1;
    }
  }
  return @vals;
}
  

# Pass in a keyword, and keyword/value text (lines), substitute a value
sub setkwd {
  my $kw = shift;
  my $nv = shift;
  for (@_) {
    if (s!\b$kw\s+.*!$kw $nv!) {
      return;
    }
  }
}

# Print an array on a line with comma separators
sub csvprintln {
  print (join ',', @_, "\n");
}

# conversion between backslashes and forward slashes
sub fwdslash { for (@_) { s!\\!/!g } }
sub bakslash { for (@_) { s!/!\\!g } }



sub datestr {
  my ($s,$mi,$h,$d,$mo,$y) = localtime();
  $y  += 1900;
  $mo += 1;
  return sprintf "%4d-%02d-%02d %02d:%02d:%02d ", $y,$mo,$d, $h,$mi,$s;
}

1;
