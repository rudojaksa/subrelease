{ # CUSTOM PRINTING

my $HDRLEN=20;

# filename in path to green if file exists
my sub greenfn { my $s=$_[0]; $s=~s/\/([^\/]*)$/\/$CG_$1$CD_/ if -e $s; return $s; }
# filename in path to green if file exists and to default if not
my sub defgrfn { my ($s,$c)=($_[0],$CD_); $c=$CG_ if -e $s; $s=~s/\/([^\/]*)$/\/$c$1$CD_/; return $s; }

# return filling space for given key
my sub hspace { return " " x ($HDRLEN - esclen $_[0]); }

# print helper
my sub prnt_ { my ($c1,$c2,$k,$v,$c) = @_;
  return if $QUIET;
  my $sp = hspace $k;			# spacing
  print "$c1$sp$k$CD_: $c2$v$CD_";	# key: value
  print " $CK_$c$CD_" if defined $c;	# comment
  print "\n"; }				# \n

# prnt "key",$var,"comment";
our sub prnt   { prnt_ "",$CD_,@_ }				# default color
our sub prntg  { prnt_ "",$CG_,@_ }				# green
our sub prntr  { prnt_ $CR_,$CR_,@_ }				# red
our sub prntfn { prnt_ "",$CK_,$_[0],defgrfn($_[1]),$_[2]; }	# filename debug

# debug "key",$var,"comment";
our sub debug	{ prnt_ $CC_,$CD_,@_ if $DEBUG }
# filename debug
our sub debugfn	{ prnt_ $CC_,$CK_,$_[0],greenfn($_[1]),$_[2] if $DEBUG }

# print fatal error message, and exit
our sub fatal { prnt_ $CR_,$CR_,"fatal",@_; prnt; exit }
our sub fatal2 { print "$CR_$_[0]$CD_\n"; exit }

# print the logo (three lines)
our sub prnt_logo {
  return if $QUIET;
  prnt;
  print hspace $_[0];
  print "$CC_$_[0]$CD_$_[1]$CC_$_[2]$CD_\n";
  prnt; }

# ---------------------------------------------------------------------------------------- HASH DEBUG

# for explicit order of keys
my @ORDER = ("file","language","package","project","version","subversion","next","variant",
	     "pkgname","fullname","major","minor","mtype","delimiter","dot","pwd","config2",
	     "config1","config","tmpdir","tgzdir","suffix","authors","caption","always",
	     "onsubrelease","onrelease","exclude");

# prel $key,$val,$msg; prints single element for debughash
my sub prel {
  if($_[0] eq "..")  { prnt_ $CW_,$CW_,""   ,$_[1],$_[2] }
  elsif($_[0] eq "") { prnt_ $CW_,$CW_,$_[0],'""' ,$_[2] }
  else		     { prnt_ $CW_,$CW_,$_[0],$_[1],$_[2] }}

# debughash \%PKG,\%PKM; prints whole hash
our sub debughash {
  return if not $DEBUG;
  my @order;
  for(@ORDER) { push @order,$_ if defined $_[0]{$_} }		    # add ORDER keys if defined
  for(sort keys %{$_[0]}) { push @order,$_ if not inar \@order,$_ } # add keys missing in ORDER
  for my $k (@order) {
    prel $k,$_[0]{$k},$_[1]{$k} and next if ref($_[0]{$k}) ne "ARRAY";
    my $k2=$k;
    for(my $i=0;$i<=$#{$_[0]{$k}};$i++) {
      prel $k2,$_[0]{$k}[$i],$_[1]{$k}[$i];
      $k2=".." if $k2!=1 }}}

# ---------------------------------------------------------------------------------------------------

# ask to confirm to proceed
our sub proceed {
  prnt and exit if $QUERY;				# QUERY?
  return if $FORCED;					# FORCED?
  my $s = "proceed? Y/n/q"; print hspace($s).$s.": ";	# prompt question
  system "stty -icanon eol \001";
  my $k; $k=getc(STDIN) while not $k=~/[YyNnQq\n]/;	# wait for keypress
  system "stty icanon eol ^@";
  print "\n" if not $k eq "\n";				# manual newline
  if($k=~/[nNqQ]/) { prnt "","bye"; prnt; exit }	# exit
  prnt; }						# print empty line

} # R.Jaksa 2001,2023 GPLv3
