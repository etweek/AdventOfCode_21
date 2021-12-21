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

sub decode_operator{
  my $off = shift;

  my $length=0;
  if($binary[$off++] eq "0"){
#    print "15 bit length\n";
    #take 15 bits of length
    $length = oct("0b".join("",@binary[$off..$off+14]));
    $off += 15;
    print "Operator length=$length\n";
    my $end = $off+$length;
    while($off < $end){
      $off = parse_packet($off);
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
      $off = parse_packet($off);
    }
    
  }
  return ($off, $length);
}
my $versions = 0;

sub parse_packet{
  my $off = shift;

  my $version;
  ($off, $version) = decode_version($off);
  $versions += $version;
  printf("Version %d\n",$version);
  my $type;
  ($off, $type) = decode_type($off);
  printf("Type %d\n",$type);

  if($type == 4){
    #literal
    ($off, my $literal) = decode_literal($off);
    print "Literal $literal\n";
  }
  else{
    ($off, my $length) = decode_operator($off);
  }
  return $off;

}
my $offset=0;
parse_packet($offset);

print $versions,"\n";
