#!/opt/loca/bin/perl
use warnings;
use strict;

use Storable qw(dclone);

use Data::Dumper;

#gather input
my $line = <STDIN>;
my @ages=split(/,/,$line);

print "There are ",scalar(@ages)," fish in the sea: ",join(",",@ages),"\n";

sub tick{
  my $ref_timers = shift;
  my @timers = @{$ref_timers};
  #record index at the start, as it will grow
  my $last = $#timers;
  for(my $i=0;$i <= $last; $i++){
#    print "Fish $i has timer $timers[$i]\n";
    if($timers[$i] == 0){
      $timers[$i] = 6;
      push(@timers, 8);
    }
    else{
      $timers[$i]--;
    }
  }
#  print "There are ",scalar(@timers)," timers: ",join(",",@timers),"\n";
  return \@timers;
}

sub bucket_tick{
  my $ref_buckets = shift;
  my @buckets = @{$ref_buckets};
  my @output = (0,0,0,0,0,0,0,0,0);
  for (my $i=0; $i <= $#buckets; $i++){
    if($i==0){
      $output[8]=$buckets[$i];
      $output[6]=$buckets[$i];
    }
    else{
      $output[$i-1] += $buckets[$i];
    }
  }
  return \@output;
}

sub print_bucket{
  my $ref_buckets = shift;
  my @buckets = @{$ref_buckets};
  my $sum = 0;
  map { $sum += $_ } @buckets;
  print "There are ",$sum," fish in the sea\n";
}
  
my @buckets=(0,0,0,0,0,0,0,0);
for my $fish(@ages){
  $buckets[$fish]++;
}

print_bucket(\@buckets);

my $DAYS=256;
for(my $day=1; $day <= $DAYS; $day++){
  print STDERR $day,", ";
  @buckets = @{bucket_tick(\@buckets)};
}
print "\n";

print_bucket(\@buckets);

