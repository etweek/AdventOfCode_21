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

my $starting_state;
my $index=0;
while(my $line = <STDIN>){
  if($line =~ /###(\w)#(\w)#(\w)#(\w)###/){
    ${$starting_state->{1}}[$index]=$1;
    ${$starting_state->{2}}[$index]=$2;
    ${$starting_state->{3}}[$index]=$3;
    ${$starting_state->{4}}[$index]=$4;
    $index++;
  }
  elsif($line =~ /  #(\w)#(\w)#(\w)#(\w)#/){
    ${$starting_state->{1}}[$index]=$1;
    ${$starting_state->{2}}[$index]=$2;
    ${$starting_state->{3}}[$index]=$3;
    ${$starting_state->{4}}[$index]=$4;
    $index++;
  }
}
$starting_state->{"hall"}=();
$starting_state->{"cost"}=0;
$starting_state->{"history"}=();

sub check_state{
  my $state = shift;
  my %count;
  $count{'A'}=0;
  $count{'B'}=0;
  $count{'C'}=0;
  $count{'D'}=0;
  
  for(my $i=0;$i<=10;$i++){
    if(defined(${$state->{"hall"}}[$i])){
#      print ${$state->{"hall"}}[$i], " found\n";
      $count{${$state->{"hall"}}[$i]}++;
    }
  }
  for my $room (1..4){
    for my $bunk (0..3){
      if(defined(${$state->{$room}}[$bunk])){$count{${$state->{$room}}[$bunk]}++};
    }
  }
  for my $key (keys(%count)){
    if($count{$key} != 4){
      print "Doesn't look right for $key:\n";
      print_state($state);
      die "Invalid state for $key=".$count{$key}
    }
  }
}
  
sub print_state{
  my $state = shift;
  print "#############\n";
  print "#";
  for(my $i=0;$i<=10;$i++){
    if(defined(${$state->{"hall"}}[$i])){
      print(${$state->{"hall"}}[$i]);
    }
    else{
      print ".";
    }
  }
  print "#\n";
  for my $bunk (0..3){
    if($bunk == 0){print "###"}
    else{print "  #"}
    for my $room (1..4){
      if(defined(${$state->{$room}}[$bunk])){print ${$state->{$room}}[$bunk]}
      else{print "."}
      print "#";
    }
    if($bunk == 0){print "##\n"}
    else{print "\n"}
  }
  print "  #########\n";
}

sub mini_state{
  my $state = shift;
  my $result;

  for(my $i=0;$i<=10;$i++){
    if(defined(${$state->{"hall"}}[$i])){
      $result .= ${$state->{"hall"}}[$i];
    }
    else{
      $result .= ".";
    }
  }
  for my $room (1..4){
    for my $bunk (0..3){
      if(defined(${$state->{$room}}[$bunk])){$result .= ${$state->{$room}}[$bunk]}
      else{$result .= "."}
    }
  }

  return $result;
}

sub clone_state{
  my $state = shift;
  my $new_state = shift;
  for my $room (1..4){
    for my $bunk (0..3){
      ${$new_state->{$room}}[$bunk] = ${$state->{$room}}[$bunk];
    }
  }
  $new_state->{"hall"}=();
  $new_state->{"cost"}=$state->{"cost"};
  for(my $i=0;$i<=10;$i++){
    ${$new_state->{"hall"}}[$i] = ${$state->{"hall"}}[$i];
  }
  return $new_state;
}

sub is_full{
  my $aref = shift;
  my $type = shift;
  #print "checking $type in ",join("",@$aref),"\n";
  for my $bunk (3,2,1,0){
    if(!defined(${$aref}[$bunk])){
      # empty, so there's space
      return 0;
    }
    elsif(${$aref}[$bunk] ne $type){
      # occupied by someone who shouldn't be here
      return -1;
    }
  }
  return 1;
}

