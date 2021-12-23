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
while(my $line = <STDIN>){
  if($line =~ /###(\w)#(\w)#(\w)#(\w)###/){
    $starting_state->{"r_1_0"}=$1;
    $starting_state->{"r_2_0"}=$2;
    $starting_state->{"r_3_0"}=$3;
    $starting_state->{"r_4_0"}=$4;
  }
  elsif($line =~ /  #(\w)#(\w)#(\w)#(\w)#/){
    $starting_state->{"r_1_1"}=$1;
    $starting_state->{"r_2_1"}=$2;
    $starting_state->{"r_3_1"}=$3;
    $starting_state->{"r_4_1"}=$4;
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
  if(defined($state->{"r_1_0"})){$count{$state->{"r_1_0"}}++};
  if(defined($state->{"r_1_1"})){$count{$state->{"r_1_1"}}++};
  if(defined($state->{"r_2_0"})){$count{$state->{"r_2_0"}}++};
  if(defined($state->{"r_2_1"})){$count{$state->{"r_2_1"}}++};
  if(defined($state->{"r_3_0"})){$count{$state->{"r_3_0"}}++};
  if(defined($state->{"r_3_1"})){$count{$state->{"r_3_1"}}++};
  if(defined($state->{"r_4_0"})){$count{$state->{"r_4_0"}}++};
  if(defined($state->{"r_4_1"})){$count{$state->{"r_4_1"}}++};
  for my $key (keys(%count)){
    if($count{$key} != 2){
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
  printf("###%s#%s#%s#%s###\n",    
         defined($state->{"r_1_0"})?$state->{"r_1_0"}:'.', 
         defined($state->{"r_2_0"})?$state->{"r_2_0"}:'.',  
         defined($state->{"r_3_0"})?$state->{"r_3_0"}:'.', 
         defined($state->{"r_4_0"})?$state->{"r_4_0"}:'.');
  printf("  #%s#%s#%s#%s#  \n",    
         defined($state->{"r_1_1"})?$state->{"r_1_1"}:'.', 
         defined($state->{"r_2_1"})?$state->{"r_2_1"}:'.',  
         defined($state->{"r_3_1"})?$state->{"r_3_1"}:'.', 
         defined($state->{"r_4_1"})?$state->{"r_4_1"}:'.');
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
  for my $element ($state->{"r_1_0"}, $state->{"r_2_0"},  $state->{"r_3_0"}, $state->{"r_4_0"},$state->{"r_1_1"}, $state->{"r_2_1"},  $state->{"r_3_1"}, $state->{"r_4_1"}){
    if(defined($element)){
      $result .= $element;
    }
    else{
      $result .= ".";
    }
  }
  return $result;
}

sub clone_state{
  my $state = shift;
  my $new_state = shift;
  $new_state->{"r_1_0"}=$state->{"r_1_0"};
  $new_state->{"r_2_0"}=$state->{"r_2_0"};
  $new_state->{"r_3_0"}=$state->{"r_3_0"};
  $new_state->{"r_4_0"}=$state->{"r_4_0"};
  $new_state->{"r_1_1"}=$state->{"r_1_1"};
  $new_state->{"r_2_1"}=$state->{"r_2_1"};
  $new_state->{"r_3_1"}=$state->{"r_3_1"};
  $new_state->{"r_4_1"}=$state->{"r_4_1"};
  $new_state->{"hall"}=();#$state->{"hall"};
  $new_state->{"cost"}=$state->{"cost"};
  for(my $i=0;$i<=10;$i++){
    ${$new_state->{"hall"}}[$i] = ${$state->{"hall"}}[$i];
  }
#  print "Cloned state, hall is ", $new_state->{"hall"},"\n";
  return $new_state;
}

  
sub is_complete{
  my $state = shift;
  if(defined($state->{"r_1_0"}) && $state->{"r_1_0"} eq 'A' &&
     defined($state->{"r_2_0"}) && $state->{"r_2_0"} eq 'B' &&
     defined($state->{"r_3_0"}) && $state->{"r_3_0"} eq 'C' &&
     defined($state->{"r_4_0"}) && $state->{"r_4_0"} eq 'D' &&
     defined($state->{"r_1_1"}) && $state->{"r_1_1"} eq 'A' &&
     defined($state->{"r_2_1"}) && $state->{"r_2_1"} eq 'B' &&
     defined($state->{"r_3_1"}) && $state->{"r_3_1"} eq 'C' &&
     defined($state->{"r_4_1"}) && $state->{"r_4_1"} eq 'D'){
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
    if($s_o == 1 && defined($state->{"r_".$s_r."_0"})){
      # there's someone above us inthe room
      return -1;
    }
    $distance=$s_o+1;
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
    if($t_o == 1 && defined($state->{"r_".$t_r."_0"})){
      # there's someone above us in the room
      print "r_".$t_r."_0 occupied\n";
      return -1;
    }
    $distance+=$t_o+1;
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
        my $target0 = "r_".$target."_0";
        my $target1 = "r_".$target."_1";
        my $hall_o = "h_".$i;
        my $distance1 = path_clear($state, $hall_o, $target1);
        my $distance0 = path_clear($state, $hall_o, $target0);
        print "checking whether $type can move from $hall_o to $target0($distance0) or $target1 ($distance1)\n";
        if(!defined($state->{$target1}) && $distance1 > 0){
          print "it can move straight in $distance1\n";
          # can move straight in
          # compute the cost to move
          my $new_state = clone_state($state);
          $new_state->{$target1}=$type;
          ${$new_state->{"hall"}}[$i]=undef;
          $new_state->{"cost"}+=$distance1*$move_cost{$type};
          my $key = mini_state($new_state);
          if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
            $considered{$key}=$new_state->{"cost"};
            check_state($new_state);
            push(@new_states, $new_state);
          }
        }
        elsif(defined($state->{$target1}) && $state->{$target1} eq $type && !defined($state->{$target0}) && $distance0 > 0){
          print "it can move in and complete the room ($distance0)\n";
          # this'll complete the room!
          my $new_state = clone_state($state);
          $new_state->{$target0}=$type;
          ${$new_state->{"hall"}}[$i]=undef;
          $new_state->{"cost"}+=$distance0*$move_cost{$type};
          my $key = mini_state($new_state);
          if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
            $considered{$key}=$new_state->{"cost"};
            check_state($new_state);
            push(@new_states, $new_state);
          }
        }
      }
    }
    
    # Then consider the rooms, left to right
    for my $room (1..4){
      my $room0 = "r_".$room."_0";
      my $room1 = "r_".$room."_1";
      # bottom bunk first
      if(!defined($state->{$room0}) && defined($state->{$room1}) && $state->{$room1} ne $occ{$room}){
        print "need to shift ",$state->{$room1}," out of $room0...";
        # is the target free?
        my $type   = $state->{$room1};
        my $target = $target_room{$type};
        my $target0 = "r_".$target."_0";
        my $target1 = "r_".$target."_1";
        
        my $distance1 = path_clear($state, $room1, $target1);
        my $distance0 = path_clear($state, $room1, $target0);
        if(!defined($state->{$target1}) && $distance1 > 0){
          print "bottom bunk can move straight in ($distance1)\n";
          # can move straight in
          # compute the cost to move
          my $new_state = clone_state($state);
          $new_state->{$target1}=$type;
          $new_state->{$room1}=undef;
          $new_state->{"cost"}+=$distance1*$move_cost{$type};
          my $key = mini_state($new_state);
          if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
            $considered{$key}=$new_state->{"cost"};
            check_state($new_state);
            push(@new_states, $new_state);
          }
        }
        elsif(defined($state->{$target1}) && $state->{$target1} eq $type && !defined($state->{$target0}) && $distance0 > 0){
          print "bottom bunk can move in and complete the room (distance0)\n";
          # this'll complete the room!
          my $new_state = clone_state($state);
          $new_state->{$target0}=$type;
          $new_state->{$room1}=undef;
          $new_state->{"cost"}+=$distance0*$move_cost{$type};
          my $key = mini_state($new_state);
          if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
            $considered{$key}=$new_state->{"cost"};
            check_state($new_state);
            push(@new_states, $new_state);
          }
        }
        else{
          print "target room not ready, move to hallway\n";
          # up to ten new states
          for(my $i=0; $i <= 10; $i++){
            next if($i==2||$i==4||$i==6||$i==8); # can't occupy those spaces
            my $distance = path_clear($state, $room1, "h_".$i);
            if($distance > 0){
              my $new_state = clone_state($state);
#              print "putting $type in $i ($distance away)\n";
              ${$new_state->{"hall"}}[$i]=$type; # place it where it's going
              $new_state->{$room1}=undef; #clear the room
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
      }
      elsif(defined($state->{$room0}) && ($state->{$room1} ne $occ{$room} ||
                                          $state->{$room0} ne $occ{$room})){ # the one on top needs to move
        print "need to shift ",$state->{$room0}," out of $room0...";
        # is the target free?
        my $type   = $state->{$room0};
        my $target = $target_room{$type};
        my $target0 = "r_".$target."_0";
        my $target1 = "r_".$target."_1";
        my $distance1=-1;
        my $distance0=-1;
        if($target !=  $room){
          # only move to target if we're not already there
          $distance1 = path_clear($state, $room0, $target1);
          $distance0 = path_clear($state, $room0, $target0);
        }
        if(!defined($state->{$target1}) && $distance1 > 0){
          print "top bunk can move straight in (distance1)\n";
          # can move straight in
          # compute the cost to move
          my $new_state = clone_state($state);
          $new_state->{$target1}=$type;
          $new_state->{$room0}=undef;
          $new_state->{"cost"}+=$distance1*$move_cost{$type};
          my $key = mini_state($new_state);
          if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
            $considered{$key}=$new_state->{"cost"};
            check_state($new_state);
            push(@new_states, $new_state);
          }
        }
        elsif(defined($state->{$target1}) && $state->{$target1} eq $type && !defined($state->{$target0}) && $distance0 > 0){
          print "top bunk can move in and complete the room (distance0)\n";
          # this'll complete the room!
          my $new_state = clone_state($state);
          $new_state->{$target0}=$type;
          $new_state->{$room0}=undef;
          $new_state->{"cost"}+=$distance0*$move_cost{$type};
          my $key = mini_state($new_state);
          if(!defined($considered{$key}) || $considered{$key} > $new_state->{"cost"}){
            $considered{$key}=$new_state->{"cost"};
            check_state($new_state);
            push(@new_states, $new_state);
          }
        }
        else{
          print "target room not ready, move to hallway\n";
          # up to ten new states
          for(my $i=0; $i <= 10; $i++){
            next if($i==2||$i==4||$i==6||$i==8); # can't occupy those spaces
            my $distance = path_clear($state, $room0, "h_".$i);
            if($distance > 0){
              print "$type can move from $room0 to h_$i at distance $distance\n";
              my $new_state = clone_state($state);
#              print "putting $type in $i ($distance away)\n";
              ${$new_state->{"hall"}}[$i]=$type; # place it where it's going
              $new_state->{$room0}=undef; #clear the room
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
      }
    }
  }
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



