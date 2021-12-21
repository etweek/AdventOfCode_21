#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
use Data::Compare;

#gather input
my $algo_line = <STDIN>;
$algo_line =~ s/\./0/g;
$algo_line =~ s/\#/1/g;
my @algo = split(//,$algo_line);

my $image;
while(my $line = <STDIN>){
  chomp($line);
  next unless length($line)>3;
  $line =~ s/\./0/g;
  $line =~ s/\#/1/g;
  
  my @pixels = map { int } split(//,$line);
  push(@{$image->{"pixels"}}, \@pixels);
}

sub print_image{
  my $img = shift;

  for my $row (@{$img->{"pixels"}}){
    my $string = join("",@$row);
    $string =~ s/0/\./g;
    $string =~ s/1/\#/g;
    
    print $string,"\n";
  }
}

sub enhance_pixel{
  my $input = shift;
  my $x = shift;
  my $y = shift;
  my $infinite_pixel = shift;

  #print Dumper($input);
  my @pixels = @{$input->{"pixels"}};
  # my @sample  = (@{$pixels[$x-1]}[($y-1)..($y+1)], 
  #                @{$pixels[$x]}[($y-1)..($y+1)], 
  #                @{$pixels[$x+1]}[($y-1)..($y+1)]);
  my ($first, $second, $third);
  if($x == 0){
    ($first, $second, $third) = ($infinite_pixel, $infinite_pixel, $infinite_pixel);
  }
  else{
    $first  = ($y==0)?$infinite_pixel:$pixels[$x-1][$y-1];
    $second = $pixels[$x-1][$y];
    $third  = ($y==$#pixels)?$infinite_pixel:$pixels[$x-1][$y+1];
  }
  my $fourth = ($y==0)?$infinite_pixel:$pixels[$x][$y-1];
  my $fifth  = $pixels[$x][$y];
  my $sixth  = ($y==$#pixels)?$infinite_pixel:$pixels[$x][$y+1];
  my ($seventh, $eighth, $ninth);
  if($x == $#pixels){
    ($seventh, $eighth, $ninth) = ($infinite_pixel, $infinite_pixel, $infinite_pixel);
  }
  else{
    $seventh  = ($y==0)?$infinite_pixel:$pixels[$x+1][$y-1];
    $eighth = $pixels[$x+1][$y];
    $ninth  = ($y==$#pixels)?$infinite_pixel:$pixels[$x+1][$y+1];
  }
  my @sample = ($first, $second, $third, $fourth, $fifth, $sixth, $seventh, $eighth, $ninth);
  
  my $value = oct("0b".join("",@sample));
  
  return $algo[$value];
}

sub grow{
  my $input = shift;
  my @pixels = @{$input->{"pixels"}};

  
  my $size = scalar(@pixels)+2;
  my @blank1 = (0)x($size);
  my @blank2 = (0)x($size);
  my @result;
  push(@result, \@blank1);
  for my $row (@pixels){
    my @newrow = (0,@$row,0);
    push(@result,\@newrow);
  }
  push(@result, \@blank2);

  my $newimage;
  $newimage->{"pixels"}=\@result;
  return ($newimage,$size);
}

sub clone_image{
  my $input = shift;
  my @pixels = @{$input->{"pixels"}};

  
  my $size = scalar(@pixels);
  my @result;
  for my $row (@pixels){
    my @newrow = (@$row);
    push(@result,\@newrow);
  }

  my $newimage;
  $newimage->{"pixels"}=\@result;
  return ($newimage,$size);
}

sub sum_pixels{
  my $input = shift;
  my $sum = 0;
  for my $row (@{$input->{"pixels"}}){
    map { $sum += $_ } @$row;
  }
  return $sum;
}

  
print "Starting image:\n";
print_image($image);

my $infinity;
my @infarr = ([(0) x 3], [(0) x 3], [(0) x 3]);
$infinity->{"pixels"} = \@infarr;

# grow the image with 1 pixel border
# twice first time round
my $size;
($image, $size) = grow($image);
($image, $size) = grow($image);
($image, $size) = grow($image);
($image, $size) = grow($image);
($image, $size) = grow($image);
($image, $size) = grow($image);
for my $growing (1..50){
  ($image, $size) = grow($image);
}

my $infinitypixel = $infinity->{"pixels"}[1][1];
for my $frame (1..50){
  my ($nextimage, $newsize) = clone_image($image);
  for my $row (0..$size-1){
    for my $column (0..$size-1){
      ${$nextimage->{"pixels"}}[$row][$column]=enhance_pixel($image, $row, $column, $infinitypixel);
    }
  }
  $image = $nextimage;
  $infinitypixel = enhance_pixel($infinity, 1, 1, 0);
  @infarr = ([($infinitypixel) x 3], [($infinitypixel) x 3], [($infinitypixel) x 3]);
  $infinity->{"pixels"} = \@infarr;
  print "Infinity:\n";
  print_image($infinity);
  
  $size  = $newsize;
  print "After $frame frames:\n";
  print_image($image);
  
}

print "Number of lit pixels: ",sum_pixels($image),"\n";