sub is_available{
  my $aref = shift;
  my $type = shift;

  for my $bunk (3,2,1,0){
    if(defined(${$aref}[$bunk]) && ${$aref}[$bunk] ne $type){
      return -1;
    }
    elsif(!defined(${$aref}[$bunk])){
      # this one's free!
      return $bunk;
    }
  }
  die "Shouldn't have got here, $type and ".join(",",@$aref);
}
  

sub is_complete{
  my $state = shift;
  if (is_full($state->{1},'A')>0 &&
      is_full($state->{2},'B')>0 &&
      is_full($state->{3},'C')>0 &&
      is_full($state->{4},'D')>0){
    return 1;
  }
  else{
    return 0;
  }
}

sub path_clear{
  my $state  = shift;
  my $source = shift;
  my $target = shift;

  my $distance=0;
  # walk the path, as a side-effect compute the distance
  # room and offset
  my ($s_r,$s_o);
  if($source =~ /r_(\d)_(\d)/){
    $s_r=int($1);
    $s_o=int($2);
  }
  elsif($source =~ /h_(\d+)$/){
    $s_r='h';
    $s_o=int($1);
  }
  else{
    die "unknown $source\n";
  }
  my ($t_r,$t_o);
  if($target =~ /r_(\d)_(\d)/){
    $t_r=int($1);
    $t_o=int($2);
  }
  elsif($target =~ /h_(\d+)$/){
    $t_r='h';
    $t_o=int($1);
  }
  else{
    die "unknown $target\n";
  }

  if($s_r ne 'h'){
    #move it into the hallway
    while($s_o > 0){
      $s_o--;
      $distance+=1;
      if(defined(${$state->{$s_r}}[$s_o])){
        # there's someone in a bunk above
        return -1;
      }
    }
    $distance+=1;
    $s_o=$s_r*2;
    $s_r='h';
  }
  # how far along the hallway do we need to move
  my $off = $t_o;
  if($t_r ne 'h'){
    $off = $t_r*2;
  }
  # are we going right or left?
  #print "moving from $s_o to $off";
  my $direction = ($off > $s_o)?1:-1;
  while($s_o != $off){
    #print ".";
    $distance += 1;
    $s_o += $direction;
    if(defined(${$state->{"hall"}}[$s_o])){
      # occupied!
      print "hall ".$s_o." occupied\n";
      return -1;
    }
  }
  if($t_r ne 'h'){
    # move into the room
    $s_o=0;
    $distance += 1;
    while($s_o < $t_o){
      if(defined(${$state->{$t_r}}[$s_o])){
        # there's someone in a bunk above
        return -1;
      }
      $s_o++;
      $distance+=1;
    }
  }
  return $distance;
}

my %considered;
my %target_room=('A'=>1,'B'=>2, 'C'=>3, 'D'=>4);
my %occ=(1=>'A',2=>'B',3=>'C',4=>'D');
my %move_cost=('A'=>1,'B'=>10,'C'=>100,'D'=>1000);
my @states;

