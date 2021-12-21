#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my $start = <STDIN>;
chomp($start);
my %rules;


while(my $line = <STDIN>){
  chomp($line);
  if($line =~ /(..) -> (.)/){
    $rules{$1}=$2;
  }
}
my $numrules=scalar(%rules);

print "There are $numrules rules, starting with $start\n";

sub find_matches{
  my $polymer = shift;
  my $pair = shift;

  my @results;

  my $offset = 0;
  my $hit = index($polymer, $pair, $offset);

  while ($hit != -1) {
    push(@results, $hit);
    $offset = $hit + 1;
    $hit = index($polymer, $pair, $offset);
  }
  return @results;
}

sub increase_index{
  my $r_matches = shift;
  my $insert = shift;

  my %matches=%{$r_matches};
  for my $pair(keys(%matches)){
    my $r_in=$matches{$pair};
    my @out;
    for my $index(@{$r_in}){
      if($index>$insert){
        print "increasing index of $pair from $index to $index+1\n";
        push(@out,$index+1);
      }
      else{
        push(@out,$index);
      }
    }
    $matches{$pair}=\@out;
  }
  return \%matches;
}

sub run_rules{
  my $polymer = shift;

  my %matches;
  my %insertions;
  for my $pair (keys(%rules)){
    my @hits = find_matches($polymer, $pair);
    if(scalar(@hits)>0){
      for my $insertion (@hits){
        if(defined($insertions{$insertion})){
          die "Already an insertion at point $insertion before $pair rule\n";
        }
        else{
          $insertions{$insertion}=$rules{$pair};
        }
      }
    }
  }

  for my $index (reverse sort {$a <=> $b} keys(%insertions)){
    #print "inserting ",$insertions{$index}," at $index\n";
    substr($polymer, $index+1, 0) = $insertions{$index};
  }
  return $polymer;
  
}

sub min_max{
  my $polymer = shift;
  
  my %all_freq;
  for my $char (split(//,$polymer)){
    $all_freq{$char}++;
  }
  print Dumper(%all_freq);
  my @freq = sort {$a <=> $b} values(%all_freq);
  my $min = $freq[0];
  my $max = $freq[-1];
  return ($min, $max);
}
  
my $polymer = run_rules($start);
print "After one run, the result is $polymer\n";
for (my $i = 2; $i <= 40; $i++){
  $polymer = run_rules($polymer);
#  print "After step $i: $polymer\n";
}

my ($min, $max)=min_max($polymer);
print "$max - $min = ",($max-$min),"\n";
