#! /usr/bin/perl

# DEPENDENCIES:
# sudo apt-get install xsltproc



use Getopt::Std;
use FindBin;
use lib "$FindBin::Bin";
use HTTP::Lite;

%opt = ();
getopts('htr0n:f', \%opt);

$usage .= "plodder.pl -t -r -0 -n # -f [feed]\n";
$usage .= "  -h    help (this message)\n";
$usage .= "  -t    test (no download)\n";
$usage .= "  -r    reverse order (from oldest)\n";
$usage .= "  -0    don't download (but put in history)\n";
$usage .= "  -n N  number of mp3 to download\n";
$usage .= "  -f    force (even if already in history)\n";
if ($opt{h}) {
  print $usage;
  exit;
}

if ($ENV{PLODDER_CFG} && -r $ENV{PLODDER_CFG}) {
  $CFG = $ENV{PLODDER_CFG};
} elsif (-r "$ENV{HOME}/.plodder.cfg") {
  $CFG = "$ENV{HOME}/.plodder.cfg";
} elsif (-r "$FindBin::Bin/.plodder.cfg") {
  $CFG = "$FindBin::Bin/.plodder.cfg";
} else {
  die "Can't determine/read PLODDER_CFG\n";
}

($HST = $CFG) =~ s!\.cfg$!.hst!;

open CFG;
while (<CFG>) {
  s!\#.*!!;
  next unless /\S/;
  @ary = split;
  $cmd = shift @ary;
  if      ($cmd eq 'ROOT') {
    $dir = shift @ary;
    #while ($dir =~ s/\\$//) {
    while (@ary > 0) {
      $dir .= (" ".(shift @ary));
    }
    next;
  } elsif ($cmd eq 'FEED') {
    $lbl = shift @ary;
    $rss = shift @ary;
    $rssOf{$lbl} = $rss;
  }
}
close CFG;

die "ROOT '$dir' doesn't exist!" unless -d $dir or $opt{t} or $opt{0};

open HST;
while (<HST>) {
  s!\#.*!!;
  next unless /\S/;
  chomp;
  $hstHsh{$_}++;
}
close HST;

if (@ARGV) {
  @lbls = @ARGV;
} else {
  @lbls = sort keys %rssOf;
}

open HST, ">>$HST";

# Copied from CPAN: HTTP::Lite
# Write the data to the filehandle $cbargs
sub savetofile {
  my ($self,$phase,$dataref,$cbargs) = @_;
  print $cbargs $$dataref;
  return undef;
}


for $lbl (@lbls) {
  print "$lbl\n";

  if (! -d "$dir/$lbl") {
    mkdir "$dir/$lbl";
  }

  #$http_lite = 1;
  if ($http_lite) {
    $http = new HTTP::Lite;
    $req = $http->request($rssOf{$lbl});
    $html = $http->body();
    #print "$html\n\n";
    @urls = ($html =~ /enclosure.*?url\=\"(.*\.mp3)\"/g);
  } else {
    $cmd = qq(xsltproc $FindBin::Bin/parse_enclosure.xsl "$rssOf{$lbl}");
    @urls = `$cmd`;
    chomp @urls;
  }

  @allurls = @urls;
  @urls = ();
  %hsh = ();
  for $url (@allurls) {
    next if $url =~ /\.jpg/;
    $url =~ s!\?.*!!;
    ($nam=$url) =~ s!.*\/!!;
    if ($nam =~ /ttr05/) {
      $stophere = 1;
    }
    if (exists $hstHsh{"$lbl $url"}) {
      next;
    }
    if (! exists $hsh{$nam}) {
      $hsh{$nam}++;
      push @urls, $url;
    }
  }

  $n = $opt{n} || @urls;
  @urls = reverse @urls unless $opt{r};
  #if ($opt{r}) {
    while (@urls > $n) { pop @urls }
  #} else {
    #while (@urls > $n) { pop   @urls }
  #}
  for $url (@urls) {
    ($nam=$url) =~ s!.*\/!!;
    $fil = "$dir/$lbl/$nam";
    $hst = "$lbl $url";
    next if $hstHsh{$hst} && !$opt{f};

    print "\t$fil\n";
    next if $opt{t};

    if ($opt{0}) {
      print HST "$hst\n";
      next;
    }

    # Download it!
    $cmd = qq(wget -t 10 -c -q -O "$fil" "$url");
    #print "$cmd\n";
    system $cmd;
    print HST "$hst\n";
  }

}
