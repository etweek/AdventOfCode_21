#!/opt/loca/bin/perl
use warnings;
use strict;
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

use List::Util qw(max min);

use Data::Dumper;
use Data::Compare;

#gather input
my $scanners;
my $current;
while(my $line = <STDIN>){
  chomp($line);
  next unless length($line)>3;
  if($line =~ /--- (scanner \d+) ---/){
    $current = $1;
    $scanners->{$current}->{"beacons"}=();
  }
  else{
    my ($x, $y, $z) = split(/,/,$line);
    my $beacon = {"x"=>$x,"y"=>$y,"z"=>$z};
    push(@{$scanners->{$current}->{"beacons"}}, $beacon);
  }
}


# calculate the difference vectors
sub difference{
  my $beacon1 = shift;
  my $beacon2 = shift;

  #print Dumper(($beacon1,$beacon2));

  my $xdiff = $beacon2->{"x"} - $beacon1->{"x"};
  $xdiff = $xdiff*$xdiff;
  my $ydiff = $beacon2->{"y"}-$beacon1->{"y"};
  $ydiff = $ydiff*$ydiff;
  my $zdiff = $beacon2->{"z"}-$beacon1->{"z"};
  $zdiff = $zdiff*$zdiff;

  my $sum = $xdiff + $ydiff + $zdiff;
  my $root = sqrt($sum);
  return $root;
}

sub calculate_differences{
  my $scanner = shift;
  my @beacons = @{$scanner->{"beacons"}};
  #$scanner->{"vectors"}=();
  # calculate the difference between any two beacons
  for(my $i=0; $i<$#beacons; $i++){
    for(my $j=$i+1; $j<=$#beacons; $j++){
      if($i != $j){
        my $difference = difference($beacons[$i], $beacons[$j]);
        #        print $difference,"\n";
        $scanner->{"vectors"}->{$difference}="$i:$j";
        #        push(@{$scanner->{"vectors"}}, $difference);
      }
    }
  }
}

my %allowed_rotations = ("x,y,z"=>1,
                         "x,-z,y"=>1,
                         "x,-y,-z"=>1,
                         "x,z,-y"=>1,
                         "y,-x,z"=>1,
                         "y,-z,-x"=>1,
                         "y,x,-z"=>1,
                         "y,z,x"=>1,
                         "-x,-y,z"=>1,
                         "-x,-z,-y"=>1,
                         "-x,y,-z"=>1,
                         "-x,z,y"=>1,
                         "-y,x,z"=>1,
                         "-y,-z,x"=>1,
                         "-y,-x,-z"=>1,
                         "-y,z,-x"=>1,
                         "z,x,y"=>1,
                         "z,y,-x"=>1,
                         "z,-x,-y"=>1,
                         "z,-y,x"=>1,
                         "-z,-y,-x"=>1,
                         "-z,x,-y"=>1,
                         "-z,y,x"=>1,
                         "-z,-x,y"=>1);

sub format_rotation{
  my $matrix = shift;

  return $matrix->{"x"}.",".$matrix->{"y"}.",".$matrix->{"z"};
}


