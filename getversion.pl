# include .built.getversion.pl .version.pl support.pl

our $HELP=<<EOF;

NAME
    getversion - get package version info for current directory

USAGE
    getversion [OPTIONS]

DESCRIPTION
    The getversion utility auto-detects the version information for
    the package rooted in current directory.  It does so by the
    examination of present configuration files, or directory names.

OPTIONS
      -h  This help.
    -pkg  Name of the package.
    -ver  Version number of the package.
    -sub  Subversion number of the package.
   -next  Next subversion number.
    -prj  Name of the project for this package.
    -pnm  Full package name including the version number.
    -cpy  Copyleft)CK(/)copyright announcement of the package.
    -del  The dot character between package name and version [.-].
    -src  File where the version info is defined.
    -cap  Package caption message.
    -lng  Language of the info file.
  CK(-t DIR)  CK(Target directory instead of ../tgz (for correct next).)
     CK(-bw)  CK(Black \& white.)
#CC(-pl/py/c)  Will generate config in perl/python/c (also CC(-make/com)). TODO
#   -full  Will generate full configs. TODO

C LANGUAGE
    Files CG(VERSION.h), then CG(CONFIG.h) or singlefile package:
    CW(#define PACKAGE \"package-name\")
    CW(#define VERSION \"1.13\" /* comment */)
    CW(#define PROJECT \"project-name\" // comment)
    CW(#define AUTHORS \"The.Author 1996\")

PERL
    Files CG(VERSION.pl), then CG(CONFIG.pl) or singlefile scripts, but also
    looks for the first perl file with CC(\$PACKAGE=...) line:
    CW(\$PACKAGE=\"package-name\";)
    CW(\$VERSION=\"1.13\";)
    CW(\$PROJECT=\"project-name\"; # comment)
    CW(\$COPYLEFT=\"(c) The.Author 1999, GPL\";)

SHELL OR PYTHON
    Shell singlefile scripts, or python files CG(VERSION.py), CG(CONFIG.py),
    or python singlefile scripts:
    CW(PACKAGE=\"package-name\")
    CW(VERSION=\"1.13\")
    CW(PROJECT=\"project-name\" # comment)
    CW(AUTHOR=\"(c) The.Author 2003\")

MAKEFILE
    CW(PACKAGE := package-name)
    CW(VERSION := 1.13)
    CW(PROJECT := project-name # comment)
    CW(AUTHORS := The.Author 2016)

VERSION FILE
    Language-independent CG(VERSION) file:
    CW(PACKAGE: package-name)
    CW(VERSION: 1.13)
    CW(AUTHORS: Author1, Author2, 2010 # comment)

HEAD-COMMENT
    A note in the head-comment of singlefile (comment in first ten
    lines) found by keywords: Version, Copyleft, Copyright, (c), (C):
    CW(/* Package ABC Version 2.13, Subversion c, (c) A.Qwerty 2011*/)

KEYWORDS
    CD(PACKAGE)
    CD(VERSION)
    CD(SUBVERS SUBVERSION)
    CD(PROJECT)
    CD(AUTHORS AUTHOR COPYLEFT COPYRIGHT)
    CD(CAPTION)
    CD(VARIANT BRANCH)
    CK(SUFFIX) (the rest are config only, CG(VERSION) file or CG(.subrelease))
    CK(TGZDIR)
    CK(ALWAYS)
    CK(ONREL ONRELEASE)
    CK(ONSUB ONSUBRELEASE)

MULTI-LANGUAGE
    For multi-language packages use automatic conversion from the
    master file (Makefile, CD(VERSION) or even CD(VERSION.h)) into language
    specific temporary/hidden includes: CG(.version.pl) or CG(.version.py) ...

SEE ALSO
    CW(subrelease -h)

VERSION
    $PACKAGE-$VERSION$SUBVERSION $CK_$AUTHOR$CD_ $CK_(built $BUILT)$CD_

EOF

$CR_=$CG_=$CC_=$CM_=$CW_=$CK_=$CD_="" if clar \@ARGV,"-bw";
printhelp if clar \@ARGV,"-h";

my $ALL=1;
my $PKG=1 and $ALL=0 if clar \@ARGV,"-pkg";
my $VER=1 and $ALL=0 if clar \@ARGV,"-ver";
my $SUB=1 and $ALL=0 if clar \@ARGV,"-sub";
my $NXT=1 and $ALL=0 if clar \@ARGV,"-next";
my $PRJ=1 and $ALL=0 if clar \@ARGV,"-prj";
my $PNM=1 and $ALL=0 if clar \@ARGV,"-pnm";
my $CPY=1 and $ALL=0 if clar \@ARGV,"-cpy";
my $DEL=1 and $ALL=0 if clar \@ARGV,"-del";
my $SRC=1 and $ALL=0 if clar \@ARGV,"-src";
my $CAP=1 and $ALL=0 if clar \@ARGV,"-cap";
my $LNG=1 and $ALL=0 if clar \@ARGV,"-lng";
our %ARG;
do { $ARG{tgzdir}=$ARGV[$i]; $ARGV[$i]=""; } if $i=clar(\@ARGV,"-t") and $i<=$#ARGV;
for(@ARGV) { print STDERR "${CR_}unknown rgument $_$CD_\n" and exit if $_ ne "" }

our %PKG; # package parameters key-value pairs
our %PKK; # exact original keywords for given key
our %PKM; # verbose message for given key

# include config.pl
$PKG{$_}=$ARG{$_} and $PKM{$_}="<- CLI arg" for keys %ARG;
# include identify.pl next.pl

# get next subversion from the archive file
our $release = get_release;
our $archive = get_archive;
get_next_sub $release,$archive;
update_majorminor;

# print the %PKG value (if exists)
sub prval { return if not defined $PKG{$_[0]} or print "$PKG{$_[0]}\n" }

prval "package"	   if $PKG;
prval "version"	   if $VER;
prval "subversion" if $SUB;
prval "next"	   if $NXT;
prval "project"	   if $PRJ;
prval "pkgname"	   if $PNM;
prval "authors"	   if $CPY;
prval "delimiter"  if $DEL;
prval "source"	   if $SRC;
prval "caption"	   if $CAP;
prval "language"   if $LNG;
exit 0 if not $ALL;

# print single %PKG key/value line for given key
sub prln { my $k=$_[0];
  return if not defined $PKG{$k};
  my $msg = " $CK_$PKM{$k}$CD_" if defined $PKM{$k};
  my $key = defined $_[1] ? $_[1] : $k;
  printf "%10s: $CC_%s$CD_$msg\n",$key,$PKG{$k}; }

# prln but with PKK as a key
sub prlo { prln $_[0],(defined $PKK{$_[0]} ? lc $PKK{$_[0]} : $_[0]) }

prln "singlefile";
prln "package";
prln "version";
print "     major: $CC_$PKG{major}$CK_$PKG{dot}$PKG{minor}$CD_\n";
prln "subversion";
prln "next";
prln "pkgname";
prlo "authors";
prln "caption";
prln "variant";
prln "suffix";
prln "project";
# TODO: tgzdir...

# R.Jaksa 2001,2021,2023 GPLv3
