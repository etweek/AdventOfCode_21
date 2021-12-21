#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my @map;

my $numrows=0;
my $numcols=0;
while(my $line = <STDIN>){
  chomp($line);
  my @row=split(//, $line);
  push (@map, \@row);
  $numcols=scalar(@row);
}
$numrows=scalar(@map);

print "The cavern is $numrows by $numcols\n";

my $visited;
my $unvisited;
my $cost;
for(my $i=0; $i<$numrows; $i++){
  for(my $j=0; $j<$numcols; $j++){
    # Add this to the unvisited set with "infinite" distance
    my $key = sprintf("%02d:%02d",$i,$j);
    $unvisited->{$key} = 10*100*100;
    $cost->{$key} = $map[$i][$j];
  }
}
# initialise starting node
$unvisited->{"00:00"}=0;

sub calculate_node{
  my $key = shift;
  my ($i,$j)=map {int} split(/:/,$key);
  print "checking neighbours of $i,$j\n";

  my $path_cost = $unvisited->{$key};
  for(my $n_i=($i>0?$i-1:$i);   $n_i <= ($i==($numrows-1)?$i:$i+1); $n_i++){
    for(my $n_j=($j>0?$j-1:$j); $n_j <= ($j==($numcols-1)?$j:$j+1); $n_j++){
      my $n_key = sprintf("%02d:%02d",$n_i,$n_j);
      #ignore self
      next unless $key ne $n_key;
      #ignore diagonals
      next unless $n_i == $i || $n_j == $j;
      #ignore visited nodes
      next unless defined($unvisited->{$n_key});
          
      #print "\tChecking $n_i,$n_j: ";
      my $current = $unvisited->{$n_key};
      if($current > $path_cost+$cost->{$n_key}){
        # shorter path found
        $unvisited->{$n_key} = $path_cost+$cost->{$n_key};
      }
      #print $unvisited->{$n_key},"\n";
    }
  }
  $visited->{$key} = $path_cost;
  delete $unvisited->{$key};
}

sub cheapest_node{
  my @keys = sort { $unvisited->{$a} <=> $unvisited->{$b} } keys(%$unvisited);
  return $keys[0];
}

calculate_node("00:00");
my $last = sprintf("%02d:%02d",$numrows-1,$numcols-1);
my $current = cheapest_node();
while($current ne $last){
  calculate_node($current);
  $current = cheapest_node();
}
calculate_node($last);
print "Cost to last: ",$visited->{$last},"\n";
