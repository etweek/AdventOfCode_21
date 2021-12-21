#!/opt/loca/bin/perl
use warnings;
use strict;

my $oxygen;
my $co2;

my @input = <STDIN>;

my @rows = ();
my @transposed = ();

my $i = 0;
while($i<=$#input){
  my $line = $input[$i];
  chomp($line);

  my @row = split(//,$line);
  print @row,"\n";
  $rows[$i]=\@row;
  $i++
}

sub filter {
  my $highest = shift;
  my $index = shift;
  my $array_ref = shift;
  my @array = @{$array_ref};
  my $len = $#{$array_ref}+1;
  print "looking for ",$len/2," of $highest...";

  my $sum = 0;
  for my $row (@array){
    $sum += ${$row}[$index];
  }
  print $sum,"\n";
  my @result = ();
  if($sum > $len/2){
    for my $row (@array){
      if(${$row}[$index] == $highest){
        push(@result, $row);
      }
    }
  }
  elsif($sum < $len/2){
    for my $row (@array){
      if(${$row}[$index] == 1-$highest){
        push(@result, $row);
      }
    }
  }
  else{
    #equal number
    for my $row (@array){
      if(${$row}[$index] == $highest){
        push(@result, $row);
      }
    }
  }
  return \@result;
}

sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

my $index = 0;
my $result = \@rows;
my @res = @{$result};

while(scalar @{$result} > 1){
  $result = filter(1, $index, $result);
  $index++;
  my @res = @{$result};
  for my $new_row (@res){
    print @{$new_row},"\t";
  }
  print "\n";
}
my @remaining = @{$result->[0]};
$oxygen = bin2dec(join("",@remaining));
print $oxygen,"\n";

# reset for CO2
$index = 0;
$result = \@rows;
@res = @{$result};

while(scalar @{$result} > 1){
  $result = filter(0, $index, $result);
  $index++;
  my @res = @{$result};
  for my $new_row (@res){
    print @{$new_row},"\t";
  }
  print "\n";
}
@remaining = @{$result->[0]};
$co2 = bin2dec(join("",@remaining));
print $co2,"\n";

print "Life Support rating is ", ($oxygen * $co2), "\n";
