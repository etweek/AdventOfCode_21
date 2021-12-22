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
  # next if(($startx < -50 && $endx < -50)||
  #         ($startx > 50 && $endx > 50)||
  #         ($starty < -50 && $endy < -50)||
  #         ($starty > 50 && $endy > 50)||
  #         ($startz < -50 && $endz < -50)||
  #         ($startz > 50 && $endz > 50));
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

sub make_key{
  my $el = shift;

  return "(".$el->{"x1"}.",".$el->{"y1"}.",".$el->{"z1"}."):(".$el->{"x2"}.",".$el->{"y2"}.",".$el->{"z2"}.")";
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
  
  #print "Overlap between ",format_instruction($e1)," and ",format_instruction($e2),", a box ",format_instruction($entry)," with volume ",volume($entry),"\n";
  return $entry;
}

sub split_box{
  my $to_split = shift;
  my $around = shift;

  print "Splitting ".make_key($to_split)." around ".make_key($around)."\n";
  my @outside;
  # start with the X axis
  if($to_split->{"x1"} < $around->{"x1"}){
    my $newbox;
    $newbox->{"instruction"}=$to_split->{"instruction"};
    $newbox->{"x1"}=$to_split->{"x1"};
    $newbox->{"x2"}=$around->{"x1"}-1;
    $newbox->{"y1"}=$to_split->{"y1"};
    $newbox->{"y2"}=$to_split->{"y2"};
    $newbox->{"z1"}=$to_split->{"z1"};
    $newbox->{"z2"}=$to_split->{"z2"};
    print "\tsplit X at ".$around->{"x1"}." leaving ".make_key($newbox)."\n";
    push(@outside,$newbox);
    #shink what's left
    $to_split->{"x1"}=$around->{"x1"};
  }
  if($to_split->{"x2"} > $around->{"x2"}){
    my $newbox;
    $newbox->{"instruction"}=$to_split->{"instruction"};
    $newbox->{"x1"}=$around->{"x2"}+1;
    $newbox->{"x2"}=$to_split->{"x2"};
    $newbox->{"y1"}=$to_split->{"y1"};
    $newbox->{"y2"}=$to_split->{"y2"};
    $newbox->{"z1"}=$to_split->{"z1"};
    $newbox->{"z2"}=$to_split->{"z2"};
    print "\tsplit X at ".$around->{"x2"}." leaving ".make_key($newbox)."\n";
    push(@outside,$newbox);
    #shink what's left
    $to_split->{"x2"}=$around->{"x2"};
  }
  # now the same for the y axis
  if($to_split->{"y1"} < $around->{"y1"}){
    my $newbox;
    $newbox->{"instruction"}=$to_split->{"instruction"};
    $newbox->{"x1"}=$to_split->{"x1"};
    $newbox->{"x2"}=$to_split->{"x2"};
    $newbox->{"y1"}=$to_split->{"y1"};
    $newbox->{"y2"}=$around->{"y1"}-1;
    $newbox->{"z1"}=$to_split->{"z1"};
    $newbox->{"z2"}=$to_split->{"z2"};
    print "\tsplit Y at ".$around->{"y1"}." leaving ".make_key($newbox)."\n";
    push(@outside,$newbox);
    #shink what's left
    $to_split->{"y1"}=$around->{"y1"};
  }
  if($to_split->{"y2"} > $around->{"y2"}){
    my $newbox;
    $newbox->{"instruction"}=$to_split->{"instruction"};
    $newbox->{"x1"}=$to_split->{"x1"};
    $newbox->{"x2"}=$to_split->{"x2"};
    $newbox->{"y1"}=$around->{"y2"}+1;
    $newbox->{"y2"}=$to_split->{"y2"};
    $newbox->{"z1"}=$to_split->{"z1"};
    $newbox->{"z2"}=$to_split->{"z2"};
    print "\tsplit Y at ".$around->{"y2"}." leaving ".make_key($newbox)."\n";
    push(@outside,$newbox);
    #shink what's left
    $to_split->{"y2"}=$around->{"y2"};
  }
  #finally z
  if($to_split->{"z1"} < $around->{"z1"}){
    my $newbox;
    $newbox->{"instruction"}=$to_split->{"instruction"};
    $newbox->{"x1"}=$to_split->{"x1"};
    $newbox->{"x2"}=$to_split->{"x2"};
    $newbox->{"y1"}=$to_split->{"y1"};
    $newbox->{"y2"}=$to_split->{"y2"};
    $newbox->{"z1"}=$to_split->{"z1"};
    $newbox->{"z2"}=$around->{"z1"}-1;
    print "\tsplit Z at ".$around->{"z1"}." leaving ".make_key($newbox)."\n";
    push(@outside,$newbox);
    #shink what's left
    $to_split->{"z1"}=$around->{"z1"};
  }
  if($to_split->{"z2"} > $around->{"z2"}){
    my $newbox;
    $newbox->{"instruction"}=$to_split->{"instruction"};
    $newbox->{"x1"}=$to_split->{"x1"};
    $newbox->{"x2"}=$to_split->{"x2"};
    $newbox->{"y1"}=$to_split->{"y1"};
    $newbox->{"y2"}=$to_split->{"y2"};
    $newbox->{"z1"}=$around->{"z2"}+1;
    $newbox->{"z2"}=$to_split->{"z2"};
    print "\tsplit Z at ".$around->{"z2"}." leaving ".make_key($newbox)."\n";
    push(@outside,$newbox);
    #shink what's left
    $to_split->{"z2"}=$around->{"z2"};
  }
  print "\t finally discarding ".make_key($to_split)."\n";

  # what's left in $to_split now is the discarded bit
  return @outside;
}

#### Main ####
my $on;
my $step=0;
for my $instruction (@instructions){
  # look for intersections
  my @additions = ($instruction);
  my $splits = 0;
  my @split_additions;
  for my $addition (@additions){
    $splits = 0;
    for my $key (keys(%$on)){
      my $value = $on->{$key};
      my $overlap = overlap($addition, $value);
      if(defined($overlap)){
        my $overlap_key = make_key($overlap);
        print "Overlap between ",format_instruction($addition)," and ",$key,", a box ",format_instruction($overlap)," with volume ",volume($overlap),"\n";
        # easy case if we've swallowed it:
        if($key eq $overlap_key){
          print format_instruction($addition)." swallows $key, removing";
          delete $on->{$key};
        }
        else{
          # can we leave the existing alone?
          if($addition->{"instruction"}){
            # yes, we can split the new entry into bits around the existing one
            # push it on the back of additions for re-processing
            push(@additions,split_box($addition,$value));
            $splits=1;
            # since we've split it, we need to stop the loop here and go again with the smaller parts.
            last;
          }
          else{
            # delete the old key, as we'll be adding new ones
            delete $on->{$key};
            # then split the existing one around our current box
            # put it straight on the result pile, as it won't be further split up.
            push(@split_additions,split_box($value, $addition));
          }
        }
      }
    }
    if($splits == 0 && $addition->{"instruction"}){
      push(@split_additions, $addition);
    }
  }
  @additions = @split_additions;

  for my $addition(@additions){
    $on->{make_key($addition)} = $addition;
  }
  
  print "after ",++$step," steps we have these on:\n";
  my $total=0;
  for my $key (keys(%$on)){
    my $volume = volume($on->{$key});
    print "\t$key\t",$volume,"\n";
    $total += $volume;
  }
  print "\tfor a total volume of: \t$total\n";
}
