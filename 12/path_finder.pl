#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my @links;

while(my $line = <STDIN>){
  chomp($line);
  my @link =split(/-/,$line);
  
  push(@links,\@link);
}
my $numlinks=scalar(@links);

print "There are $numlinks links defined\n";

sub find_node_in_path{
  my $node = shift;
  my $path = shift;
  my @keys = keys(%{$path});
  print @keys,"\n";
}

my $paths;
$paths->{"start"}=1;
for my $link (@links){
  my ($source, $target)=@{$link};
  find_node_in_path($source,$paths);
  $paths->{$source}->{$target}=1;
}

print Dumper($paths);
