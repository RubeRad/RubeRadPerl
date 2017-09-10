package STATS;
use strict;



sub Stat {
  my $val = shift;
  my $lbl = shift; # optional

  my $aval = abs($val);
  if ($STATS::STAT->{$lbl}->{num} == 0) {
    $STATS::STAT->{$lbl}->{max}  = $val;
    $STATS::STAT->{$lbl}->{min}  = $val;
    $STATS::STAT->{$lbl}->{amax} = $aval;
    $STATS::STAT->{$lbl}->{amin} = $aval;
  }
  $STATS::STAT->{$lbl}->{num}  += 1;
  $STATS::STAT->{$lbl}->{sum}  += $val;
  $STATS::STAT->{$lbl}->{sumsq}+= $val*$val;
  $STATS::STAT->{$lbl}->{asum} += $aval;
  $STATS::STAT->{$lbl}->{avg}   = $STATS::STAT->{$lbl}->{sum}  / $STATS::STAT->{$lbl}->{num};
  $STATS::STAT->{$lbl}->{aavg}  = $STATS::STAT->{$lbl}->{asum} / $STATS::STAT->{$lbl}->{num};
  $STATS::STAT->{$lbl}->{max}   = $val  if $val  > $STATS::STAT->{$lbl}->{max};
  $STATS::STAT->{$lbl}->{amax}  = $aval if $aval > $STATS::STAT->{$lbl}->{amax};
  $STATS::STAT->{$lbl}->{min}   = $val  if $val  < $STATS::STAT->{$lbl}->{min};
  $STATS::STAT->{$lbl}->{amin}  = $aval if $aval < $STATS::STAT->{$lbl}->{amin};
}

sub Labels {
  return sort keys %$STATS::STAT;
}

sub Average {
  my $lbl = shift;
  my $n = $STATS::STAT->{$lbl}->{num};
  if ($n<=1) { return -1 }
  return $STATS::STAT->{$lbl}->{sum} / $n;
}

sub Variance {
  my $lbl = shift;
  my $sx  = $STATS::STAT->{$lbl}->{sum};
  my $sxx = $STATS::STAT->{$lbl}->{sumsq};
  my $n   = $STATS::STAT->{$lbl}->{num};
  if ($n<=1) { return -1 }
  return ($sxx - $sx*$sx/$n) / ($n-1.0);
}

sub StdDev {
  my $lbl = shift;
  return sqrt(Variance($lbl));
}

sub StatRpt {
  my $dlm = shift || "\t";

  my @cols = qw(avg aavg max amax min amin);
  my @lines;
  for my $lbl (sort keys %{$STATS::STAT}) {
    my @row = ($lbl, $STATS::STAT->{$lbl}->{num});
    for my $col (@cols) {
      push @row, (sprintf "%.2le", $STATS::STAT->{$lbl}->{$col});
    }
    push @lines, (join "\t", @row);
  }

  my @nonzero_lines = ();
  for my $line (@lines) {
    my @ary = (split /\t/, $line)[2,3,4,5,6,7];
    for my $num (@ary) {
      if ($num != 0.0) { 
        push @nonzero_lines, $line; last; 
      }
    }
  }

  if (@nonzero_lines > 0) {
    my $hdr = (join "\t", 'lbl', 'num', @cols);
    return (join "\n", $hdr, @nonzero_lines, '');
  } # else
  return '';
}


1;
