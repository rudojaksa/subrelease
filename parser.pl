# GETVERSION PARSERS
# include tore.pl

{ # ---------------------------------------------------------------------------- PER-LASGUAGE PARSERS
# key/value parsers: value = xyzvar(body,key) # $_[0]=body $_[1]=key
# return: a value, or (value,used_keyname) pair

our sub cvar { my ($s,$k) = @_;
  my $re1 = tore 'BGN~#~define ',$k,' "([^"\n]*)"';		# quoted
  my $re2 = tore 'BGN~#~define ',$k,' ([^\h]*)\s';		# plain
  return $1 if $s =~ /$re1/;
  return $1 if $s =~ /$re2/;
  return }

our sub perlvar { my ($s,$k) = @_;
  my $re1 = tore 'BGN~(?:our|my\h+)?\$',$k,'~=~"([^"\n]*)"';	# quoted
  my $re2 = tore 'BGN~(?:our|my\h+)?\$',$k,'~=~([^\h;]*)[\s;]';	# plain
  return $1 if $s =~ /$re1/;
  return $1 if $s =~ /$re2/;
  return }

our sub shvar { my ($s,$k) = @_;
  my $re1 = tore 'BGN~',$k,'~=~"([^"\n]*)"';			# quoted
  my $re2 = tore 'BGN~',$k,'~=~([^\h#;]*)[\s#;]';		# plain
  return $1 if $s =~ /$re1/;
  return $1 if $s =~ /$re2/;
  return }

our sub pythonvar { shvar @_ }

our sub makevar { my ($s,$k) = @_;
  my $re1 = tore 'BGN~',$k,'~:?=~"([^"\n]*)"';			# quoted
  my $re2 = tore 'BGN~',$k,'~:?=~([^#]*?)~(?:#.*)?END';		# plain (w comment)
  return $1 if $s =~ /$re1/;
  return $1 if $s =~ /$re2/;
  return }

my  sub cfgre1 { return tore 'BGN~',$_[0],'~: "([^"\n]*)"' }	# quoted
my  sub cfgre2 { return tore 'BGN~',$_[0],'~: ([^#]*?)~(?:#.*)?END' } # plain (w comment)
our sub cfgvar { my ($s,$k) = @_;
  my $re1 = cfgre1 $k; return $1 if $s =~ /$re1/;
  my $re2 = cfgre2 $k; return $1 if $s =~ /$re2/;
  return }

our sub commentvar {
  my ($s,$k) = @_;
  my $k1 = lc $k;
  my $k2 = ucfirst lc $k;
  my $k3 = uc $k;
  if($k eq "PACKAGE" or $k eq "PROJECT" or $k eq "VERSION" or $k eq "SUBVERS" or $k eq "SUBVERSION") {
    return ($5,$1) if $s =~ /(($k1)|($k2)|($k3))\h+([^\h]*?)[\h,;]/ }
  else {
    return ($5,$1) if $s =~ /(($k1)|($k2)|($k3))\h+(.*?)(\n|$)/ }
  return }

# -------------------------------------------------------------------------------------------- GETVAR

# checkvar "PACKAGE","package"; requires $CMD,$BODY,$MSG; fills $PKG,$PKK,$PKM
my sub checkvar {
  my ($NAME,$KEY) = @_;					# variable name and a PKG key
  my ($val,$name) = &{$CMD}($BODY,$NAME);		# $val,$key = perlvar($body,"PACKAGE")
  return if not defined $val or $val eq "";		# no $val or empty $val
  $PKG{$KEY} = $val;					# $PKG{package} = $val
  $PKK{$KEY} = $NAME;					# $PKK{package} = "PACKAGE"
  if(defined $name) { $PKM{$KEY}="$MSG: $name" }	# $PKM{package} = "$msg: Package"
  else		    { $PKM{$KEY}="$MSG: $NAME" }}	# $PKM{package} = "$msg: PACKAGE"

# check all appearances of the array-type variables in config (config-only!)
# requires $CMD,$BODY,$MSG; fills $PKG,$PKK,$PKM
my sub checkcfg {
  my ($NAME,$KEY) = @_;
  my $body = $BODY; # copy!
  my $re1 = cfgre1 $NAME;
  my $re2 = cfgre2 $NAME;
  my @pkg; my @pkk; my @pkm; my $ok;
  while($body=~s/$re1/\n/ or $body=~s/$re2/\n/) {
    push @pkg,$1;
    push @pkk,$NAME;
    push @pkm,"$MSG: $NAME";
    $ok=1 }
  return if not $ok;
  # print ">> $KEY:"; print " [$_]" for @arr; print "\n";
  push @{$PKG{$KEY}},@pkg;
  push @{$PKK{$KEY}},@pkk;
  push @{$PKM{$KEY}},@pkm; }

# load $PKG{file} and read all variables from it
our sub getvar {
  return if not defined $PKG{file};
  $PKG{comment} = 1 if $_[2] eq "comment";
  local  $CMD = $_[0]; # local to be seen in checkvar
  local $BODY = $_[1]; $BODY = `cat $PKG{file}` if not defined $_[1];
  local  $MSG = "<- ".beautify($PKG{file},$PKG{pwd}); $MSG.=" $_[2]" if defined $_[2];
  checkvar "PACKAGE","package";
  checkvar "VERSION","version";
  checkvar "SUBVERS",   "subversion";
  checkvar "SUBVERSION","subversion";
  checkvar "PROJECT","project";
  checkvar "AUTHOR",   "authors";
  checkvar "AUTHORS",  "authors";
  checkvar "COPYRIGHT","authors";
  checkvar "COPYLEFT", "authors";
  checkvar "CAPTION","caption";
  checkvar "BRANCH", "variant";
  checkvar "VARIANT","variant";
  return if not $PKG{config}; # the rest are config specific keywords
  checkvar "SUFFIX","suffix";
  checkvar "TGZDIR","tgzdir";
  checkcfg "ONSUBRELEASE","onsubrelease"; # next are arrays = accept multiple lines
  checkcfg "ONSUB",	  "onsubrelease";
  checkcfg "ONRELEASE","onrelease";
  checkcfg "ONREL",    "onrelease";
  checkcfg "ALWAYS","always" }

} # -------------------------------------------------------------------------------------------------

# R.Jaksa 2001,2009,2023 GPLv3
