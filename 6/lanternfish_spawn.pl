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

my @buckets=(0,0,0,0,0,0,0,0);
for my $fish(@ages){
  $buckets[$fish]++;
}

print join(",",@buckets);
exit 1;
my $DAYS=256;
for(my $day=1; $day <= $DAYS; $day++){
  print STDERR $day,", ";
  @ages = @{tick(\@ages)};
}
print "There are ",scalar(@ages)," fish in the sea: ";
if(0){
  print join(",",@ages),"\n";
}
else{
  print "\n";
}
