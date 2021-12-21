#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use Hash::PriorityQueue;

use Data::Dumper;

#gather input
my @inputmap;

my $numrows=0;
my $numcols=0;
while(my $line = <STDIN>){
  chomp($line);
  my @row=split(//, $line);
  push (@inputmap, \@row);
  $numcols=scalar(@row);
}
$numrows=scalar(@inputmap);

print "The cavern is $numrows by $numcols\n";
# multiply it up
my @map=@inputmap;
for(my $k_i=0; $k_i<5; $k_i++){
  for(my $k_j=0; $k_j<5; $k_j++){
    if($k_i==0 && $k_j==0){
      next;
    }
    my $i_offset=$k_i*$numrows;
    my $j_offset=$k_j*$numcols;
  
    for(my $i=0; $i<$numrows; $i++){
      for(my $j=0; $j<$numcols; $j++){
        my $value = $map[$i][$j]+$k_i+$k_j;
        if($value > 9){
          $value -= 9;
        }
        $map[$i_offset+$i][$j_offset+$j]=$value;
      }
    }
  }
}

$numrows = scalar(@map);
$numcols = scalar(@{$map[0]});
# open my $check_FH,"<miniinput_full";
# my @check;
# while(my $line = <$check_FH>){
#   chomp($line);
#   my @row=split(//, $line);
#   push (@check, \@row);
# }
# for my $x (0 .. $numrows-1) {
#   for my $y (0 .. $numcols-1) {
#     die "failed at $x:$y\n" unless $map[$x][$y] == $check[$x][$y];
#     }
# }

print "The cavern is $numrows by $numcols\n";

my $visited;
my $unvisited = Hash::PriorityQueue->new();
my $cost;
for(my $i=0; $i<$numrows; $i++){
  for(my $j=0; $j<$numcols; $j++){
    # Add this to the unvisited set with "infinite" distance
    my $key = sprintf("%d:%d",$i,$j);
    $unvisited->insert($key,10*$numrows*$numcols);
    $cost->{$key} = $map[$i][$j];
  }
}
# initialise starting node
$unvisited->update("0:0",0);

sub calculate_node{
  my $key = shift;
  my ($i,$j)=map {int} split(/:/,$key);
  print "checking neighbours of $i,$j\n";

  my $path_cost = $unvisited->{$key};
  for(my $n_i=($i>0?$i-1:$i);   $n_i <= ($i==($numrows-1)?$i:$i+1); $n_i++){
    for(my $n_j=($j>0?$j-1:$j); $n_j <= ($j==($numcols-1)?$j:$j+1); $n_j++){
      my $n_key = sprintf("%d:%d",$n_i,$n_j);
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
  return $unvisited->pop();
}

calculate_node("0:0");
my $last = sprintf("%d:%d",$numrows-1,$numcols-1);
my $current = cheapest_node();
while($current ne $last){
  #print "Next node to check is $current: ";
  calculate_node($current);
  $current = cheapest_node();
}
calculate_node($last);
print "Cost to last: ",$visited->{$last},"\n";
