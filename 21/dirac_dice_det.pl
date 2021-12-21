#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
use Data::Compare;

#gather input
my $player1_line = <STDIN>;
my $player1_pos = 0;
if($player1_line =~ /Player 1 starting position: (\d+)/){
  $player1_pos = $1-1;
}
else{
  die "Couldn't parse player 1 line";
}
my $player2_line = <STDIN>;
my $player2_pos = 0;
if($player2_line =~ /Player 2 starting position: (\d+)/){
  $player2_pos = $1-1;
}
else{
  die "Couldn't parse player 2 line";
}

my $die_val=1;
my $rolls=0;
sub roll{
  $rolls++;
  if($die_val>100){
    $die_val=1;
  }
  my $result = $die_val++;
  print "$rolls: $result\n";
  return $result
}

my $player1_score = 0;
my $player2_score = 0;

while($player1_score < 1000 && $player2_score < 1000){
  my $player1_move = roll()+roll()+roll();
  $player1_pos += $player1_move;
  if($player1_pos >= 10){
    $player1_pos = $player1_pos%10;
  }
  print "player1: $player1_score + ",($player1_pos+1)," = ";
  $player1_score += $player1_pos+1;
  print $player1_score,"\n";
  if($player1_score >= 1000){
    print "Player 1 wins, score is $player1_score, $rolls rolls of the dice were made, $player2_score was the opposition score.  Finishing number: ", ($player2_score*$rolls),"\n";
    exit 0;
  }

  my $player2_move = roll()+roll()+roll();
  $player2_pos += $player2_move;
  if($player2_pos >= 10){
    $player2_pos = $player2_pos%10;
  }
  print "player2: $player2_score + ",($player2_pos+2)," = ";
  $player2_score += $player2_pos+1;
  print $player2_score,"\n";
  if($player2_score >= 1000){
    print "Player 2 wins, score is $player2_score, $rolls rolls of the dice were made, $player1_score was the opposition score.  Finishing number: ", ($player1_score*$rolls),"\n";
    exit 0;
  }
}
