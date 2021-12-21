#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my @rows;
my $numrows;
my $numcols;
while(my $line = <STDIN>){
  chomp($line);
  my @columns = split(//, $line);
  $numcols= scalar(@columns);
  push(@rows,\@columns);
}
$numrows=scalar(@rows);

my %chunk_map=('[' => ']',
               '(' => ')',
               '{' => '}',
               '<' => '>');

my %points=(']' => 57,
            ')' => 3,
            '}' => 1197,
            '>' => 25137);

  
sub start_chunk{
  my $chunk_char = shift;
#  print "Got !$chunk_char!\n";
  my $end_char = $chunk_map{$chunk_char};
#  print "looking for $end_char\n";
  my $row = shift;
  my $nextchar = shift(@{$row});
#  print " $chunk_char=$end_char ";
  while(defined($nextchar) && $nextchar ne $end_char){
    my $points = dispatch($nextchar, $row);
    if($points != 0){
      return $points;
    }
#    print "=$end_char";
    $nextchar = shift(@{$row});
  }
  if(!defined($nextchar)){
    print "Syntax error, expected $end_char, got EOL\n";
    return -1;
  }
  print $nextchar,". ";
  return 0;
}


sub dispatch{
  my $nextchar = shift;
  my $row = shift;
  die "no next char" unless defined($nextchar);
  print "$nextchar ";
  if($nextchar eq '[' || $nextchar eq '(' || $nextchar eq '{' || $nextchar eq '<'){
    return start_chunk($nextchar,$row);
  }
  else{
    print "Unexpected char: $nextchar\n";
    return $points{$nextchar};
  }

}

my $total_errors=0;
for my $row (@rows){
  #  my @columns = @{$row};
#  print "Start of line\n";
  my $nextchar = shift(@{$row});
  while(defined($nextchar)){
    my $points = dispatch($nextchar, $row);
    if($points != 0){
      print $points,"\n";
      if($points > 0){
        $total_errors += $points;
      }
      last;
    }
    $nextchar = shift(@{$row});
  }
}
print "Total Error points = $total_errors\n";
