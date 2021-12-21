#!/opt/loca/bin/perl
use warnings;
use strict;

my $gamma="";
my $epsilon="";

my @input = <STDIN>;

my @rows = ();
my @transposed = ();

my $i = 0;
while($i<=$#input){
  my $line = $input[$i];
  chomp($line);

  my @row = split(//,$line);
#  print @row,"\n";
  $rows[$i]=\@row;
  $i++
}

for my $row (@rows){
  my $len = $#{$row};
  for my $column (0 .. $len){
    push(@{$transposed[$column]}, $row->[$column]);  
  }
}

for my $new_row (@transposed) {
  my $len = $#{$new_row}+1;
  my $sum = 0;
  print $len," ";
  for my $new_col (@{$new_row}) {
    $sum += $new_col;
    print $new_col, " ";
  }
  print " = $sum\n";
  if($sum > $len/2){
    $gamma   .= "1";
    $epsilon .= "0";
  }
  elsif($sum < $len/2){
    $gamma   .= "0";
    $epsilon .= "1";
  }
  else{
    die "No most common bit";
  }
  
}

sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

my $gamma_dec = bin2dec($gamma);
my $epsilon_dec = bin2dec($epsilon);

print $gamma, " = ", $gamma_dec,"\n",$epsilon," = ",$epsilon_dec,"\n";

print "Power consumption is ", ($gamma_dec*$epsilon_dec),"\n";
