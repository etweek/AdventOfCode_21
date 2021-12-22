#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
use Data::Compare;

my @instructions;
my ($smallest_x, $smallest_y, $smallest_z) =(0,0,0);
my ($largest_x, $largest_y, $largest_z) =(0,0,0);


while(my $line = <STDIN>){
  my ($instruction, $startx, $endx, $starty, $endy, $startz, $endz);
  if($line =~ /([\w]+) x=([\d-]+)\.\.([\d-]+),y=([\d-]+)\.\.([\d-]+),z=([\d-]+)\.\.([\d-]+)/){
    ($instruction, $startx, $endx, $starty, $endy, $startz, $endz) = ($1,$2,$3,$4,$5,$6,$7);
  }
  else{
    die "Failed to parse $line\n";
  }
  my $entry;
  $entry->{"instruction"}=($instruction eq "on")?1:0;
  # we've been told to ignore these
  next if(($startx < -50 && $endx < -50)||
          ($startx > 50 && $endx > 50)||
          ($starty < -50 && $endy < -50)||
          ($starty > 50 && $endy > 50)||
          ($startz < -50 && $endz < -50)||
          ($startz > 50 && $endz > 50));
  if($startx > $endx){
    my $temp=$startx;
    $startx=$endx;
    $endx=$temp;
  }
  if($starty > $endy){
    my $temp=$starty;
    $starty=$endy;
    $endy=$temp;
  }
  if($startz > $endz){
    my $temp=$startz;
    $startz=$endz;
    $endz=$temp;
  }
  if($startx < $smallest_x){
    $smallest_x = $startx;
  }
  if($starty < $smallest_y){
    $smallest_y = $starty;
  }
  if($startz < $smallest_z){
    $smallest_z = $startz;
  }
  if($endx > $largest_x){
    $largest_x = $endx;
  }
  if($endy > $largest_y){
    $largest_y = $endy;
  }
  if($endz > $largest_z){
    $largest_z = $endz;
  }
  
  $entry->{"x1"}=$startx;
  $entry->{"x2"}=$endx;
  $entry->{"y1"}=$starty;
  $entry->{"y2"}=$endy;
  $entry->{"z1"}=$startz;
  $entry->{"z2"}=$endz;
  push(@instructions, $entry);
};

print scalar(@instructions)," instructions for within the ($smallest_x, $smallest_y, $smallest_z):($largest_x, $largest_y, $largest_z) area\n";
#print Dumper(@instructions)

my %cube;
for my $instruction (@instructions){
  for my $x ($instruction->{"x1"}..$instruction->{"x2"}){
    for my $y ($instruction->{"y1"}..$instruction->{"y2"}){
      for my $z ($instruction->{"z1"}..$instruction->{"z2"}){
        $cube{$x.",".$y.",".$z}=$instruction->{"instruction"};
      }
    }
  }
}

my $sum = 0;
{
  my $v;
  $sum += $v while (undef, $v) = each %cube;
}
print "Cognito ergo $sum\n";

#print Dumper(%cube);
