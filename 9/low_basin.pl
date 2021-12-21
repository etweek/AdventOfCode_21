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

my %visited;
sub explore{
  my $r = shift;
  my $c = shift;
  #prune
  my $key = sprintf("%03d,%03d",$r,$c);
  if($visited{$key}){
    return (-1,-1,-1);
  }
  $visited{$key}=1;
  my $current = $rows[$r][$c];
  #find the smallest neighbour
  my $nr = $r;
  my $nc = $c;
  if($r-1 >= 0 && $rows[$r-1][$c] < $current){
    $nr = $r-1;
    $current = $rows[$r-1][$c];
  }
  if($c-1 >= 0 && $rows[$r][$c-1] < $current){
    $nc = $c-1;
    $current = $rows[$r][$c-1];
  }
  if($r-1 >= 0 && $c-1 >= 0 && $rows[$r-1][$c-1] < $current){
    $nr = $r-1;
    $nc = $c-1;
    $current = $rows[$r-1][$c-1];
  }
  if($r+1 < $numrows && $rows[$r+1][$c] < $current){
    $nr = $r+1;
    $current = $rows[$r+1][$c];
  }
  if($c+1 < $numcols && $rows[$r][$c+1] < $current){
    $nc = $c+1;
    $current = $rows[$r][$c+1];
  }
  if($r+1 < $numrows && $c+1 < $numcols && $rows[$r+1][$c+1] < $current){
    $nr = $r+1;
    $nc = $c+1;
    $current = $rows[$r+1][$c+1];
  }
  if($r+1 < $numrows && $c-1 >= 0 && $rows[$r+1][$c-1] < $current){
    $nr = $r+1;
    $nc = $c-1;
    $current = $rows[$r+1][$c-1];
  }
  if($r-1 >= 0 && $c+1 < $numcols && $rows[$r-1][$c+1] < $current){
    $nr = $r-1;
    $nc = $c+1;
    $current = $rows[$r-1][$c+1];
  }

  if($nr != $r || $nc != $c){
    ($current,$nr,$nc) = explore($nr, $nc);
  }
      
  return ($current,$nr,$nc);
}

my %lows;
my $i=0;
my $j=0;
for($i=0;$i<$numrows;$i++){
  for($j=0;$j<$numcols;$j++){
    my ($val, $row, $col) = explore($i,$j);
    if($val > -1){
      my $key = sprintf("%03d,%03d",$row,$col);
      $lows{$key}=$val;
    }
  }
}

# OK, now time to find the basins from those points
my %checked;

sub explore_basin{
  my $r = shift;
  my $c = shift;
  # check for invalid values
  if($r<0 || $r >= $numrows){
    return 0;
  }
  if($c<0 || $c >= $numcols){
    return 0;
  }
  #prune
  my $key = sprintf("%03d,%03d",$r,$c);
  if($checked{$key}){
    return 0;
  }
  $checked{$key}=1;
  my $current = $rows[$r][$c];
  # exit condition
  if($current == 9){
    return 0;
  }
  #find the smallest neighbour
  print "($r,$c)=$current,";
  return 1 + 
      explore_basin($r-1,$c) +
      explore_basin($r,$c-1) +
      explore_basin($r,$c+1) +
      explore_basin($r+1,$c);
  # don't go diagonally
  # return 1 + explore_basin($r-1,$c-1) +
  #     explore_basin($r-1,$c) +
  #     explore_basin($r-1,$c+1) +
  #     explore_basin($r,$c-1) +
  #     explore_basin($r,$c+1) +
  #     explore_basin($r+1,$c-1) +
  #     explore_basin($r+1,$c) +
  #     explore_basin($r+1,$c+1);
  
}

my @sizes;
for my $key (keys(%lows)){
  my ($row,$col)=split(/,/,$key);
  $row = int($row);
  $col = int($col);
  print "$row,$col --> ";
  my $size = explore_basin($row,$col);
  push(@sizes,$size);
  print " ==> $size\n";
}
print Dumper(sort { $b <=> $a } @sizes);
my $total=1;    
my $count=0;
for my $size (sort { $b <=> $a } @sizes){
  if($count < 3){
    $total *= $size;
  }
  $count++;
}
print "Grand total = $total\n";
