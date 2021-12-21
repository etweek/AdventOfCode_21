#!/opt/loca/bin/perl
use warnings;
use strict;

my $position=0;
my $depth=0;
my @input = <STDIN>;



my $i = 0;
while($i<=$#input){
  my ($action, $distance) = split(" ",$input[$i]);
  print("Action $action, Distance $distance\n");
  if("forward" eq $action) {
    $position += $distance;
  }
  elsif("down" eq $action) {
    $depth += $distance;
  }
  elsif("up" eq $action) {
    $depth -= $distance;
  }
  else{
    die "Don't understand $action\n";
  }
  $i++;
}

print "Position $position and depth $depth becomes ".($position*$depth)."\n";
