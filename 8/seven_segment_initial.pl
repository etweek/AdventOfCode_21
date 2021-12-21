#!/opt/loca/bin/perl
use warnings;
use strict;

use List::Util qw(max min);

use Data::Dumper;

#gather input
my @inputs;
my @outputs;
while(my $line = <STDIN>){
  chomp($line);
  my ($input, $output) = split(/ \| /, $line);
  my @input_array = split(/ /,$input);
  my @output_array = split(/ /,$output);
  push(@inputs, \@input_array);
  push(@outputs, \@output_array);
}

print "There are ",scalar(@inputs), " input examples\n";

# 1: 2 segments (c,f)
# 4: 4 segments (b,c,d,f)
# 7: 3 segments (a,c,f)
# 8: 7 segments (a,b,c,d,e,f,g)
my $count = 0;
for my $output (@outputs){
  my @displays = @{$output};
  for my $display (@displays){
#    print "$display has ",length($display)," segments\n";
    if(length($display) == 2){
      #it's a 1
      $count++;
    }
    elsif(length($display) == 3){
      #it's a 7
      $count++;
    }
    elsif(length($display) == 4){
      #it's a 4
      $count++;
    }
    elsif(length($display) == 7){
      #it's a 8
      $count++;
    }
  }
}

print "There were $count times that digits 1,4,7 and 8 appeared\n";

# 2: 5 segments (a,c,d,e,g)
# 3: 5 segments (a,c,d,f,g)
# 5: 5 segments (a,b,d,f,g)
# 6: 6 segments (a,b,d,e,f,g)
# 9: 6 segments (a,b,c,d,f,g)  
  
