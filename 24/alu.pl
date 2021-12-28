#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
$Data::Dumper::Indent=1;
use Data::Compare;
use Scalar::Util qw(looks_like_number);

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
while(my $line = <STDIN>){
  chomp($line);
  @input= split(//,$line);
}
print scalar(@input), " lines of input\n";

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
  if(!looks_like_number($rval)){
    dump_registers();
    die "$rval not a number";
  }
  $registers->{$arg0} = ($registers->{$arg0}==$rval)?1:0;
}


for my $instruction (@instructions){
  my @args=split(/ /,$instruction);
#  print join(",",@args),"\n";
  my $comm = shift(@args);
  if($comm eq "inp"){
    input(@args);
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
    die "Unknown instruction $instruction";
  }

}

dump_registers();
