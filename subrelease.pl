# include .built.subrelease.pl .version.pl support.pl

our $HELP=<<EOF;

NAME
    subrelease - snapshot current directory to package or subrel. archive

USAGE
    subrelease [OPTIONS] CK([PKGNAME])

DESCRIPTION
    Subrelease makes a snapshot package from the content of current
    directory to the CG(PKGNAME.tlz) file in CG(../tgz), or CG(..) directories. The
    PKGNAME is optional, as the version, subversion and package name are
    autodetected by CC(getversion).  

OPTIONS
    -h  This help.
    CK(-d)  CK(Debug.)
    -f  Forced no-questions noninteractive mode.
    -q  Query mode, don't write any files.
    -c  Run CC(make clean) before packing (dangerous with faulty Makefile).
    -R  Rewrite the release package, don\'t make subversions.
#   -r  Release, increment the minor number. TODO
    -s  Save a snapshot, not archive subversion, like CG(pkg-1.4c.tlz).
-s STR  Save given variant snapshot, like CG(pkg-1.4.variant.tlz).
-v STR  Just set a variant.
-t DIR  Target directory instead of CG(../tgz).
   -nb  No backups in CG(../tgz).
   -nt  No tmp-backups in CG(/tmp/subrelease).
   CK(-bw)  CK(Black \& white.)

SUBVERSIONS
    If the archive CG(pkg-1.4.tlz) already exists, the subversions archive
    CG(pkg.1.4.xlz) will be created with subversions CC(1.4a), CC(1.4b) inside.
    The subversion value is automatically incremented in its source
    file pointed out by getversion.

FILES
    CG(pkg-1.4.tlz)   The .tar.lz release package.
    CG(pkg-1.4c.tlz)  Subrelease c snapshot of package.
    CG(pkg-1.4.xlz)   The .tar.lz archive containing subrelease snapshots.
    CG(pkg-1.4.sub)CK(/)CG(pkg-1.4c)  Particular subrelease snapshot subdir.
    CG(pkg-1.4.sub)CK(/)CG(pkg-1.4c.david)  Specific variant "david" (a branch).
    CG(pkg-1.4c.beta.tlz)  Variant "beta" of version 1.4 of package pkg.
    CK(anything.bkp)  CK(Backup of previous version of given file.)

CONFIG
    The CG(.subrelease) file from the home directory and from the first
    parent directory is used as a config file for the subrelease run.  
    Syntax is the same as for the CG(VERSION) file (see getversion -h).
    Config-specific keywords are SUFFIX, TGZDIR and keywords ALWAYS,
    ONRELEASE and ONSUBRELEASE to define scripts to run.  Possible
    suffixes for the archive files are:

                CK(short)           CK(full suffix)
            CK(+-------------+-----------------------+)
            CK(|  .)CD(tgz)CK( .xgz  |  .tar.)CD(gz)CK( .sub.tar.gz  |)
            CK(| .)CD(tbz2)CK( .xbz2 | .tar.)CD(bz2)CK( .sub.tar.bz2 |)
    default CK(|  .)CC(tlz)CK( .xlz  |  .tar.)CD(lz)CK( .sub.tar.lz  |)
            CK(| .)CD(tzst)CK( .xzst | .tar.)CD(zst)CK( .sub.tar.zst |)
            CK(+-------------+-----------------------+)
               rel.  CK(arch.)   release   CK(archive)

    Script keywords usage examples with automatic variables follows:
    CW(ALWAYS: echo `date -I` %P %f >> /var/log/subrelease.log)
    CW(ONSUBRELEASE: ~/util/mknews ./Changelog)
    CW(ONRELEASE: scp %f server:/archive/%x/)

    CC(%f)  filename, CC(%F) full path, CC(%d) tgzdir
    CC(%v)  version, CC(%V) full version incl. subversion, CC(%s) subversion
    CC(%p)  package name, CC(%P) w. version, CC(%b) variant/branch, CC(%B) w. branch
    CC(%a)  authors, CC(%c) caption, CC(%x) project, CC(%l) language
    CC(%%)  the % character

RECOVERY
    In case of error (No space left on device, etc.) the re-packaging
    might be stopped in the middle.  For recovery check CC(.bkp) files in
    the CG(../tgz) or CG(..) directories.  Before any subrelease work (before
    the CC(make clean) etc.) copy of current dir is stored in the
    CG(/tmp/subrelease) under a snapshot name.

