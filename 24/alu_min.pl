#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
$Data::Dumper::Indent=1;
use Data::Compare;

my @instructions;

my $file = $ARGV[0];
print "reading $file\n";
open my $fh, '<', $file or die;
while(my $line = <$fh>){
  chomp($line);
  push(@instructions, $line)
}
print scalar(@instructions), " instructions in program\n";


my @input;
# while(my $line = <STDIN>){
#   chomp($line);
#   @input= split(//,$line);
# }
# print scalar(@input), " lines of input\n";

my $registers;
$registers->{'w'}=0;
$registers->{'x'}=0;
$registers->{'y'}=0;
$registers->{'z'}=0;

sub dump_registers{
  print "w:",$registers->{'w'},"\t";
  print "x:",$registers->{'x'},"\t";
  print "y:",$registers->{'y'},"\t";
  print "z:",$registers->{'z'},"\n";
}
# inp a - Read an input value and write it to variable a.
# add a b - Add the value of a to the value of b, then store the result in variable a.
# mul a b - Multiply the value of a by the value of b, then store the result in variable a.
# div a b - Divide the value of a by the value of b, truncate the result to an integer, then store the result in variable a. (Here, "truncate" means to round the value toward zero.)
# mod a b - Divide the value of a by the value of b, then store the remainder in variable a. (This is also called the modulo operation.)
# eql a b - If the value of a and b are equal, then store the value 1 in variable a. Otherwise, store the value 0 in variable a.

sub input{
  my $arg = shift;
  my $input = shift(@input);
  
  if(!defined($registers->{$arg})){
    die "invalid inp line with $arg";
  }
  #  print "Setting $arg to $input\n";
  $registers->{$arg}=$input;
}


sub add{
  my $arg0 = shift;
  my $arg1 = shift;

  my $rval;
  if(!defined($registers->{$arg0})){
    die "invalid add line with $arg0, $arg1"
  }
  if(defined($registers->{$arg1})){
    $rval = $registers->{$arg1};
  }
  else{
    $rval = $arg1;
  }
  $registers->{$arg0}=$registers->{$arg0} + $rval;
}

sub mod{
  my $arg0 = shift;
  my $arg1 = shift;

  my $rval;
  if(!defined($registers->{$arg0})){
    die "invalid mod line with $arg0, $arg1"
  }
  if(defined($registers->{$arg1})){
    $rval = $registers->{$arg1};
  }
  else{
    $rval = $arg1;
  }
  $registers->{$arg0}=$registers->{$arg0} % $rval;
}

sub div{
  my $arg0 = shift;
  my $arg1 = shift;

  my $rval;
  if(!defined($registers->{$arg0})){
    die "invalid div line with $arg0, $arg1"
  }
  if(defined($registers->{$arg1})){
    $rval = $registers->{$arg1};
  }
  else{
    $rval = $arg1;
  }
  $registers->{$arg0}=int($registers->{$arg0} / $rval);
}

sub mul{
  my $arg0 = shift;
  my $arg1 = shift;

  my $rval;
  if(!defined($registers->{$arg0})){
    die "invalid mul line with $arg0, $arg1"
  }
  if(defined($registers->{$arg1})){
    $rval = $registers->{$arg1};
  }
  else{
    $rval = $arg1;
  }
  $registers->{$arg0}=$registers->{$arg0} * $rval;
}

sub eql{
  my $arg0 = shift;
  my $arg1 = shift;

  my $rval;
  if(!defined($registers->{$arg0})){
    die "invalid eql line with $arg0, $arg1"
  }
  if(defined($registers->{$arg1})){
    $rval = $registers->{$arg1};
  }
  else{
    $rval = $arg1;
  }
  $registers->{$arg0} = ($registers->{$arg0}==$rval)?1:0;
}

sub parse_input{
  my $arg = shift;
  my $string = "".$arg;
  @input = split(//,$string);
}

sub reset_registers{
  my $z=shift;
  $registers->{'w'}=0;
  $registers->{'x'}=0;
  $registers->{'y'}=0;
  $registers->{'z'}=$z;
}  

my $z_values;
my @zs;
my $current_z=0;
my $digit_for_z=0;

my $current = 9;
my $digit = 1;
my $stored_pc = 0;
@input=($current);
for(my $pc=0; $pc <= $#instructions; $pc++){
  #  for my $instruction (@instructions){
  
  my @args=split(/ /,$instructions[$pc]);
  #  print join(",",@args),"\n";
  my $comm = shift(@args);
  if($comm eq "inp"){
    # breakpoint
    if($pc > 0 && $current > 1){
      # store what we've got
      my $num = $digit_for_z + $current;
#      print "$current_z: $digit_for_z + $current = ",$num,"\n";
      if(!defined($z_values->{$digit}->{$registers->{'z'}}) || $z_values->{$digit}->{$registers->{'z'}} > $num){
        $z_values->{$digit}->{$registers->{'z'}}=$num;
      }
#      print $current,": ";
#      dump_registers();
      reset_registers($current_z);
      
      @input=(--$current);
      $pc=$stored_pc;
      input(@args);
    }
    elsif($pc > 0 && $current == 1){
      # store what we've got
      my $num = $digit_for_z + $current;
#      print "$current_z: $digit_for_z + $current = ",$num,"\n";
      if(!defined($z_values->{$digit}->{$registers->{'z'}}) || $z_values->{$digit}->{$registers->{'z'}} > $num){
        $z_values->{$digit}->{$registers->{'z'}}=$num;
      }
      #      print $current,": ";
      #      dump_registers();
      #      print Dumper($z_values);

      if($digit > 1 && scalar(@zs)>0){
        # need  to replay z rege values too
        # still have more to do.
        $current_z = shift(@zs);
        $digit_for_z = $z_values->{$digit-1}->{$current_z}*10;
        #print "digit for z = $digit_for_z\n";
        if(length(sprintf("%d",$digit_for_z)) < $digit){
          die "Previous value too short: $digit_for_z when working on $digit";
        }
        reset_registers($current_z);
        $current = 9;
        @input=($current);
        $pc = $stored_pc;
        input(@args);
      }
      else{
        # finally done
        print $digit," done\n";
        # move on, store all the possible z values from this digit
        @zs = keys(%{$z_values->{$digit}});
        print scalar(@zs)," possible z values to test next time\n";
#        print(Dumper($z_values));
        $digit++;
        
        $current_z = shift(@zs);
        $digit_for_z = $z_values->{$digit-1}->{$current_z}*10;
        reset_registers($current_z);
        $current = 9;
        @input=($current);
        $stored_pc = $pc;
        input(@args);
      }
    }
    else{
      # first loop
      $current = 9;
      input(@args);
      $stored_pc = $pc;
    }
  }
  elsif($comm eq "add"){
    add(@args);
  }
  elsif($comm eq "mod"){
    mod(@args);
  }
  elsif($comm eq "div"){
    div(@args);
  }
  elsif($comm eq "mul"){
    mul(@args);
  }
  elsif($comm eq "eql"){
    eql(@args);
  }
  else{
    die "Unknown instruction ".$instructions[$pc];
  }
}

#   if($registers->{"z"} == 0){
#     print $max, "is the largest valid number\n";
#     exit 0;
#   }
#   $max--;
# }
#dump_registers();
#print Dumper($z_values);
print "Value that got 0 at the end: ", $z_values->{14}->{0},"\n";
