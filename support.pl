
# remove NL
our sub nonl { chomp $_[0]; return $_[0]; }

# inar newgen, returns index+1 instead of simple 0/1
# inar(\@a,$s) - check whether the string is in the array, return its idx+1 or zero (1st match)
our sub inar {
  my $a=$_[0];	# array ref
  my $s=$_[1];	# string
  for(my $i=0;$i<=$#{$a};$i++) { return $i+1 if $$a[$i] eq $s; }
  return 0; }

# clar(\@a,$s) - clear the string in the array (1st match), return its idx+1 or zero
our sub clar {
  my $a=$_[0];	# array ref
  my $s=$_[1];	# string
  for(my $i=0;$i<=$#{$a};$i++) {
    if($$a[$i] eq $s) {
      $$a[$i] = "";
      return $i+1; }}
  return 0; }

sub writefile { open(O,">$_[0]") or die "$_[0]: $!"; print O $_[1]; close(O); }

# ----------------------------------------------------------------------------------------------- CMD

# call a command (its output in red), 2nd arg is optional echo color
sub cmd {
  my $c1=$CM_; $c1=$_[1] if defined $_[1]; # command call color
  my $c2=$CR_; $c2=$_[2] if defined $_[2]; # stdout color
  print "$c1$_[0]$CD_\n$c2"; system $_[0]; print $CD_ }

# call with output to /dev/null, stderr still red
sub cmdnull {
  print "$CK_$_[0]$CD_\n$CR_"; system "$_[0] > /dev/null"; print $CD_ }

# -------------------------------------------------------------------------------------------- COLORS

our $CR_="\033[31m"; # color red
our $CG_="\033[32m"; # color green
our $CM_="\033[35m"; # color magenta
our $CC_="\033[36m"; # color cyan
our $CW_="\033[37m"; # color white
our $CK_="\033[90m"; # color black
our $CD_="\033[0m";  # color default

# return length of string without escape sequences
our sub esclen {
  my $s = shift;
  $s =~ s/\033\[[0-9]+m//g;
  return length $s; }

# ----------------------------------------------------------------------------------------- PRINTHELP

# print $HELP and exit
sub printhelp {
  $HELP =~ s/(\n\#.*)*\n/\n/g; # skip commented-out lines
  my $colors = "CWRDKGMB";
  my $L="\#\#\>"; my $R="\<\#\#"; my $id=0; # private left/right brace
  sub SBS { return "$L$_[0]$R"; } # return complete private subst. identifier
  my $RE1 = qr/(\((([^()]|(?-3))*)\))/x; # () group, $1=withparens, $2=without
  $STR{$id++}=$4 while $HELP=~s/([^A-Z0-9])(C[$colors])$RE1/$1.SBS("c$2$id")/e;
  $STR{$id++}=$2 while $HELP=~s/(\n[ ]*)(-[a-zA-Z0-9\/]+(\[?[ =][A-Z]{2,}(x[A-Z]{2,})?\]?)?)([ \t])/$1.SBS("op$id").$5/e; # options lists
  $STR{$id++}="$1$2" while $HELP=~s/\[([+-])?([A-Z]+)\]/SBS "br$id"/e; # bracketed uppercase words
  $STR{$id++}=$2 while $HELP=~s/(\n|[ \t])(([A-Z_\/-]+[ ]?){4,})/$1.SBS("pl$id")/e; # plain uppercase words
  $HELP =~ s/${L}pl([0-9]+)$R/$CC_$STR{$1}$CD_/g;
  $HELP =~ s/${L}op([0-9]+)$R/$CC_$STR{$1}$CD_/g;
  $HELP =~ s/${L}br([0-9]+)$R/\[$CC_$STR{$1}$CD_\]/g;
  my %cc; $cc{$_}=${C.$_._} for split //,$colors;
  $HELP =~ s/${L}cC([$colors])([0-9]+)$R/$cc{$1}$STR{$2}$CD_/g;
  print $HELP; 
  exit }

# -------------------------------------------------------------------------------------------- CONFIG

# beautify $path,$pwd
sub beautify {
  my $qcwd = quotemeta $_[1];								# CWD
  my $p=$_[1]; $p=~s/\/*$//; $p=~s/[^\/]*$//; $p=~s/\/*$//; my $qp = quotemeta $p;	# parent
  my $pp=$p; $pp=~s/\/*$//; $pp=~s/[^\/]*$//; $pp=~s/\/*$//; my $qpp = quotemeta $pp;	# grandparent
  my $qh = quotemeta $ENV{HOME};							# home

  my $fn = $_[0];
  $fn =~ s/^$qcwd\/// if $qcwd;
  $fn =~ s/^$qp\//..\// if $qp;
  $fn =~ s/^$qpp\//..\/..\// if $qpp;
  $fn =~ s/^$qh\//~\// if $qh;
  return $fn }

# -------------------------------------------------------------------------------------------- CONFIG

# $file = parentcfg $init_dir,$filename; looks for config file in any parent directory
sub parentcfg { my ($dir,$fnm) = @_;
  while($dir ne "") {
    my $cf = "$dir/$fnm";
    return $cf if -f $cf;
    $dir =~ s/[^\/]*$//;
    $dir =~ s/\/$//; }
  return $cf if -f $cf }

# $file = homecfg $filename; just looks for the config file in home directory
sub homecfg { my $fnm = $_[0];
  my $cf = "$ENV{HOME}/$fnm";
  return $cf if -f $cf }

# getval $str,"keyword"; return the value for "keyword: value" line
sub cfgval { return $2 if $_[0]=~/(^|\n)\h*$_[1]\h*:\h+(.+?)\h*(\n|$)/ }

# R.Jaksa 2009,2023