SEE ALSO
    CW(getversion -h)

VERSION
    $PACKAGE-$VERSION$SUBVERSION CK($AUTHOR) CK(built $BUILT)

EOF

# ============================================================================================== ARGV
$CR_=$CG_=$CC_=$CM_=$CW_=$CK_=$CD_="" if clar \@ARGV,"-bw";
printhelp if clar \@ARGV,"-h";

our   $DEBUG=1	if clar \@ARGV,"-d";
our  $FORCED=1	if clar \@ARGV,"-f";
my $NOUPDATE=1	if clar \@ARGV,"-k";
our   $QUERY=1	if clar \@ARGV,"-q";
my  $REWRITE=1	if clar \@ARGV,"-R";
my    $CLEAN=1	if clar \@ARGV,"-c";
my    $NOBKP=1	if clar \@ARGV,"-nb";
my    $NOTMP=1	if clar \@ARGV,"-nt";

# variant, tgzdir
our %ARG;
do { $ARG{variant}=$ARGV[$i]; $ARGV[$i]=""; } if $i=clar(\@ARGV,"-v") and $i<=$#ARGV;
do {  $ARG{tgzdir}=$ARGV[$i]; $ARGV[$i]=""; } if $i=clar(\@ARGV,"-t") and $i<=$#ARGV;

# snapshot
my $SNAP;
for($i=0;$i<$#ARGV;$i++) { if($ARGV[$i] eq "-s" and $ARGV[$i+1] ne "") {
  $SNAP=1; $ARG{variant}=$ARGV[$i+1]; $ARGV[$i+1]=$ARGV[$i]=""; last }}
$SNAP=1	if clar \@ARGV,"-s";

# the first left is the package name
for($i=0;$i<$#ARGV;$i++) {
  next if $ARGV[$i] eq "";
  next if not $ARGV[$i]=~/^[a-zA-Z]/;
  $REQNAME=$ARGV[$i]; $ARGV[$i]=""; last }

# include prnt.pl

# wrong args check
my @wrong;
for $i (@ARGV) { push @wrong,$i if $i ne "" }
fatal2 "wrong args: @wrong" if @wrong;

# ============================================================================================= START
prnt_logo "this is su","b","release";

our %PKG; # package parameters key-value pairs
our %PKK; # exact original keywords for given key
our %PKM; # verbose message for given key

# include config.pl
prntg "config",beautify($PKG{config1},$PKG{pwd}) if defined $PKG{config1};
prntg "config",beautify($PKG{config2},$PKG{pwd}) if defined $PKG{config2};

# explicit values by CLI args (here for detection to work)
$PKG{$_}=$ARG{$_} and $PKM{$_}="<- CLI arg" for keys %ARG;

# verbose
debugfn "current directory",$PKG{pwd};
debugfn "target directory",$PKG{tgzdir};
debug "tmp directory",$CG_.$PKG{tmpdir};
prnt "variant",$PKG{variant},$PKM{variant} if defined $PKG{variant};
prnt  "suffix",$PKG{suffix},$PKM{suffix}   if defined $PKG{suffix};

# default (only set after the verbose output) 
$PKG{suffix}="tlz" and $PKM{suffix}="<= default" if not $PKG{suffix};

# manualy forced tgzdir might not exist
fatal "target directory $PKG{tgzdir} does not exist" if not -d $PKG{tgzdir};

# ========================================================================================== IDENTIFY
# include identify.pl

# explicit values by CLI args (again, here to override autodetected)
$PKG{$_}=$ARG{$_} and $PKM{$_}="<- CLI arg" for keys %ARG;

prnt "autodetected",$PKG{pkgname},$PKG{project};
debug "singlefile",$CG_.$PKG{singlefile} if defined $PKG{singlefile};

# =========================================================================== DECIDE THE PACKAGE NAME

my $pkgname = $PKG{pkgname}; # just remember

# requested name
name2pkg $REQNAME if $REQNAME;

# defaults: "pkg-0.1"
$PKG{package} = "pkg" if not defined $PKG{package};
$PKG{version} = "0.1" if not defined $PKG{version};

# pkgname update and major/minor (major will be used by ls at the end)
update_pkgname; update_majorminor;

