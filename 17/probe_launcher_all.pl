#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my $input = <STDIN>;

my ($xmin, $xmax, $ymin, $ymax);
if($input =~ /target area: x=([\d-]+)\.\.([\d-]+), y=([\d-]+)\.\.([\d-]+)/){
  $xmin = $1;
  $xmax = $2;
  $ymin = $3;
  $ymax = $4;
}

print "Target x between $xmin and $xmax and y between $ymin and $ymax\n";
    
my $drag = 1;
my $gravity = 1;

sub shoot{
  my $x_vel = shift;
  my $y_vel = shift;

  my $y_max=-99;
  my $x_pos=0;
  my $y_pos=0;
  #print "$x_pos,$y_pos...";
  while($y_pos >= $ymin && $x_pos<=$xmax){
    # once it's fallen below the minimum y there's no chance
    $x_pos += $x_vel;
    $y_pos += $y_vel;
    if($y_pos > $y_max){
      $y_max = $y_pos;
    }
    #print "$x_pos,$y_pos...";
    if($x_vel > 0){
      $x_vel -= $drag;
    }
    elsif($x_vel < 0){
      $x_vel += $drag;
    }
    $y_vel -= $gravity;
    if($xmin <= $x_pos && $x_pos <= $xmax &&
       $ymin <= $y_pos && $y_pos <= $ymax){
      #print "BOOM\n";
      return (1,$y_max);
    }
  }
  #print "miss\n";
  return (0,$y_max);
}

# calculate the slowest to get to xmin
sub get_max{
  my $x_vel = shift;
  my $x_pos = 0;
  my $steps=0;
  print "$x_pos...";
  while($x_vel != 0){
    # once it's fallen below the minimum y there's no chance
    $x_pos += $x_vel;
    $steps++;
    print "$x_pos...";
    if($x_vel > 0){
      $x_vel -= $drag;
    }
    elsif($x_vel < 0){
      $x_vel += $drag;
    }
  }
  return ($x_pos,$steps);
}

sub get_distance{
  my $velocity=shift;
  my $steps = shift;
  my $distance = 0;
  while($steps > 0){
    $distance += $velocity--;
    #print "$distance ";
    $steps--;
  }
  return $distance;
}

my $x_vel = 0;
my $x_pos;
my $steps;
do{
  $x_vel++;
  ($x_pos, $steps) = get_max($x_vel);
  print "; ";
}
until($x_pos>=$xmin);
my $x_min_vel = $x_vel;

# The absolute max x is the one that almost shoots out of the target zone on the first shot
my $x_max_vel = $xmax;


print "Slowest x = $x_min_vel, got to $x_pos after $steps steps, though could go all the way to $x_max_vel\n";
# figure out the y to hit.
# the largest seems to be one less than the max below.
my $y_max_vel = ($ymin*-1) - 1;
print "Trying ($x_min_vel, $y_max_vel)\n";
my ($hit, $y_max_pos) = shoot($x_min_vel, $y_max_vel);
if($hit){
  print "Hit with $x_min_vel,$y_max_vel, getting as high as $y_max_pos\n";
}
# the smallest will be max below too...
my $y_min_vel = $ymin;

# try em
my $count = 0;
for my $x_vel ($x_min_vel .. $x_max_vel){
  for my $y_vel ($y_min_vel .. $y_max_vel){
    my ($hit, $y_max_pos) = shoot($x_vel, $y_vel);
    if($hit){
      $count++;
      print "Hit with $x_vel,$y_vel, getting as high as $y_max_pos\n";
    }
  }
}
print "hit with $count attempts\n";
