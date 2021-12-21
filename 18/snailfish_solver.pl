#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;

#gather input
my @lines;

while(my $line = <STDIN>){
  chomp($line);
  push (@lines, $line);
}
my $numrows=scalar(@lines);

print "$numrows numbers given\n";

sub parse_number_inner{
  my $r_chars = shift;
  my @chars = @{$r_chars};

  my $result;
  my $char = shift @chars;
  while(defined($char)) {
    print $char;
    if($char eq '['){
      my ($res, $r_chars) = parse_number_inner(\@chars);
      $result->{"left"} = $res;
      @chars = @{$r_chars}
    }
    elsif($char =~ /\d/){
      return ($char,\@chars);
    }
    elsif($char eq ','){
      my ($res, $r_chars) = parse_number_inner(\@chars);
      $result->{"right"} = $res;
      @chars = @{$r_chars}
    }
    elsif($char eq ']'){
      return ($result,\@chars);
    }
    $char = shift @chars;
  }
  
}
sub parse_number{
  my $number = shift;
  my $result;
  my @chars = split //, $number;
  my ($res, $r_chars) = parse_number_inner(\@chars);
  @chars = @{$r_chars};
  if(scalar(@chars)>0){
    die "got chars left: @chars\n";
  }
  print "\n";
  return $res;
}

sub explode{
  my $tree = shift;
  my $nest = shift;
  my $my_left = shift;
  my $my_right= shift;
  
#  print "Nesting $nest\n";
  my $left = $tree->{"left"};
  my $right = $tree->{"right"};

  if(ref($left)){
    my ($res, $act) = explode($tree->{"left"}, $nest+1, $my_left, \$tree->{"right"});
    $tree->{"left"} = $res;
    if($act > 0){
      return ($tree, $act);
    }
  }
  if(ref($right)){
#    print "right is ref\n";
    my ($res, $act) = explode($tree->{"right"}, $nest+1, \$tree->{"left"}, $my_right);
    $tree->{"right"} = $res;
    if($act > 0){
      return ($tree, $act);
    }
  }
  if($nest >= 4){
#    print "Explode! [$left,$right]\n";
    if(ref($left) || ref($right)){
      die "todo\n";
    }
    if(defined($my_left)){
#      print "On My Left: $$my_left\n";
      while(ref($$my_left)){
        $my_left = \$$my_left->{"right"};
#        print "On My Left: $$my_left\n";
      }
#      print "adding $left to $$my_left\n";
      $$my_left += $left;
    }
    else{
#      print("my left was undefined, $left discarded\n");
    }

    if(defined($my_right)){
#      print "On My Right: $$my_right\n";
      while(ref($$my_right)){
        $my_right = \$$my_right->{"left"};
#        print "On My Right: $$my_right\n";
      }
#      print "adding $right to $$my_right\n";
      $$my_right += $right;
    }
    else{
#      print("my right was undefined, $right discarded\n");
    }
    return (0,1);
    
  }
  return ($tree, 0);
}

sub splitter{
  my $tree = shift;
  
  my $left = $tree->{"left"};
  my $right = $tree->{"right"};
  if(ref($left)){
#    print "left is ref\n";
    my ($res, $act) = splitter($tree->{"left"});
    $tree->{"left"} = $res;
    if($act > 0){
      return ($tree, $act);
    }
  }
  elsif($left >= 10){
#    print "Need to split left $left\n";
    my $pair;
    $pair->{"left"} = int($left/2);
    $pair->{"right"} = int($left/2+0.5);
    $tree->{"left"} = $pair;
    return ($tree, 1);
  }
  if(ref($right)){
#    print "right is ref\n";
    my ($res, $act) = splitter($tree->{"right"});
    $tree->{"right"} = $res;
    if($act > 0){
      return ($tree, $act);
    }
  }
  elsif($right >= 10){
#    print "Need to split right $right\n";
    my $pair;
    $pair->{"left"} = int($right/2);
    $pair->{"right"} = int($right/2+0.5);
    $tree->{"right"} = $pair;
    return ($tree, 1);
  }
  return ($tree, 0);
}

sub reduce{
  my $tree = shift;
  # print "\t";
  # pretty_print($tree);
  # print "\n";

  my $actions;
  do{
    do{
      ($tree, $actions) = explode($tree, 0, undef, undef);
      # print "\t";
      # pretty_print($tree);
      # print "\n";
      
    }
    until($actions == 0);
    #if there's a splitter, we check for explodes again first.
    ($tree, $actions) = splitter($tree);
    # print "\t";
    # pretty_print($tree);
    # print "\n";
  }
  until($actions == 0);
  

  return $tree;
  
}

sub pretty_print{
  my $tree = shift;

  print "[";
  if(ref($tree->{"left"})){
    pretty_print($tree->{"left"});
  }
  else{
    print($tree->{"left"});
  }
  print ",";
  if(ref($tree->{"right"})){
    pretty_print($tree->{"right"});
  }
  else{
    print($tree->{"right"});
  }
  print "]";
}

sub magnitude{
  my $tree=shift;

  my $left = $tree->{"left"};
  my $right = $tree->{"right"};

  my $left_mag;
  my $right_mag;
  
  if(ref($left)){
    $left_mag = 3 * magnitude($tree->{"left"});
  }
  else{
    $left_mag = 3*$left;
  }
  if(ref($right)){
    $right_mag = 2 * magnitude($tree->{"right"});
  }
  else{
    $right_mag = 2*$right;
  }
  return $left_mag + $right_mag;
}
  

my $i=0;
my @trees;
for my $number (@lines){
  my $tree = parse_number($number);
  $tree = reduce($tree);
  push(@trees, $tree);
  #print Dumper($tree);
}

my $total = shift(@trees);
for my $tree (@trees){
  # print "  ";
  # pretty_print($total);
  # print "\n+ ";
  # pretty_print($tree);
  # print "\n= ";
  my $new;
  $new->{"left"} = $total;
  $new->{"right"} = $tree;
  $total = reduce($new);
  # pretty_print($total);
  # print "\n\n";
}


print "Sum: ";
pretty_print($total);
print "\n";

print "Magnitude: ", magnitude($total), "\n";
