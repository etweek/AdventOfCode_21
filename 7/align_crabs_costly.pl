#!/opt/loca/bin/perl
use warnings;
use strict;

use List::Util qw(max min);

use Data::Dumper;

#gather input
my $line = <STDIN>;
my @positions=split(/,/,$line);

print "There are ",scalar(@positions)," crabs in the sea: ",join(",",@positions),"\n";

sub calculate_progression{
  my $num = shift;
  my $ini = shift;
  my $add = shift;

  my $res = ($num/2)*(2*$ini + ($num-1)*$add);
  return $res;
}

sub calculate_cost{
  my $target = shift;
  my $position_ref = shift;
  my @pos = @{$position_ref};

  print "Calculating for position $target...";
  my $sum = 0;
  for my $crab (@pos){
    if($crab > $target){
      $sum += calculate_progression($crab-$target,1,1);
    }
    else{
      $sum += calculate_progression($target-$crab,1,1);
    }
  }
  print "$sum\n";
  return $sum
}

my $max = max(@positions);
my $min = min(@positions);

print "Need to search between $min and $max\n";

my @costs;
for (my $target = $min; $target <= $max; $target++){
  push(@costs, calculate_cost($target, \@positions));
}

my $least = min(@costs);

print "Minimum cost is $least\n";

