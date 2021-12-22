#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
use Data::Compare;

my @instructions;
my ($smallest_x, $smallest_y, $smallest_z) =(0,0,0);
my ($largest_x, $largest_y, $largest_z) =(0,0,0);


while(my $line = <STDIN>){
  my ($instruction, $startx, $endx, $starty, $endy, $startz, $endz);
  if($line =~ /([\w]+) x=([\d-]+)\.\.([\d-]+),y=([\d-]+)\.\.([\d-]+),z=([\d-]+)\.\.([\d-]+)/){
    ($instruction, $startx, $endx, $starty, $endy, $startz, $endz) = ($1,$2,$3,$4,$5,$6,$7);
  }
  else{
    die "Failed to parse $line\n";
  }
  my $entry;
  $entry->{"instruction"}=($instruction eq "on")?1:0;
  # we've been told to ignore these
  next if(($startx < -50 && $endx < -50)||
          ($startx > 50 && $endx > 50)||
          ($starty < -50 && $endy < -50)||
          ($starty > 50 && $endy > 50)||
          ($startz < -50 && $endz < -50)||
          ($startz > 50 && $endz > 50));
  if($startx > $endx){
    my $temp=$startx;
    $startx=$endx;
    $endx=$temp;
  }
  if($starty > $endy){
    my $temp=$starty;
    $starty=$endy;
    $endy=$temp;
  }
  if($startz > $endz){
    my $temp=$startz;
    $startz=$endz;
    $endz=$temp;
  }
  if($startx < $smallest_x){
    $smallest_x = $startx;
  }
  if($starty < $smallest_y){
    $smallest_y = $starty;
  }
  if($startz < $smallest_z){
    $smallest_z = $startz;
  }
  if($endx > $largest_x){
    $largest_x = $endx;
  }
  if($endy > $largest_y){
    $largest_y = $endy;
  }
  if($endz > $largest_z){
    $largest_z = $endz;
  }
  
  $entry->{"x1"}=$startx;
  $entry->{"x2"}=$endx;
  $entry->{"y1"}=$starty;
  $entry->{"y2"}=$endy;
  $entry->{"z1"}=$startz;
  $entry->{"z2"}=$endz;
  push(@instructions, $entry);
};

print scalar(@instructions)," instructions for within the ($smallest_x, $smallest_y, $smallest_z):($largest_x, $largest_y, $largest_z) area\n";
#print Dumper(@instructions)

sub volume{
  my $entry = shift;
  if(!defined($entry)){
    return 0;
  }
  my $result = ($entry->{"x2"}-$entry->{"x1"}+1)* ($entry->{"y2"}-$entry->{"y1"}+1) * ($entry->{"z2"}-$entry->{"z1"}+1);
  return $result;
}

sub format_instruction{
  my $el = shift;

  return "(".$el->{"x1"}.",".$el->{"y1"}.",".$el->{"z1"}."):(".$el->{"x2"}.",".$el->{"y2"}.",".$el->{"z2"}.")=".$el->{"instruction"};

}
sub sat{
  my $e1 = shift;
  my $e2 = shift;
  my $axis=shift;

  my $halfwidth_1 = $e1->{$axis."2"}-$e1->{$axis."1"};
  my $halfwidth_2 = $e2->{$axis."2"}-$e2->{$axis."1"};

  my $centre_1 = $e1->{$axis."1"}+$halfwidth_1;
  my $centre_2 = $e2->{$axis."1"}+$halfwidth_2;
  my $distance = max($centre_1, $centre_2)-min($centre_1,$centre_2);

  my $gap = $distance - $halfwidth_1 - $halfwidth_2;
  return ($gap < 0);
}

sub intersect{ 
  my $e1 = shift;
  my $e2 = shift;
  my $axis=shift;

  my $e1_start = $e1->{$axis."1"};
  my $e1_end   = $e1->{$axis."2"};
  my $e2_start = $e2->{$axis."1"};
  my $e2_end   = $e2->{$axis."2"};

  my ($start,$end);
  if($e1_end < $e2_start ||  $e2_end < $e1_start){
    # there's no intersection
    return (undef,undef);
  }
  else{
    if(min($e1_start,$e2_start) == $e1_start){
      $start = $e2_start;
      $end = min($e1_end,$e2_end);
    }
    else{
      $start = $e1_start;
      $end = min($e1_end,$e2_end);
    }
  }
  return ($start,$end);
}
 
sub overlap{
  my $e1 = shift;
  my $e2 = shift;

  my ($startx,$endx) = intersect($e1,$e2,"x");
  if(!defined($startx)){
    return undef;
  }
  my ($starty,$endy) = intersect($e1,$e2,"y");
  if(!defined($starty)){
    return undef;
  }
  my ($startz,$endz) = intersect($e1,$e2,"z");
  if(!defined($startz)){
    return undef;
  }
  my $entry;
  $entry->{"instruction"}=$e1->{"instruction"};
  $entry->{"x1"}=$startx;
  $entry->{"x2"}=$endx;
  $entry->{"y1"}=$starty;
  $entry->{"y2"}=$endy;
  $entry->{"z1"}=$startz;
  $entry->{"z2"}=$endz;
  
  #print "Overlap between ",format_instruction($e1)," and ",format_instruction($e2),", a cube ",format_instruction($entry)," with volume ",volume($entry),"\n";
  return $entry;
}

my %cube;
my $executed=0;
my $on=0;
my @done;
for my $instruction (@instructions){
  if($instruction->{"instruction"}){
    print "turning on ",volume($instruction)," because ",format_instruction($instruction),"\n";
    $on += volume($instruction);
    my @overlaps;
    my $diff=0;
    for my $done(@done){
      if($done->{"instruction"}){
        #we've turned something doubly on
        my $overlap = overlap($instruction, $done);
        if(defined($overlap)){
          print "will need to remove ",volume($overlap), " from ",format_instruction($overlap),"\n";
          $overlap->{"instruction"}=0;
          push(@overlaps, $overlap);
          $diff += volume($overlap);
          my @triple;
          for my $double(@overlaps){
            my $d_overlap = overlap($overlap, $double);
            if(defined($d_overlap)){
              print "Already removed ",format_instruction($double),"\n";
              $d_overlap->{"instruction"}=1;
              push(@triple, $d_overlap);
              $diff -= volume($d_overlap);
            }
          }
          die "too many overlapping ons" if(scalar(@triple)>1);
        }
      }
    }
    $on -= $diff;
  }
  else{
    print "turning off ",volume($instruction)," because ",format_instruction($instruction),"\n";
    for my $done(@done){
      if($done->{"instruction"}){
        #we're turning them off again
        $on -= volume(overlap($instruction, $done));
        
      }
    }
  }
  push(@done, $instruction);
  # check if we overlap with any others
  
  print $executed++, " run\n";
}
print "At the end: $on on\n";

#print Dumper(%cube);
