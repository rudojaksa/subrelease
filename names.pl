{ # SUBRELEASE NAMES/FILENAMES UTILITIES, required %PKG access

# parse the string to package, delimiter, version
sub name2pkg {
  my $name = $_[0];
  my $sx = "(([a-z])|(rc[0-9]))?";
  my @pdv;
  if($name =~ /([a-zA-Z][a-zA-Z0-9._+-]*?)?([\._-]?)([0-9\.]+$sx)$/) { @pdv = ($1,$2,$3) }
  elsif($name =~ /^[^a-zA-Z0-9]*(.*)$/) { @pdv = ($1) }
  ($PKG{package},$PKG{delimiter},$PKG{version}) = @pdv;
  $PKM{package} = $PKM{delimiter} = $PKM{version} = "<= $name" }

# parse the version into major, dot, minor, mtype
sub update_majorminor {
  return if not $PKG{version};
  my @mdm;
  if   ($PKG{version} =~ /(.*?)([.]?)([0-9]+)$/) { @mdm = ($1,$2,$3,"09") }
  elsif($PKG{version} =~ /(.*?)([.-]?)([a-z])$/) { @mdm = ($1,$2,$3,"az") }
  ($PKG{major},$PKG{dot},$PKG{minor},$PKG{mtype}) = @mdm;
  $PKM{major} = $PKM{dot} = $PKM{minor} = $PKM{mtype} = "<= $PKG{version}" }

# update pkgname: package+version
sub update_pkgname {
  $PKG{pkgname} = $PKG{package}.$PKG{delimiter}.$PKG{version};
  $PKM{pkgname} = "<= $PKG{package} $PKG{delimiter} $PKG{version}" }

# update fullname: pkgname+subversion+variant
sub update_fullname {
  my $var=""; $var=".$PKG{variant}" if defined $PKG{variant};
  $PKG{fullname} = $PKG{pkgname}.$PKG{next}.$var;
  $PKM{fullname} = "<= $PKG{pkgname} $PKG{next} $PKG{variant}" }

# ------------------------------------------------------------------------------------------ SUFFIXES

# release suffix
our sub relsx {
  my $sx = $PKG{suffix};					# gz
     $sx = "tar.$sx" if $PKG{suffix}=~/^[gblz]/;		# tar.gz
     $sx = "$PKG{variant}.$sx" if defined $PKG{variant};	# variant.tar.gz
  return ".$sx" }

# subreleases archive suffix
our sub subsx {
  my $sx = $PKG{suffix};					# gz
  if($PKG{suffix}=~/^[gblz]/) { $sx = "sub.tar.$sx" }		# sub.tar.gz
  else			      { $sx =~ s/^t/x/ }		# tgz -> xgz
  return ".$sx" }

# ------------------------------------------------------------------------------ EXISTING FILES NAMES
# return previous existing release/archive paths, relative to TGZDIR, from package and version

# release and archive suffixes
my @RSX = ("tlz","tar.lz","tzst","tar.zst","tbz2","tar.bz2","tgz","tar.gz");
my @ASX = ("xlz","sub.tar.lz","xzst","sub.tar.zst","xbz2","sub.tar.bz2","xgz","sub.tar.gz");
my @ADE = ("arch.tar.bz2","arch.bkp.tar.bz2"); # DEPRECATED
my @RBP = @RSX; s/$/.bkp/ for @RBP;
my @ABP = @ASX; s/$/.bkp/ for @ABP;

# our $release = get_release; return active release file path
# only checks variant release if variant specified
our sub get_release {
  my @vars = ("");
     @vars = (".$PKG{variant}") if defined $PKG{variant}; # (".$PKG{variant}","") to check all
  for my $var (@vars) {		# variant
    for my $sx (@RSX,@RBP) {	# suffixes
      for my $del ("-",".") {	# delimiters
	my $f = "$PKG{package}$del$PKG{version}$var.$sx"; my $fn=$f;
	   $f = "$PKG{tgzdir}/$f" if defined $PKG{tgzdir};
	# print $f; print " *" if -f $f; print "\n";
	return $fn if -f $f }}}}

# our $archive = get_archive; return active archive path
our sub get_archive {
  for my $sx (@ASX,@ABP,@ADE) {
    for my $del ("-",".") {
      my $f = "$PKG{package}$del$PKG{version}.$sx"; my $fn=$f;
         $f = "$PKG{tgzdir}/$f" if defined $PKG{tgzdir};
      # print $f; print " *" if -f $f; print "\n";
      return $fn if -f $f }}}

# ----------------------------------------------------------------------------------------- TAR FILES

# return ziptype for tar
my sub ziptype {
  if   ($PKG{suffix} =~ /zst$/) { return "--zstd" }
  elsif($PKG{suffix} =~ /bz2$/) { return "--bzip2" }
  elsif($PKG{suffix} =~ /gz$/)  { return "--gzip" }
  return "--lzip" }

# tar from given dir: tarfrom(inputdir,inputfileordir,outputtar)
our sub tarfrom { my ($dir,$file,$tar,$cc) = @_; my $zip = ziptype;
  cmd "tar cf $tar $zip -C $dir $file",$cc; }

# directory tar: tardir(inputdir,outputtar)
our sub tardir { my ($dir,$tar) = @_; my $zip = ziptype;
  cmd "tar cf $tar $zip $dir"; }

} # R.Jaksa 2001,2021,2023 GPLv3
