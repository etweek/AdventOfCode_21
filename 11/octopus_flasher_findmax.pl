#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my @rows;
my $numrows;
my $numcols;
while(my $line = <STDIN>){
  chomp($line);
  my @columns = split(//, $line);
  $numcols= scalar(@columns);
  push(@rows,\@columns);
}
$numrows=scalar(@rows);

print "There are $numrows x $numcols octopuses\n";

sub tick{
  my $flashes = 0;
  # loop over all the octopuses increasing their value
  for(my $r=0; $r < $numrows; $r++){
    for(my $c=0; $c < $numcols; $c++){
      $rows[$r][$c]++;
    }
  }

  # loop over all the octopuses checking for a flash
  my $flash = 0;
  my $round = 0;
  while($round==0 || $flash > 0){
    $round++;
    $flash=0;
    for(my $r=0; $r < $numrows; $r++){
      for(my $c=0; $c < $numcols; $c++){
        if($rows[$r][$c] > 9){
          print "$r:$c=$rows[$r][$c] ";
          $flash++;
          #increase the others
          if($r>0 && $c>0){
            # check it hasn't flashed already
            $rows[$r-1][$c-1]++ unless $rows[$r-1][$c-1]==0;
          }
          if($r>0){
            $rows[$r-1][$c]++ unless $rows[$r-1][$c]==0;
          }
          if($r>0 && $c<$numcols-1){
            $rows[$r-1][$c+1]++ unless $rows[$r-1][$c+1]==0;
          }
          if($c>0){
            $rows[$r][$c-1]++ unless $rows[$r][$c-1]==0;
          }
          if($c<$numcols-1){
            $rows[$r][$c+1]++ unless $rows[$r][$c+1]==0;
          }
          if($r<$numrows-1 && $c>0){
            $rows[$r+1][$c-1]++ unless $rows[$r+1][$c-1]==0;
          }
          if($r<$numrows-1){
            $rows[$r+1][$c]++ unless $rows[$r+1][$c]==0;
          }
          if($r<$numrows-1 && $c<$numcols-1){
            $rows[$r+1][$c+1]++ unless $rows[$r+1][$c+1]==0;
          }
          $rows[$r][$c]=0;
        }
      }
    }
    print "\nAfter round $round, $flash flashes\n";
    $flashes += $flash;
  }
  return $flashes;
}

sub print_state{
  for(my $r=0; $r < $numrows; $r++){
    for(my $c=0; $c < $numcols; $c++){
      print $rows[$r][$c];
    }
    print "\n";
  }
}

print "starting:\n";
print_state();
my $tick_flashes = tick();
my $tick = 1;
while($tick_flashes < 100){
  $tick_flashes = tick();
  $tick++;
}
print_state();
print "Reached full flash in $tick ticks\n";

