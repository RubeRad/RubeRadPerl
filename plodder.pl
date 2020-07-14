#! /usr/bin/perl

# DEPENDENCIES:
# sudo apt-get install xsltproc



use Getopt::Std;
use FindBin;
use lib "$FindBin::Bin";
use HTTP::Lite;
use LWP::UserAgent;

%opt = ();
getopts('htr0n:fd:b:', \%opt);

$usage .= "plodder.pl -t -r -0 -n # -f [feed]\n";
$usage .= "  -h    help (this message)\n";
$usage .= "  -t    test (no download)\n";
$usage .= "  -r    reverse order (from oldest)\n";
$usage .= "  -0    don't download (but put in history)\n";
$usage .= "  -n N  number of mp3 to download\n";
$usage .= "  -f    force (even if already in history)\n";
$usage .= "  -d dir root directory to copy downloads\n";
$usage .= "  -b bytes convert mp3 to a different bitrate\n";

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
    $pat = shift @ary;
    @dirs = glob($pat);
    for (@dirs) { if (-d) { $dir = $_; last } }
    next;
  } elsif ($cmd eq 'FEED') {
    $lbl = shift @ary;
    $rss = shift @ary;
    $rssOf{$lbl} = $rss;
  }
}
close CFG;

if ($opt{d}) {
  $dir = $opt{d};
}

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
    @urls = ($html =~ /enclosure.*?url\=\"(.*\.mp3)/g);
  } elsif ($rssOf{$lbl} =~ /https/){
      $ua = LWP::UserAgent->new;
      $res = $ua->get($rssOf{$lbl});
      if ($res->is_success) {
	  $html = $res->decoded_content;
	  @urls = ($html =~ /enclosure.*?url\=\"(.*\.mp3)/g);
      }
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
    $nam =~ s!.*\%2F!!;
    $path = "$dir/$lbl/$nam";
    $dupctr = 0;
    while ($nam eq 'audio.mp3' && -f $path) {
	$dupctr++;
	$path = "$dir/$lbl/$nam$ctr.mp3";
    }
    
    if (! exists $hsh{$nam}) {
      $hsh{$nam}++;
      push @urls, $url;
      $fname{$url} = $path;
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
    $fil = $fname{$url};
    $hst = "$lbl $url";
    next if $hstHsh{$hst} && !$opt{f};

    print "\t$url --> $fil\n";
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

    if ($opt{b}) {
      $b = $opt{b};
      ($bfil = $fil) =~ s!.mp3!_$b.mp3!;
      $cmd = qq(lame -b $opt{b} "$fil" "$bfil"\n);
      print  $cmd;
      system $cmd;
      unlink $fil;
    }
  }

}