# verbose
prnt "new name",$PKG{pkgname},"<- $pkgname" if $PKG{pkgname} ne $pkgname;

# ================================================================ RELEASE VS ARCHIVE LOGIC AND FILES

# whether to RELEASE = if file not found or if forced, existing vs. new
our $release = get_release; # existing one
our $RELEASE = $PKG{pkgname}.relsx if not $release or $REWRITE; # new: pkg-1.4.tlz or pkg-1.4.variant.tlz

# whether to ARCHIVE = if not RELEASE, existing vs. new
our $archive = get_archive if not $RELEASE; # existing one
our $ARCHIVE = $PKG{pkgname}.subsx if not $RELEASE; # new: pkg-1.4.xlz (no variant!)

debugfn "old package file","$PKG{tgzdir}/$release" if $release;
debugfn "new package file","$PKG{tgzdir}/$RELEASE" if $RELEASE;
debugfn "old sub. archive","$PKG{tgzdir}/$archive" if $archive;
debugfn "new sub. archive","$PKG{tgzdir}/$ARCHIVE" if $ARCHIVE and $ARCHIVE ne $archive;

# ============================================================================================== NEXT
# include next.pl

# reset subversion if we do RELEASE and there is no ARCHIVE
if($RELEASE and not $archive and defined $PKG{subversion} and $PKG{subversion}) {
  prnt "subversion reset","from $PKG{subversion}";
  $PKG{subversion} = "reset $PKG{subversion}"; } # to reset SUBVERS value in config

# obtain the next subversion and subdir - look into archive file
get_next_sub $release,$archive;
update_fullname;
our $mem = $PKG{fullname}; # subversion archive member dir

# explicit snapshot, requires PKG{next}
if(defined $SNAP) {
  $RELEASE = "$PKG{pkgname}$PKG{next}".relsx;
  undef $ARCHIVE; undef $archive }

# verbose: we have either $RELEASE or $ARCHIVE, both undef are not possible
if($RELEASE) {
  prntfn $SNAP?"snapshot":"release","$PKG{tgzdir}/$RELEASE"; }
else	{
  prnt "subrelease $CC_$PKG{next}","$mem","(-R to rewrite $PKG{pkgname})";
  my $s = "<- $PKG{tgzdir}/$CG_$archive" if $archive and $archive ne $ARCHIVE;
  prntfn "subversions archive","$PKG{tgzdir}/$ARCHIVE",$s; }

# here PKG is complete, including PKG{next}
debughash \%PKG,\%PKM;

# ============================================================================== TARGET DIRS AND TARS

# target (extract) directory
my $dir = "$PKG{pkgname}";					  # release pkg-1.4
   $dir = "$PKG{pkgname}.$PKG{variant}" if defined $PKG{variant}; # release pkg-1.4.variant
   $dir = "$PKG{pkgname}.sub" if $ARCHIVE;			  # archive pkg-1.4.sub

# target tar file
my $tar = $RELEASE;						  # release
   $tar = $ARCHIVE if $ARCHIVE;					  # archive

# avoid extracting to existing directory (left one)
fatal "can't continue while $PKG{tgzdir}/$dir is present" if -e "$PKG{tgzdir}/$dir";

# ===================================================================================== SCRIPTS LOGIC

# delete unneded scripts
delete $PKG{onrelease} if not $RELEASE;	# on subrelease dont run release scripts
delete $PKG{onsubrelease}  if $RELEASE;	# on release dont run subrelease scripts

# count scripts
my $nscripts=0; $nscripts++ for @{$PKG{always}},@{$PKG{onsubrelease}},@{$PKG{onrelease}};

# scripts announcements, 1st always scripts, then either subrelease or release
prnt "will run" if $nscripts>1;
if(defined $PKG{always})	{ prnt "script","$CC_$_$CD_" for @{$PKG{always}}}
if(defined $PKG{onsubrelease})	{ prnt "subrelease script","$CC_$_$CD_" for @{$PKG{onsubrelease}}}
if(defined $PKG{onrelease})	{ prnt "release script","$CC_$_$CD_" for @{$PKG{onrelease}}}

# ==================================================================================== ASK TO PROCEED
proceed;
# ============================================================================ RE/WRITE PACKAGE FILES

