#!/opt/loca/bin/perl
use warnings;
use strict;

use Storable qw(dclone);

use Data::Dumper;

my $callLine = <STDIN>;
chomp($callLine);

my @cards=();
my @current_card;
while(<STDIN>){
  chomp($_);
  if(length($_) < 1){
    #new card time
    if($#current_card > 1){
      push(@cards, dclone(\@current_card));
      my @transposed = ();
      for my $row (@current_card){
        for my $column (0 .. $#{$row}){
          push(@{$transposed[$column]}, $row->[$column]);
        }
      }
      push(@cards, \@transposed);
    }
    @current_card=();
  }
  else{
    my @line = split ' ',$_;
    push @current_card, \@line;
  }
}
if($#current_card > 1){
  push(@cards, dclone(\@current_card));
  my @transposed = ();
  for my $row (@current_card){
    for my $column (0 .. $#{$row}){
      push(@{$transposed[$column]}, $row->[$column]);
    }
  }
  push(@cards, \@transposed);
}

#print Dumper(@cards);
sub check_row{
  my $row = shift;
  my $called = shift;
#  print "Checking ",join(",",@{$row})," against ",keys(%{$called}),"\n";
  for my $val (@{$row}){
    if(!$called->[$val]==1){
      return 0;
    }
  }
  return 1;
}
sub sum_unmarked_card{
  my $card = shift;
  my $called = shift;
  my $acc=0;
  for my $row(@{$card}){
    for my $col(@{$row}){
      if(!$called->[$col]==1){
        $acc += $col;
      }
    }
  }
  return $acc;
}

sub print_row{
  my $row = shift;
  for my $col(@{$row}){
    print $col," ";
  }
  print "\n";
}

sub check_cards{
  my $ref_cards = shift;
  my $called = shift;
  my @cards=@{$ref_cards};

  for(my $i=0; $i<=$#cards; $i++){
    my $card = $cards[$i];
    use integer;
    print "Checking card $i(",$i/2,"): ";
    print_row(${$card}[0]);
    for my $row (@{$card}){
      if(check_row($row, $called)){
        print "BINGO: ", join(", ", @{$row}), "\n";
        return $i;
      }
    }
  }
  return -1;
}

#my $cards_hash;
#for(my $i=0; $i<$#cards; $i++){

my @to_call = split(/,/,$callLine);
my $called;
my $cards_left = scalar(@cards)/2;
while(scalar(@to_call) > 0){
  my $val = shift(@to_call);
  $called->[$val]=1;
  print scalar(@cards), " (really $cards_left) left\n";
  my $index = check_cards(\@cards, $called);
  while($index > -1){
    use integer;
 
    my $sum = sum_unmarked_card($cards[$index],$called);
    print "$index: $val * $sum = ",($val * $sum),"\n";
    if($cards_left == 1){
      exit 0;
    }
    my $card_index = $index/2;
    delete $cards[$card_index*2+1];
    delete $cards[$card_index*2];
    $cards_left -=1;
    $index = check_cards(\@cards, $called);
#    exit 0;
  }
}

