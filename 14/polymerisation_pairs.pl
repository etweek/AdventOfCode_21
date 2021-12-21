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
  my @chars = @{$polymer};
  
  my @result;

  for(my $i=0; $i<$#chars; $i++){
    my $key = $chars[$i].$chars[$i+1];
    push(@result,$chars[$i]);
    if(defined($rules{$key})){
      push(@result,$rules{$key});
    }
    else{
    }
  }
  push(@result,$chars[-1]);
  return \@result;
}

sub min_max{
  my $polymer = shift;
  
  my %all_freq;
  for my $char (split(//,$polymer)){
    $all_freq{$char}++;
  }
  #print Dumper(%all_freq);
  my @freq = sort {$a <=> $b} values(%all_freq);
  my $min = $freq[0];
  my $max = $freq[-1];
  return ($min, $max);
}

sub get_pairs{
  my $r_arr = shift;
  my @a_rray = @{$r_arr};

  my $res;
  for (my $i=0; $i<$#a_rray; $i++){
    my $key = $a_rray[$i].$a_rray[$i+1];
    $res->{$key}=1;
  }
  return $res;
}

sub increment{
  my $r_pairs = shift;

  my $res;
  for my $pair (keys(%$r_pairs)){
    if(defined($rules{$pair})){
      my ($char1, $char2) = split(//,$pair);
      my $pair1 = $char1.$rules{$pair};
      my $pair2 = $rules{$pair}.$char2;
      $res->{$pair1}+=$r_pairs->{$pair};
      $res->{$pair2}+=$r_pairs->{$pair};
    }
    else{
      $res->{$pair}+=$r_pairs->{$pair};
    }
  }
  return $res;
}

sub count_chars{
  my $r_pairs = shift;

  my $char_buckets;
  for my $pair (keys(%$r_pairs)){
    my ($char1, $char2) = split(//,$pair);
    $char_buckets->{$char1} += $r_pairs->{$pair};
  }
  return $char_buckets;
}

my @polymer = split(//, $start);
my $pair_buckets = get_pairs(\@polymer);
print Dumper($pair_buckets);
for(my $step=1;$step <=40; $step++){
  $pair_buckets = increment($pair_buckets);
}
print Dumper($pair_buckets);
my $char_buckets = count_chars($pair_buckets);
$char_buckets->{$polymer[-1]}++;
my @freq = sort {$a <=> $b} values(%$char_buckets);
my $min = $freq[0];
my $max = $freq[-1];

print Dumper($char_buckets);
print "$max-$min=",($max-$min),"\n";
