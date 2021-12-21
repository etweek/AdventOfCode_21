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

sub check_cards{
  my $cards = shift;
  my $called = shift;

  for my $card (@{$cards}){
    for my $row (@{$card}){
      if(check_row($row, $called)){
        print "BINGO: ", join(", ", @{$row}), "\n";
        return sum_unmarked_card($card, $called);
      }
    }
  }
  return 0;
}

my @to_call = split(/,/,$callLine);
my $called;
while(scalar(@to_call) > 0){
  my $val = shift(@to_call);
  $called->[$val]=1;
  my $sum = check_cards(\@cards, $called);
  if($sum > 0){
    print "$val * $sum = ",($val * $sum),"\n";
    exit 0;
  }
}
