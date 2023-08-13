# include names.pl parser.pl

{ # GETVERSION IDENTIFY

# get PKG file (and singlefile) and language from current dir, no PKM PKK
my sub getfile {

  # 1st: try explicit VERSION files
  if   (-f "VERSION.pl"){ $PKG{language} = "perl";   $PKG{file} = "VERSION.pl"; }
  elsif(-f  "CONFIG.pl"){ $PKG{language} = "perl";   $PKG{file} = "CONFIG.pl"; }
  elsif(-f "VERSION.py"){ $PKG{language} = "python"; $PKG{file} = "VERSION.py"; }
  elsif(-f  "CONFIG.py"){ $PKG{language} = "python"; $PKG{file} = "CONFIG.py"; }
  elsif(-f "VERSION.h")	{ $PKG{language} = "c";      $PKG{file} = "VERSION.h"; }
  elsif(-f  "CONFIG.h")	{ $PKG{language} = "c";      $PKG{file} = "CONFIG.h"; }
  elsif(-f "VERSION")	{ $PKG{language} = "cfg";    $PKG{file} = "VERSION"; $PKG{config} = 1; }
  elsif(-f "Makefile")	{ $PKG{language} = "make";   $PKG{file} = "Makefile"; }

  # get list of all files to look further
  my @FILES = split /\n/,`find . -maxdepth 1 -type f`;
  s/^.\/// for @FILES;

  # 2nd: singlefile if there is only a single file present
  if(not defined $PKG{file} and $#FILES==0) { 
    $PKG{file} = $PKG{singlefile} = $FILES[0];
    my $line1 = `head -n 1 '$FILES[0]'`;
    $PKG{language} = "perl"   if $line1 =~ /^\#!\h*\/.*\/perl/;
    $PKG{language} = "python" if $line1 =~ /^\#!\h*\/.*\/python/;
    $PKG{language} = "sh"     if $line1 =~ /^\#!\h*\/.*\/((ba)|(z))?sh/;
    $PKG{language} = "c"      if $FILES[0] =~ /\.[ch]$/;
    $PKG{language} = "perl"   if $FILES[0] =~ /\.pl$/;
    $PKG{language} = "python" if $FILES[0] =~ /\.py$/;
    $PKG{language} = "sh"     if $FILES[0] =~ /\.sh$/; }

  # look for the 1st perl file with the "$PACKAGE="
  if(not defined $PKG{file}) {
    for my $f (@FILES) {
      my $line1 = `head -n 1 '$f'`;
      my $pl = 0;
         $pl = 1 if $f =~ /\.pl$/;
         $pl = 1 if $line1 =~ /^\#!\h*\/.*\/perl/;
      next if not $pl;
      next if not `cat '$f'` =~ /\$PACKAGE\h*=/;
      $PKG{file} = $f;
      $PKG{language} = "perl";
      last; }}}

# get all variables from given PKG{file}, needs file and language
my sub getvars {

  getvar \&perlvar   if $PKG{language} eq "perl";
  getvar \&pythonvar if $PKG{language} eq "python";
  getvar \&shvar     if $PKG{language} eq "sh";
  getvar \&cvar	     if $PKG{language} eq "c";
  getvar \&cfgvar    if $PKG{language} eq "cfg";
  getvar \&makevar   if $PKG{language} eq "make";

  # from header-comment
  if((not defined $PKG{package} or
      not defined $PKG{version} or
      not defined $PKG{authors}) and defined $PKG{file}) {
    my $s = `head $PKG{file}`;
    my $body;

    if($PKG{language} eq "c") {
      while($s=~s/\/\*(.*?)\*\///)   { $body.="$1\n" }	# we don't avoid in-strings "/*...*/" match
      while($s=~s/\/\/(.*?)(\n|$)//) { $body.="$1\n" }}	# detto
    else {
      while($s=~s/#(.*?)(\n|$)//)    { $body.="$1\n" }}	# detto

    getvar \&commentvar,$body,"comment";

    # (c) Author hack
    if(not defined $PKG{authors}) {
      $PKG{authors} = $2 if $body=~/(\([Cc]\))\h+(.*?)\h*\n/;
      $PKM{authors} = "<- $PKG{file} comment: $1" }}

  # singlefile PKG from filename
  if(not defined $PKG{package} and defined $PKG{singlefile}) {
    $PKG{package} = $PKG{file};
    $PKG{package} =~ s/\..*$//;
    $PKM{package} = "<= $PKG{file} filename"; }}

# identify project from pwd or package
my sub getproject {

  # derived from parent directory
  if(not defined $PKG{project}) {
    if($PKG{pwd} =~ /\/([^\/]+)\/[^\/]+$/) {
      $PKG{project} = "$1";
      $PKM{project} = "derived from CWD: $PKG{pwd}"; }}

  # copy the package name
  if(not defined $PKG{project} and defined $PKG{package}) {
    $PKG{project} = "$PKG{package}";
    $PKM{project} = "derived from $PKG{package}"; }}

# main
our sub getversion_identify {
  getfile;
  getvars;
  getproject;
  update_pkgname }

# MAIN
} getversion_identify;

# R.Jaksa 2001,2021,2023 GPLv3
