#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
$Data::Dumper::Indent=1;
use Data::Compare;

my $seafloor;
$seafloor->{"rows"}=();

while(my $line=<STDIN>){
  chomp($line);
  my @row = map {($_ eq '.')?undef:$_;} split(//, $line);
  push (@{$seafloor->{"rows"}}, \@row);
}

my $num_rows = scalar(@{$seafloor->{"rows"}});
my $num_cols = scalar(@{@{$seafloor->{"rows"}}[0]});
sub print_floor{
  my $floor = shift;
  for(my $i=0; $i < $num_rows; $i++){
    for(my $j=0; $j < $num_cols; $j++){
      if(!defined($floor->{"rows"}->[$i]->[$j])){
        print '.';
      }
      else{
        print $floor->{"rows"}->[$i]->[$j];
      }
    }
    print "\n";
  }
}

sub east{
  my $floor = shift;
  my $output;
  $output->{"moves"}=0;
  $output->{"round"} = $floor->{"round"};
  $output->{"rows"}=();
  
  #east
  for(my $i=0; $i < $num_rows; $i++){
    for(my $j=0; $j < $num_cols; $j++){
      if(!defined($floor->{"rows"}->[$i]->[$j])){
        next;
      }
      else{
        if($floor->{"rows"}->[$i]->[$j] eq '>'){
          my $next_col = ($j+1) % $num_cols;
#          print "$j > $next_col\n";
          if(!defined($floor->{"rows"}->[$i]->[$next_col])){
            $output->{"rows"}->[$i]->[$next_col] = '>';
            $output->{"moves"}++;
          }
          else{
            #leave it where it was
            $output->{"rows"}->[$i]->[$j] = '>';
          }
        }
        else{
          #leave it where it was
          $output->{"rows"}->[$i]->[$j] = $floor->{"rows"}->[$i]->[$j];
        }
      }
    }
  }
  return $output;
}  

sub south{
  my $floor = shift;
  my $output;
  $output->{"rows"}=();
  $output->{"round"} = $floor->{"round"};
  $output->{"moves"} = $floor->{"moves"};

  #south-facing
  for(my $i=0; $i < $num_rows; $i++){
    for(my $j=0; $j < $num_cols; $j++){
      if(!defined($floor->{"rows"}->[$i]->[$j])){
        next;
      }
      else{
        if($floor->{"rows"}->[$i]->[$j] eq 'v'){
          my $next_row = ($i+1) % $num_rows;
          if(!defined($floor->{"rows"}->[$next_row]->[$j])){
            $output->{"rows"}->[$next_row]->[$j] = 'v';
          }
          else{
            #leave it where it was
            $output->{"rows"}->[$i]->[$j] = 'v';
          }
        }
        else{
          #leave it where it was
          $output->{"rows"}->[$i]->[$j] = $floor->{"rows"}->[$i]->[$j];
        }
      }
    }
  }

  return $output;
}  

sub tick{
  my $floor = shift;

  $floor->{"round"}++;
  $floor = east($floor);
  return south($floor);
}

print "$num_rows x $num_cols grid\n";
$seafloor->{"round"}=0;

do{
  $seafloor = tick($seafloor);
}
until($seafloor->{"moves"} == 0);

print "After ".$seafloor->{"round"}." round, ".$seafloor->{"moves"}."\n";
print_floor($seafloor);