sub compute_new_states{
  my @current_states = sort {$a->{"cost"} <=> $b->{"cost"}} @states;
  my @new_states;

  for my $state (@current_states){
    print "Considering: ",$state->{"cost"},"\n";
    print_state($state);
    if(is_complete($state)){
      print "We're done\n";
      print "cost was ",$state->{"cost"},"\n";
      exit 0;
    }

    # consider the hallway first, can any in there move to their destination?
    for(my $i=0;$i<=10;$i++){
      if(defined(${$state->{"hall"}}[$i])){
        # check it
        my $type   = ${$state->{"hall"}}[$i];
        my $target = $target_room{$type};
        my $bunk = is_available($state->{$target},$type);
        if($bunk > -1){
          my $target_bunk = "r_".$target."_".$bunk;
          my $hall_o = "h_".$i;
          print "checking whether $type can move from $hall_o to $target_bunk...";
          my $distance_bunk = path_clear($state, $hall_o, $target_bunk);
          print $distance_bunk,"\n";
          if(!defined(${$state->{$target}}[$bunk]) && $distance_bunk > 0){
            # build up the new state for when it's done so.
            my $new_state = clone_state($state);
            # move from the hall to the target bunk
            ${$new_state->{$target}}[$bunk]= $type;
            ${$new_state->{"hall"}}[$i]    = undef;
            # add in the cost of moving
            $new_state->{"cost"}+=$distance_bunk*$move_cost{$type};
            # check if we've explored this already
            my $key = mini_state($new_state);
            if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
              $considered{$key}=$new_state->{"cost"};
              # I've made some mistakes before, this is a safeguard
              check_state($new_state);
              push(@new_states, $new_state);
            }
          }
        }
      }
    }
    
    # Then consider the rooms, left to right
    for my $room (1..4){
      # do we need to do anything?
      my $aref = $state->{$room};
      my $fullness = is_full($aref, $occ{$room});
      # if it's full, then nothing to do here
#      print "$room is $fullness full\n";
      next if($fullness == 1);
      # if it's not full, but everyone belongs we don't need to do anything either
      next if($fullness == 0);
      # find the first moveable
      my @bunks = @$aref;
      for my $bunk (0..3){
        if(defined($bunks[$bunk])){
          my $source_bunk = "r_".$room."_".$bunk;
          my $type = $bunks[$bunk];
          print "need to shift ",$type," out of $source_bunk...";
          # is the target free?
          my $target = $target_room{$type};
          my $target_i = is_available($state->{$target},$type);
          if($target_i > -1){
            my $target_bunk = "r_".$target."_".$target_i;
            print "checking whether $type can move from $source_bunk to $target_bunk...";
            my $distance_bunk = path_clear($state, $source_bunk, $target_bunk);
            print $distance_bunk,"\n";
            if(!defined(${$state->{$target}}[$target_i]) && $distance_bunk > 0){
              # build up the new state for when it's done so.
              my $new_state = clone_state($state);
              # move from the hall to the target bunk
              ${$new_state->{$target}}[$target_i] = $type;
              ${$new_state->{$room}}[$bunk]       = undef;
              # add in the cost of moving
              $new_state->{"cost"}+=$distance_bunk*$move_cost{$type};
              # check if we've explored this already
              my $key = mini_state($new_state);
              if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
                $considered{$key}=$new_state->{"cost"};
                # I've made some mistakes before, this is a safeguard
                check_state($new_state);
                push(@new_states, $new_state);
              }
            }
          }
          else{
            print "target room not ready, move to hallway\n";
            # up to ten new states
            for(my $i=0; $i <= 10; $i++){
              next if($i==2||$i==4||$i==6||$i==8); # can't occupy those spaces
              my $distance = path_clear($state, $source_bunk, "h_".$i);
              if($distance > 0){
                my $new_state = clone_state($state);
                print "moving $type from $source_bunk to h_$i ($distance away)\n";
                ${$new_state->{"hall"}}[$i]   = $type; # place it where it's going
                ${$new_state->{$room}}[$bunk] = undef; #clear the room
                $new_state->{"cost"}+=$distance*$move_cost{$type};
                my $key = mini_state($new_state);
                if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
                  $considered{$key}=$new_state->{"cost"};
                  check_state($new_state);
                  push(@new_states, $new_state);
                }
              }
            }
          }
          # if we found an occupied bunk, then don't look on the bunks below, that's
          # for the next round
          print "done with room $room after bunk $bunk\n";
          last;
        } #if the bunk was occupied
      }# for all the bunks
    }#for all rooms
  }#for all states
  return @new_states;
} 

print_state($starting_state);

# can get to the starting position at no cost
$considered{mini_state($starting_state)}=0;
push(@states, $starting_state);

my $round=1;
while(scalar(@states)>0){
  print "############################ Round $round ####################################\n";
  @states = compute_new_states();
  print scalar(@states), " states to consider next time\n";
  $round++;
}



