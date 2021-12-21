#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my @points;
my @folds;

while(my $line = <STDIN>){
  chomp($line);
  if(index($line, ",") != -1){
    my @point =split(/,/,$line);
  
    push(@points,\@point);
  }
  elsif($line =~ /fold along (.)=(.+)$/){
    print "Fold on $1 at $2\n";
    my @fold=($1,$2);
    push(@folds,\@fold);
  }
}
my $numpoints=scalar(@points);
my $numfolds=scalar(@folds);

print "There are $numpoints points and $numfolds folds defined\n";

sub print_paper{
  my $r_points = shift;
  my @a_points = @{$r_points};

  my $max_x = 0;
  my $max_y = 0;
  for my $r_point (@a_points){
    my ($x,$y) = @{$r_point};
    if($x>$max_x){
      $max_x = $x;
    }
    if($y>$max_y){
      $max_y = $y;
    }
  }
  my @paper;
  # initialize blank paper
  for my $i ( 0 .. $max_y ) {
    for my $j ( 0 .. $max_x ) {
      $paper[$i][$j]=".";
    }
  }
  # add points
  for my $r_point (@a_points){
    my ($x,$y) = @{$r_point};
    $paper[$y][$x]="#";
  }
  # finally print it
  for my $row (@paper){
    my @a=@{$row};
    print @a,"\n";
  }
}

sub array_equals{
  my $a = shift;
  my $b = shift;
  my @arrA = @{$a};
  my @arrB = @{$b};
  my $lenA = scalar(@arrA);
  my $lenB = scalar(@arrB);
  if($lenA != $lenB){
    return 0;
  }
  else{
    for(my $i = 0;$i < $lenA; $i++){
      if($arrA[$i] ne $arrB[$i]){
        return 0;
      }
    }
    return 1;
  }
}
 
sub array_contains_array{
  my $array_ref = shift;
  my $element_ref = shift;
  my @array = @{$array_ref};
  for my $element (@array){
    if(array_equals($element,$element_ref)){
      return 1;
    }
  }
  return 0;
}
  
  
sub fold_y{
  my $r_points = shift;
  my @a_points = @{$r_points};
  my $fold = shift;
  my @a_result;
  
  for my $r_point (@a_points){
    my ($x,$y) = @{$r_point};
    if($y == $fold){
      die "invalid fold at $fold (points at $x,$y)\n";
    }
    elsif($y > $fold){
      # fold it
      $y = $fold-($y-$fold);
    }
    my @newpoint=($x,$y);
    if(!array_contains_array(\@a_result, \@newpoint)){
      push(@a_result, \@newpoint);
    }
  }
  return \@a_result;


}
sub fold_x{
  my $r_points = shift;
  my @a_points = @{$r_points};
  my $fold = shift;
  my @a_result;
  
  for my $r_point (@a_points){
    my ($x,$y) = @{$r_point};
    if($x == $fold){
      die "invalid fold at $fold (points at $x,$y)\n";
    }
    elsif($x > $fold){
      # fold it
      $x = $fold-($x-$fold);
    }
    my @newpoint=($x,$y);
    if(!array_contains_array(\@a_result, \@newpoint)){
      push(@a_result, \@newpoint);
    }
  }
  return \@a_result;


}

print_paper(\@points);
my $fold = shift @folds;
my ($axis, $distance) = @{$fold};
if($axis eq "x"){
  @points = @{fold_x(\@points, $distance)};
}
elsif($axis eq "y"){
  @points = @{fold_y(\@points, $distance)};
}
else{
  die "weird axis $axis\n";
}
print "\nafter fold:\n";
print_paper(\@points);
print "There are ",scalar(@points)," points left\n";