sub compute_matrix{
  my $s1_diffs = shift;
  my $s2_diffs = shift;
  my $s1_beacon1 = shift;
  my $s1_beacon2 = shift;
  my $s2_beacon1 = shift;
  my $s2_beacon2 = shift;

  print "computing matrix to ".format_beacon($s1_beacon1)." from ".format_beacon($s2_beacon1)." checking against ".format_beacon($s1_beacon2)."->".format_beacon($s2_beacon2)."\n";
  my $matrix;
  my %taken;
  for my $dim1 ("x","y","z"){
    for my $dim2 ("x","y","z"){
      next if $taken{$dim2} || defined($matrix->{$dim1});
      if($s1_diffs->{$dim1} == $s2_diffs->{$dim2}){
        print "$dim1 matched to $dim2, offset to ";
        $matrix->{$dim1} = $dim2;
        $matrix->{$dim1."_offset"} =  $s1_beacon1->{$dim1} - $s2_beacon1->{$dim2};
        $taken{$dim2}=1;
        print $matrix->{$dim1."_offset"},"\n";

        unless($s1_beacon2->{$dim1} == ($s2_beacon2->{$dim2} + $matrix->{$dim1."_offset"})){
          print $dim1." conversion wrong\n";
          $matrix->{$dim1}="";
        }
      }
      elsif($s1_diffs->{$dim1} == -($s2_diffs->{$dim2})){
        print "$dim1 matched to -$dim2, offset to ";
        $matrix->{$dim1} = "-".$dim2;
        $matrix->{$dim1."_offset"} =  $s1_beacon1->{$dim1} + $s2_beacon1->{$dim2};
        $taken{$dim2}=1;
        print $matrix->{$dim1."_offset"},"\n";
        unless($s1_beacon2->{$dim1} == (-$s2_beacon2->{$dim2} + $matrix->{$dim1."_offset"})){
          print $dim1." (flipped) conversion wrong ".$s1_beacon2->{$dim1}."!=".(-$s2_beacon2->{$dim2})." + ".$matrix->{$dim1."_offset"}."\n" ;
          $matrix->{$dim1}="";
        }

      }
    }
  }

  return $matrix;

}
sub compute_union{
  my $scanner1 = shift;
  my $scanner2 = shift;

  my @s1_vectors = keys(%{$scanner1->{"vectors"}});

  my $result;
  $result->{"count"}=0;
  my $s1_indexes;
  my $s2_indexes;
  my @matrix_guesses;
  my @votes;
  for my $vector (@s1_vectors){
    #print "Looking for $vector\n";
    if(defined($scanner2->{"vectors"}->{$vector})){
      print $scanner1->{"vectors"}->{$vector},"->",$scanner2->{"vectors"}->{$vector},"\n";
      my ($s1_i1, $s1_i2) = split(/:/, $scanner1->{"vectors"}->{$vector});
      my $s1_beacon1 = ${$scanner1->{"beacons"}}[$s1_i1];
      my $s1_beacon2 = ${$scanner1->{"beacons"}}[$s1_i2];

      my ($s2_i1, $s2_i2) = split(/:/, $scanner2->{"vectors"}->{$vector});
      
      my $s2_beacon1 = ${$scanner2->{"beacons"}}[$s2_i1];
      my $s2_beacon2 = ${$scanner2->{"beacons"}}[$s2_i2];

      # So s1 beacon1 == s2 beacon1 or s2 beacon 2...
      # need to align thir vectors
      my $s1_diffs;
      $s1_diffs->{"x"}=$s1_beacon2->{"x"} - $s1_beacon1->{"x"};
      $s1_diffs->{"y"}=$s1_beacon2->{"y"} - $s1_beacon1->{"y"};
      $s1_diffs->{"z"}=$s1_beacon2->{"z"} - $s1_beacon1->{"z"};
      # if(($s1_diffs->{"x"} < 0 && $s1_diffs->{"y"} < 0) ||
      #    ($s1_diffs->{"x"} < 0 && $s1_diffs->{"z"} < 0) ||
      #    ($s1_diffs->{"y"} < 0 && $s1_diffs->{"z"} < 0)){
      #   # flip em
      #   my $temporary = $s1_beacon1;
      #   $s1_beacon1 = $s1_beacon2;
      #   $s1_beacon2 = $temporary;
      #   $s1_diffs->{"x"}=$s1_beacon2->{"x"} - $s1_beacon1->{"x"};
      #   $s1_diffs->{"y"}=$s1_beacon2->{"y"} - $s1_beacon1->{"y"};
      #   $s1_diffs->{"z"}=$s1_beacon2->{"z"} - $s1_beacon1->{"z"};
      # }
      my $s2_diffs;
      $s2_diffs->{"x"}=$s2_beacon2->{"x"} - $s2_beacon1->{"x"};
      $s2_diffs->{"y"}=$s2_beacon2->{"y"} - $s2_beacon1->{"y"};
      $s2_diffs->{"z"}=$s2_beacon2->{"z"} - $s2_beacon1->{"z"};

      print "s1: ",($s1_diffs->{"x"}),",",($s1_diffs->{"y"}),",",($s1_diffs->{"z"}),"\n";
      print "s2: ",($s2_diffs->{"x"}),",",($s2_diffs->{"y"}),",",($s2_diffs->{"z"}),"\n";
      # find a matching magnitude for all the parts
      my $matrix = compute_matrix($s1_diffs, $s2_diffs, $s1_beacon1, $s1_beacon2, $s2_beacon1, $s2_beacon2);
      # check it's legal.
      my $rotation = format_rotation($matrix);
      if(!defined($allowed_rotations{$rotation})){
        # try again
        print "chose an illegal rotation; $rotation\n";
        # flip em
        my $temporary = $s1_beacon1;
        $s1_beacon1 = $s1_beacon2;
        $s1_beacon2 = $temporary;
        $s1_diffs->{"x"}=$s1_beacon2->{"x"} - $s1_beacon1->{"x"};
        $s1_diffs->{"y"}=$s1_beacon2->{"y"} - $s1_beacon1->{"y"};
        $s1_diffs->{"z"}=$s1_beacon2->{"z"} - $s1_beacon1->{"z"};
        my $matrix = compute_matrix($s1_diffs, $s2_diffs, $s1_beacon1, $s1_beacon2, $s2_beacon1, $s2_beacon2);
        # check it's legal.
        my $rotation = format_rotation($matrix);
        if(!defined($allowed_rotations{$rotation})){
          
          print "chose an illegal rotation; $rotation\n";
          next;
        }
      }
      # looks like it worked, mark it down
      $s1_indexes->{$s1_i1}=1;
      $s1_indexes->{$s1_i2}=1;
      $s2_indexes->{$s2_i1}=1;
      $s2_indexes->{$s2_i2}=1;
      
      my $found=0;
      for(my $i=0; $i<=$#matrix_guesses; $i++){
        if(Compare($matrix_guesses[$i], $matrix)){
          print "$i was a match\n";
          $votes[$i]++;
          $found=1;
        }
      }
      if(!$found){
        push(@matrix_guesses, $matrix);
      }
#      print Dumper($matrix);
    }
  }
  print "There are ", scalar(@matrix_guesses), " attempts at a matrix\n";
  #  print Dumper(@matrix_guesses, @votes);
  my $highest_value=0;
  my $highest_index=-1;
  for(my $i=0; $i <= $#votes; $i++){
    if(defined($votes[$i]) && $votes[$i] > $highest_value){
      $highest_value = $votes[$i];
      $highest_index = $i;
    }
  }
  print "The best match was voted for $highest_value times\n";
  #print scalar(keys(%$s1_indexes)),", ", scalar(keys(%$s2_indexes)), "\n";
  $result->{"count"} = scalar(keys(%$s1_indexes));
  $result->{"matrix"} = $matrix_guesses[$highest_index];
  # check it
  # map all of set 2 to set 1
  if($result->{"count"} >= 12){
    my @failed;
    my %beacons;
    for my $index (keys(%$s1_indexes)){
      my $beacon = format_beacon(${$scanner1->{"beacons"}}[$index]);
      print $beacon,"\n";
      $beacons{$beacon}=1;
    }
    for my $index (keys(%$s2_indexes)){
      my $beacon = format_beacon(scanner_map(${$scanner2->{"beacons"}}[$index], $result->{"matrix"}));
      if(!defined($beacons{$beacon})){
        push(@failed, $index);
      }

    }
    if(scalar(@failed) > 0){
      print Dumper($result->{"matrix"}),"\n";
      die "Matrix failed check for ".scalar(@failed)." indexes ",@failed,"\n";

    }
#    print Dumper(@beacons1, @beacons2);
  }
    
  return $result;
}   

