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

sub array_equals{
  my $a = shift;
  my $b = shift;
  my @arrA = @{$a};
  my @arrB = @{$b};
  my $lenA = scalar(@arrA);
  my $lenB = scalar(@arrB);
  if($lenA != $lenB){
    return 0;
  }
  else{
    for(my $i = 0;$i < $lenA; $i++){
      if($arrA[$i] ne $arrB[$i]){
        return 0;
      }
    }
    return 1;
  }
}
 
sub array_contains_array{
  my $array_ref = shift;
  my $element_ref = shift;
  my @array = @{$array_ref};
  for my $element (@array){
    if(array_equals($element,$element_ref)){
      return 1;
    }
  }
  return 0;
}

sub array_contains_element{
  my $array_ref = shift;
  my $element_ref = shift;
  my @array = @{$array_ref};
  for my $element (@array){
    if($element_ref eq $element){
      return 1;
    }
  }
  return 0;
}

sub is_upper{
  my $str = shift;
  return $str eq uc $str;
}

sub add_links{
  my $link_array_ref = shift;
  my $path_ref = shift;
  my @link_array = @{$link_array_ref};
  my @path_array = @{$path_ref};

  for my $link (@link_array){
    my ($source, $target)=@{$link};
    if($source eq "start"){
      my @chain = ($source,$target);
      if(!array_contains_array(\@path_array, \@chain)){
        push(@path_array,\@chain);
      }
    }
    elsif($target eq "start"){
      my @chain = ($target,$source);
      if(!array_contains_array(\@path_array, \@chain)){
        push(@path_array,\@chain);
      }
    }
    for my $path (@path_array){
      my @chain = @{$path};
      if($chain[-1] ne "end"){
        if($chain[-1] eq $source && $source ne "end"){
          if(!array_contains_element(\@chain,$target) || is_upper($target)){
            my @new_chain = @chain;
            push(@new_chain, $target);
            if(!array_contains_array(\@path_array, \@new_chain)){
              push(@path_array,\@new_chain);
            }
          }
        }
        # check reverse
        if($chain[-1] eq $target && $target ne "end"){
          if(!array_contains_element(\@chain,$source) || is_upper($source)){
            my @new_chain = @chain;
            push(@new_chain, $source);
            if(!array_contains_array(\@path_array, \@new_chain)){
              push(@path_array,\@new_chain);
            }
          }
        }

      }
    }
  }
  return \@path_array;
}

sub print_path{
  my $path_ref = shift;
  my @path=@{$path_ref};
  print join("->",@path);
  print "\n";
}
sub print_paths{
  my $paths_ref = shift;
  my @paths=@{$paths_ref};
  for my $path (@paths){
    print_path($path);
  }
  
}

sub prune{
  my $path_array_ref = shift;
  my @path_array = @{$path_array_ref};
  my @result_array;
  for my $path_ref (@path_array){
    my @path = @{$path_ref};
    if($path[-1] eq "end"){
      push(@result_array, \@path);
    }
  }
  return \@result_array
}
 
my @paths;
my $number_of_paths = scalar(@paths);
@paths = @{add_links(\@links, \@paths)};
print scalar(@paths), " found\n";
print_paths(\@paths);

while(scalar(@paths) != $number_of_paths){
  $number_of_paths = scalar(@paths);
  @paths = @{add_links(\@links, \@paths)};
  print scalar(@paths), " found\n";
}

@paths = @{prune(\@paths)};
print_paths(\@paths);
print scalar(@paths), " to end found\n";

# my @test = ("start", "A","b","end");
# if(array_contains_array(\@paths, \@test)){
#   print "found test\n";
# }


