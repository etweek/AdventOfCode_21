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


sub print_scores{
  my $r_scores = shift;
  my %scores = %{$r_scores};

  for my $key (keys(%scores)){
    print "\t",$key, "=", $scores{$key};
  }
  print "\n";
  # for my $player1 (1..20){
  #   for my $player2 (1..20){
  #     print "\t",$player1.":".$player2,"=",$scores{$player1.":".$player2};
  #   }
  #   print "\n";
  # }
}
#calculate all the possible scores
# my %scores;
# for my $player1 (1..20){
#   for my $player2 (1..20){
#     $scores{$player1.":".$player2}=0;
#   }
# }

# all possible rolls

my %rolls;
for my $die1 (1..3){
  for my $die2 (1..3){
    for my $die3 (1..3){
      my $val = $die1+$die2+$die3;
      $rolls{$val}++;
    }
  }
}

my $player1_wins = 0;
my $player2_wins = 0;

my %scores=("0:0:$player1_pos:$player2_pos"=>1);
print "Before play commences:\n";
print_scores(\%scores);

my $universes_left = 1;
my $round=0;
while($universes_left>0){
  my %newscores;
  $universes_left = 0;
  # 27 new universes created for each existing universe, ranging from 3(1+1+1) moves to 9(3+3+3) moves
  # consider all the buckets and how it affects them
  for my $key (keys(%scores)){
    my ($player1_score,$player2_score,$player1_pos,$player2_pos) = split(/:/,$key);
    my $num_universes = $scores{$key};
    for my $player1_move (keys(%rolls)){
      my $new_universes = $rolls{$player1_move};
      my $player1_new = $player1_pos + $player1_move;
      if($player1_new >= 10){
        $player1_new = $player1_new%10;
      }
      my $player1_score_new = $player1_score+$player1_new+1;
      if($player1_score_new >= 21){
        $player1_wins += $num_universes*$new_universes;
      }
      else{
        $newscores{"$player1_score_new:$player2_score:$player1_new:$player2_pos"} += $num_universes*$new_universes;
        $universes_left+=$num_universes*$new_universes;
      }
    }
  }

  %scores = %newscores;
  %newscores=();
  $universes_left = 0;
#  print "Half-way through round $round:\n";
#  print_scores(\%scores);
  # 27 new universes created for each existing universe, ranging from 3(1+1+1) moves to 9(3+3+3) moves
  # consider all the buckets and how it affects them
  for my $key (keys(%scores)){
    my ($player1_score,$player2_score,$player1_pos,$player2_pos) = split(/:/,$key);
    my $num_universes = $scores{$key};
    for my $player2_move (keys(%rolls)){
      my $new_universes = $rolls{$player2_move};
      my $player2_new = $player2_pos + $player2_move;
      if($player2_new >= 10){
        $player2_new = $player2_new%10;
      }
      my $player2_score_new = $player2_score+$player2_new+1;
      if($player2_score_new >= 21){
        $player2_wins += $num_universes*$new_universes;
      }
      else{
        $newscores{"$player1_score:$player2_score_new:$player1_pos:$player2_new"} += $num_universes*$new_universes;
        $universes_left+=$num_universes*$new_universes;
      }
    }
  }
  %scores = %newscores;
  $round++;
  print "At the end of round $round:\n";
  #print_scores(\%scores);
  print "$universes_left universes left\n";
  print "Player 1: $player1_wins\n";
  print "Player 2: $player2_wins\n";
  
}
  