sub format_beacon{
  my $beacon = shift;
  return $beacon->{"x"}.",".$beacon->{"y"}.",".$beacon->{"z"}
}

sub scanner_map{
  my $beacon = shift;
  my $matrix = shift;
  my $new;

  for my $dim1 ("x","y","z"){
    for my $dim2 ("x","y","z"){
      if($matrix->{$dim1} eq $dim2){
        $new->{$dim1} = $beacon->{$dim2} + $matrix->{$dim1."_offset"};
      }
      elsif($matrix->{$dim1} eq "-".$dim2){
        $new->{$dim1} = -$beacon->{$dim2} + $matrix->{$dim1."_offset"};
      }
    }
  }
  print "mapped ",format_beacon($beacon), " to ", format_beacon($new),"\n";
  return $new;

}

my @scannernames = sort keys(%$scanners);
for my $scanner (@scannernames){
  calculate_differences($scanners->{$scanner});
}

my $matrices;
my $first_scanner=shift(@scannernames);
my $total=scalar(@{$scanners->{$first_scanner}->{"beacons"}});
my $beacons;
for my $beacon (@{$scanners->{$first_scanner}->{"beacons"}}){
  $beacons->{format_beacon($beacon)} = 1;
}
while(scalar(@scannernames) > 0){
  my $scannername = shift(@scannernames);
  #  for (my $j=$i+1; $j <= $#scannernames; $j++){
  print "\t\tConsidering ",$first_scanner,"<->",$scannername,"\n";
  
  #$total = $total + scalar(@{$scanners->{$scannernames[$j]}->{"beacons"}});
  my $common = compute_union($scanners->{$first_scanner}, $scanners->{$scannername});
  print $first_scanner,"<->",$scannername,": ",$common->{"count"},"\n";
  if($common->{"count"} >= 12){
    $total += scalar(@{$scanners->{$scannername}->{"beacons"}});
    $total -= $common->{"count"};
    print "removing ",$common->{"count"},"\n";
    
    $matrices->{$scannername}->{$first_scanner}=$common->{"matrix"};
    print Dumper($common->{"matrix"});
    for my $beacon (@{$scanners->{$scannername}->{"beacons"}}){
      $beacon = scanner_map($beacon, $common->{"matrix"});
      # add it to the first scanners'
      push(@{$scanners->{$first_scanner}->{"beacons"}}, $beacon);
      $beacons->{format_beacon($beacon)}++;
    }
    #recalculate scanner 0
    calculate_differences($scanners->{$first_scanner});
  }
  else{
    # push it back for later
    push(@scannernames,$scannername);
  }
}
print Dumper($beacons);
print "$total beacons == ",scalar(keys(%$beacons)), " unique beacons\n";
#print Dumper($matrices);



#print Dumper($scanners);

#print difference(${$scanners->{"scanner 0"}->{"beacons"}}[0], ${$scanners->{"scanner 0"}->{"beacons"}}[1]),"\n";
#print difference(${$scanners->{"scanner 1"}->{"beacons"}}[0], ${$scanners->{"scanner 1"}->{"beacons"}}[1]),"\n";
