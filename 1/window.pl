#!/opt/loca/bin/perl
use warnings;
use strict;

my $larger=0;
my $current=99999;
my @input = <STDIN>;
my $i = 2;
while($i<=$#input){
  my $line = $input[$i] + $input[$i-1] + $input[$i-2];
#  print $line,"\n";
  $i++;
  if($line > $current){
    $larger++;
  }
  $current= $line;
}

print "Increased $larger times\n";
