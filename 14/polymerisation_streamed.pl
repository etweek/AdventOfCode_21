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

my @polymer = split(//, $start);  
@polymer = @{run_rules(\@polymer)};
print "After one run, the result is ",join("",@polymer),"\n";
for (my $i = 2; $i <= 40; $i++){
  print "Step $i:",scalar(@polymer),"\n";
  @polymer = @{run_rules(\@polymer)};
#  print "After step $i: ",join("",@polymer),"\n";

}
my $end = join("",@polymer);
my ($min, $max)=min_max($end);
print "$max - $min = ",($max-$min),"\n";
