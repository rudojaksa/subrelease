# HANDLING EXCLUDE PATTERNS

# parse exclude lines: space-split, but keep quoted ones; keep the order
sub parse_excluded {
  my @new;			# output: new per-pattern array
  my $i=1;			# index of quoted patterns
  for my $line (@{$_[0]}) {	# input: raw EXCLUDE lines of patterns

    # save quoted patterns
    my @quoted; @quoted[$i++]=$1 while $line=~s/"([^"]*)"/__QTD${i}__/;

    # space-split every EXCLUDE line
    for my $pat (split(/ /,$line)) {
      $pat=$quoted[$1] if $pat=~/^__QTD([0-9]+)__$/; 
      next if $pat eq "";
      push @new,$pat }}

  return \@new }

# return only patterns which match some file in current working directory, input=patterns
# TODO: load cwd tree only once, and per-pattern parse using perl regex
sub valid_excluded {
  my %valid;			# output hash: how many files/dirs are found per pattern
  for my $pat (@{$_[0]}) {

    # fixed pattern for the -path variant
    my $fix=$pat;
       $fix="$fix*" if not $pat=~/\*$/;
       $fix="*$fix" if not $pat=~/^\*/;
 
    my @found; # list of found files/paths
    if($pat=~/\//) { @found = split /\n/,`find . -path '$fix'` }
    else	   { @found = split /\n/,`find . -name '$pat'` }
    # print "$#found $pat: @found\n";
    $valid{$pat} = $#found+1; }

  return %valid }

# filter_excluded(\@patterns,\%valid) return only the valid patterns
sub filter_excluded {
  my @new;
  for my $pat (@{$_[0]}) {
    next if not $_[1]->{$pat};
    push @new,$pat }
  return \@new }

# print_excluded(\@patterns,\%valid) return verbose patterns string
sub print_excluded {
  my $s;
  for my $pat (@{$_[0]}) {
    if   ($_[1]->{$pat}==0) { $s .= "$CK_$pat$CD_ " }	# black - none
    elsif($_[1]->{$pat}==1) { $s .= "$CG_$pat$CD_ " }	# green - one
    else		    { $s .= "$CR_$pat$CD_ " }}	#   red - more
  $s =~ s/ $//;
  return $s }

# R.Jaksa 2024 GPLv3
