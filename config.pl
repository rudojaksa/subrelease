# include parser.pl

{ # SUBRELEASE CONFIG

# return 1 if pathname can be used as dir for this user, 0 otherwise
my sub dirok {
  return 1 if not -e $_[0] or (-w $_[0] and -d $_[0]);
  return 0 }

# return the temporary backup directory, try /tmp/sub, /tmp/user-sub, /tmp/sub2...
my sub tmpdir { my $tmp;
  $tmp = "/tmp/subrelease";
  return $tmp if dirok $tmp;
  $tmp = "/tmp/$ENV{USER}-subrelease";
  return $tmp if dirok $tmp;
  my $i=2; do { $tmp = "/tmp/subrelease$i"; $i++ } while(not dirok $tmp);
  return $tmp }

# ---------------------------------------------------------------------------------------------------

my sub pkginit {
  $PKG{pwd} = nonl `pwd`;
  $PKG{tgzdir} = -d "../tgz" ? "../tgz" : "..";
  $PKM{tgzdir} = "<- default";
  $PKG{tmpdir} = tmpdir; 
  $PKG{delimiter} = "-";
  $PKM{delimiter} = "<- default"; }

# for parsing configs, before the real identify
# $PKG{config} is temporal here, but permanent for VERSION file
my sub parsecfg {
  $PKG{config} = 1; # flag that we do parse config file (not the regular source file)
  $PKG{file} = $_[0];
  $PKG{language} = "cfg";
  getvar \&cfgvar;
  delete $PKG{config}; # reset the setup after the .subrelease config
  delete $PKG{file};
  delete $PKG{language} }

# main
our sub subrelease_config {
  pkginit;

  # find config files
  my $config1 = homecfg ".subrelease";		   # 1st read these
  my $config2 = parentcfg $PKG{pwd},".subrelease"; # 2nd override by these

  # parse configs, override 1 with 2
  parsecfg $config1 and $PKG{config1}=$config1 if defined $config1;
  parsecfg $config2 and $PKG{config2}=$config2 if defined $config2;

  # # parse the config
  # if($cf) {
  #   $PKG{suffix}  = getval $cfbody,"suffix";
  #   $PKG{variant} = getval $cfbody,"variant";
  #   $PKM{suffix}  = "<- $cf" if $PKG{suffix};
  #   $PKM{variant} = "<- $cf" if $PKG{variant} }
  #
  # if($cf and not $PKG{variant}) {
  #   $PKG{variant} = getval $cfbody,"branch";
  #   $PKK{variant} = "branch" if $PKG{variant};
  #   $PKM{variant} = "<- $cf: branch" if $PKG{variant} }

  # beautify the variant
  my $variant = $PKG{variant};
  $PKG{variant} =~ s/\h/-/g; # disable unsafe whitespaces

  # beautify the suffix
  my $suffix = $PKG{suffix};
  $PKG{suffix} =~ s/x/t/g;
  $PKG{suffix} =~ s/^\.?sub//;
  $PKG{suffix} =~ s/^\.?tar//;
  $PKG{suffix} =~ s/^\.+//; 

  # fix PKM
  $PKM{variant} = "<= $variant $PKM{variant}" if $variant ne $PKG{variant};
  $PKM{suffix}  = "<= $suffix $PKM{suffix}"   if $suffix  ne $PKG{suffix};

  # no empty suffix/variant allowed
  delete $PKG{suffix} if not $PKG{suffix};
  delete $PKG{variant} if not $PKG{variant}; }

# MAIN
} subrelease_config;

# R.Jaksa 2023 GPLv3
