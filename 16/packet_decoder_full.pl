#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my $hexchars = <STDIN>;
my $binchars = unpack("B*", pack("H*",$hexchars));
my @binary = split(//, $binchars);

sub decode_version{
  my $off = shift;
  return ($off+3, oct("0b".$binary[$off+0].$binary[$off+1].$binary[$off+2]));
}

sub decode_type{
  my $off = shift;
  return ($off+3, oct("0b".$binary[$off+0].$binary[$off+1].$binary[$off+2]));
}

sub decode_literal{
  my $off=shift;

  my @res;
  while($binary[$off++] == '1'){
    push(@res,$binary[$off++]);
    push(@res,$binary[$off++]);
    push(@res,$binary[$off++]);
    push(@res,$binary[$off++]);
  }
  #grab the last nibble
  push(@res,$binary[$off++]);
  push(@res,$binary[$off++]);
  push(@res,$binary[$off++]);
  push(@res,$binary[$off++]);
  return ($off, oct("0b".join("",@res)));
}

my @operators = ('+','*','min','max',undef,'>','<','==');
sub process_operator{
  my $type = shift;
  my $left = shift;
  my $right = shift;
  # 0: sum
  # 1: product
  # 2: min
  # 3: max
  # 5: >
  # 6: <
  # 7: =
  if(!defined($left)){
    # First of two operands
    return $right;
  }
  print "$left ".$operators[$type]." $right = ";
  my $res;
  if($type == 0){
    $res = $left + $right;
  }
  elsif($type == 1){
    $res= $left * $right;
  }
  elsif($type == 2){
    if($left < $right){
      $res = $left;
    }
    else{
      $res = $right;
    }
  }
  elsif($type == 3){
    if($left > $right){
      $res = $left;
    }
    else{
      $res = $right;
    }
  }
  elsif($type == 5){
    if($left > $right){
      $res = 1;
    }
    else{
      $res = 0;
    }
  }
  elsif($type == 6){
    if($left < $right){
      $res = 1;
    }
    else{
      $res = 0;
    }
  }
  elsif($type == 7){
    if($left == $right){
      $res = 1;
    }
    else{
      $res = 0;
    }
  }
  else{
    die "unknown operator $type\n";
  }
  print "$res\n";
  return $res;
}

sub decode_operator{
  my $off = shift;
  my $type = shift;
  my $res;
  
  my $length=0;
  if($binary[$off++] eq "0"){
    #    print "15 bit length\n";
    #take 15 bits of length
    $length = oct("0b".join("",@binary[$off..$off+14]));
    $off += 15;
    print "Operator length=$length\n";
    my $end = $off+$length;
    while($off < $end){
      my $rvalue;
      ($off,$rvalue) = parse_packet($off);
      $res = process_operator($type, $res, $rvalue);
    }
  }
  else{
    #    print "11 bit length\n";
    #take 11 bits of length
    $length = oct("0b".join("",@binary[$off..$off+10]));
    $off += 11;
    print "Operator packets=$length\n";
    for my $i (1..$length){
      print "Packet $i:\n";
      my $rvalue;
      ($off,$rvalue) = parse_packet($off);
      $res = process_operator($type, $res, $rvalue);
    }
    
  }
  return ($off, $res);
}

sub parse_packet{
  my $off = shift;
  my $res=0;
  my $version;
  ($off, $version) = decode_version($off);
  printf("\tVersion %d, ",$version);
  my $type;
  ($off, $type) = decode_type($off);
  printf("Type %d\n",$type);

  if($type == 4){
    #literal
    ($off, $res) = decode_literal($off);
  }
  else{
    ($off, $res) = decode_operator($off, $type);
  }
  return ($off, $res);

}
my $offset=0;
my $result;
($offset, $result) = parse_packet($offset);

print $result,"\n";
