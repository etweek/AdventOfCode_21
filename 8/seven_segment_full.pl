#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

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
sub anagram{
  my ($s1, $s2) = @_;

  return (join '', sort { $a cmp $b } split(//, $s1)) eq
         (join '', sort { $a cmp $b } split(//, $s2));
}

sub find_index{
  my $search=shift;
  my $space=shift;
  my @space_array = @{$space};
  for(my $i=0;$i<=$#space_array;$i++){
    if(anagram($search,$space_array[$i])){
      return $i;
    }
  }
  return -1;
}

sub contains{
  my $target = shift;
  my $searchfor = shift;

  my @tchars = split(//,$target);
  my @schars = split(//,$searchfor);
  for my $char (@schars){
#    print "checking for $char in @tchars\n";
    if(!grep(/^$char$/,@tchars)){
      # char isn't in target
      return 0;
    }
  }
  return 1

}
# 1: 2 segments (c,f)
# 4: 4 segments (b,c,d,f)
# 7: 3 segments (a,c,f)
# 8: 7 segments (a,b,c,d,e,f,g)

# 2: 5 segments (a,c,d,e,g)
# 3: 5 segments (a,c,d,f,g)
# 5: 5 segments (a,b,d,f,g)

# 0: 6 segments (a,b,c,e,f,g)
# 6: 6 segments (a,b,d,e,f,g)
# 9: 6 segments (a,b,c,d,f,g)  

my $total=0;
for (my $i=0; $i <= $#inputs; $i++){
  my @displays = @{$inputs[$i]};
  my ($one, $two, $three, $four, $five, $six, $seven, $eight, $nine, $zero);
  my @numbers=();
  for my $display (@displays){
    #    print "$display has ",length($display)," segments\n";
    my $len = length($display);
    if($len == 2){
      #it's a 1
      $one = $display;
      $numbers[1]=$display;
    }
    elsif($len == 3){
      #it's a 7
      $seven = $display;
      $numbers[7]=$display;
    }
    elsif($len == 4){
      #it's a 4
      $four = $display;
      $numbers[4]=$display;
    }
    elsif($len == 7){
      #it's a 8
      $eight=$display;
      $numbers[8]=$display;
    }
    #that's all we can do by length
  }
  #round 2
  for my $display (@displays){
    #    print "$display has ",length($display)," segments\n";
    my $len = length($display);
    # only three contains a one
    if($len==2 || $len==3 || $len==4 || $len==7){
      #dealt with already
    }
    elsif($len==5 && contains($display, $one)){
      $three = $display;
      $numbers[3]=$display;
    }
    elsif($len==6 && !contains($display, $one)){
#      print "$display is six\n";
      $six=$display;
      $numbers[6]=$display;
    }
  }
  #round 3
  for my $display (@displays){
    #    print "$display has ",length($display)," segments\n";
    my $len = length($display);
    # only three contains a one
    if($len==2 || $len==3 || $len==4 || $len==7 || $display eq $three || $display eq $six){
      #dealt with already
    }
    elsif($len==5 && contains($six, $display)){
#      print "$display is five\n";
      $five = $display;
      $numbers[5]=$display;
    }
  }
  #round 4
  for my $display (@displays){
    #    print "$display has ",length($display)," segments\n";
    my $len = length($display);
    # only three contains a one
    if($len==2 || $len==3 || $len==4 || $len==7 || $display eq $three || $display eq $six || $display eq $five){
      #dealt with already
    }
    elsif($len==5 && !anagram($five, $display)){
#      print "$display is two\n";
      $two = $display;
      $numbers[2]=$display;
    }
    elsif($len==6 && contains($display, $five)){
#      print "$display is nine\n";
      $nine=$display;
      $numbers[9]=$display;
    }
    elsif($len==6 && !contains($display, $five)){
#      print "$display is zero\n";
      $zero=$display;
      $numbers[0]=$display;
    }
  }

  ## check
  for(my $j=0;$j<10;$j++){
    if(!$numbers[$j]){
      die "Didn't classify $j for ",join(" ",@displays),"\n";
    }
  }
  
  ## now solve output
  my $num = 0;
  my $out_display = $outputs[$i];
  for my $digit (@{$out_display}){
    $num = $num*10 + find_index($digit, \@numbers);
  }
  print "Solution is $num\n";
  $total += $num;
}

print "Total is $total\n";


  