# backup first: current directory as is before anything into /tmp just for case
if(not $NOTMP) {
  (my $this=$PKG{pwd}) =~ s/^.*\///;
  cmd "mkdir -p $PKG{tmpdir}",$CK_ if not -d $PKG{tmpdir};
  tarfrom "..",$this,"$PKG{tmpdir}/$PKG{pkgname}$PKG{next}".relsx,$CK_ }

# make clean: only if requested and Makefile with a clean rule exists
if($CLEAN and -f "Makefile" and not `make -n clean 2>&1` =~ /No rule to make target 'clean'/) {
  cmdnull "make clean" }

# cp command
my $cp = "cp -a";				# OK for local disk
   $cp = "cp -dR --preserve=timestamps,links";	# different UIDs over NFS need this

# here, go to TGZDIR
chdir $PKG{tgzdir}; print "${CK_}cd $PKG{tgzdir}$CD_\n";

# if release file exists and will be rewritten, then make a backup
cmd "$cp $release $release.bkp" if $REWRITE and $release and not $NOBKP;

# DEPRECATED archive backup
if(   -f "$PKG{pkgname}.arch.bkp.tar.bz2") {
  cmd "mv $PKG{pkgname}.arch.bkp.tar.bz2 $PKG{pkgname}.arch.tbz2.bkp" }

# unpack existing archive
if($archive) {
  cmd "tar xf $archive";					# OK for .xlz and .tar.bz2 too
  cmd "mv $PKG{pkgname}.arch $dir" if -d "$PKG{pkgname}.arch";	# fix DEPRECATED .arch
  fatal2 "subrelease: directory $PKG{tgzdir}/$dir not created, can't continue\n" if not -e $dir; # dir must exist here
  cmd "mv $archive $archive.bkp",$CK_ if not $NOBKP }		# make a (single) backup
elsif($ARCHIVE and not defined $PKG{singlefile}) {
  cmd "mkdir $dir"; }						# or we need new archive directory

# singlefile needs specific subdir as well
cmd "mkdir -p $dir/$mem" if defined $PKG{singlefile} and ($archive or $ARCHIVE);

# copy current dir as a new archive member
if($ARCHIVE) {
  if(defined $PKG{singlefile}) { cmd "$cp $PKG{pwd}/$PKG{singlefile} $dir/$mem"; }
  else		      	       { cmd "$cp $PKG{pwd} $dir/$mem"; }}

# or copy a release
cmd "$cp $PKG{pwd} $dir" if $RELEASE and not defined $PKG{singlefile};

# singlefile tar
if($RELEASE and defined $PKG{singlefile}) { tarfrom $PKG{pwd},$PKG{singlefile},$tar }

# or regular tar
if(not $RELEASE or not defined $PKG{singlefile}) { # either RELEASE or ARCHIVE or singlefile ARCHIVE
  fatal2 "directory $PKG{tgzdir}/$dir doesn't exists, can't continue\n" if not -e $dir; # dir must exist here
  tardir $dir,$tar }

# remove the packaging dir
cmd "rm -rf $dir",$CK_ if -d $dir;

# return back to orig CWD
print "${CK_}cd .$CD_\n";
chdir $PKG{pwd};
print "can't return back to $PKG{pwd} to run scripts\n" if $nscripts and $PKG{pwd} ne nonl(`pwd`);

# include scripts.pl and run all scripts
if($nscripts) {
  $PKG{filename} = $tar; # needed for %f
  cmd resolve($_),$CC_,$CD_ for @{$PKG{always}},@{$PKG{onsubrelease}},@{$PKG{onrelease}}}

# ================================================================================ REWRITE SUBVERSION
# include rewrite.pl

rewrite_sub if not $NOTMP
  and defined $PKG{file} and -f $PKG{file}
  and $PKG{subversion} ne $PKG{next};

# ===================================================================================== PRINT SUMMARY

my $ls = "ls -ld";
   $ls = "ll -d -m4" if `which ll`;
my $cmd = "$ls $PKG{tgzdir}/$PKG{package}$PKG{delimiter}$PKG{major}$PKG{dot}*";

print "$CM_$cmd$CD_\n\n$CR_";
system $cmd;
print "$CD_\n";

# ====================================================================== R.Jaksa 2001,2021,2023 GPLv3
