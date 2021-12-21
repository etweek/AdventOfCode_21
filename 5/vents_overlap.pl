#!/opt/loca/bin/perl
use warnings;
use strict;

use Storable qw(dclone);

use Data::Dumper;

#gather input
my @vents=();
while(<STDIN>){
  chomp($_);
  if(length($_) > 1){
    my @points = split(/ -> /,$_);
    push(@vents, \@points);
    
  }
}

# process the points, no diagonals
my %hits;
for my $entry(@vents){
  my ($start, $end) = @{$entry};
  my ($x1, $y1) = split(/,/,$start);
  my ($x2, $y2) = split(/,/,$end);
  #remove diagonals
  if($x1 == $x2){
    printf "%03d,%03d to %03d,%03d is vertical\n",$x1,$y1,$x2,$y2;
    if($y1 > $y2){
      ($y1, $y2) = ($y2, $y1);
    }
    # variation in y
    for my $y ($y1 .. $y2){
      my $point=sprintf("%03d%03d",$x1,$y);
#      print "vert hit $point\n";
      $hits{$point}+=1;
    }
  }
  elsif($y1 == $y2){
    printf "%03d,%03d to %03d,%03d is horizontal\n",$x1,$y1,$x2,$y2;
    if($x1 > $x2){
      ($x1, $x2) = ($x2, $x1);
    }
    # variation in x
    for my $x ($x1 .. $x2){
      my $point=sprintf("%03d%03d",$x,$y1);
#      print "horiz hit $point\n";
      $hits{$point}+=1;
    }
  }
  else{
    printf "%03d,%03d to %03d,%03d is diagonal\n",$x1,$y1,$x2,$y2;
    my $xdiff = $x2-$x1;
    my $xinc=1;
    my $ydiff = $y2-$y1;
    my $yinc=1;
    if($y1 > $y2){
      $ydiff = $y1-$y2;
      $yinc=-1;
    }
    if($x1 > $x2){
      $xdiff=$x1-$x2;
      $xinc=-1;
    }
    if($xdiff != $ydiff){
      die "%03d,%03d to %03d,%03d violates 45 degree assertion\n";
    }
    for(my $delta=0; $delta <= $xdiff; $delta++){
      my $point=sprintf("%03d%03d",$x1+($xinc*$delta),$y1+($yinc*$delta));
#      print "diag hit $point\n";
      $hits{$point}+=1;
    }      
  }    
}
#print Dumper(%hits);
my $count=0;
for my $point (keys(%hits)){
#  print "$point: ",$hits{$point},"\n";
  if($hits{$point} > 1){
    $count++;
  }
}
print "\nThere were $count points with more than one vent\n";
