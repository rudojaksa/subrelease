# this works directly on global %PKG

# get_next_sub $release,$archive; inspects release/archive files (relative to tgzdir)
# to get next subversion, by looking into archive or by incrementing saved subversion value
sub get_next_sub {
  my $release = "$PKG{tgzdir}/$_[0]";
  my $archive = "$PKG{tgzdir}/$_[1]";

  # default first member of archive
  my $next = "a";
     $next = "0" if $PKG{mtype} eq "az"; 

  # reset subversion
  if($PKG{subversion} =~ /^reset (.*)$/) {
    $PKG{subversion} = $1;
    $PKG{next} = "";
    $PKM{next} = "<= $1 reset";
    return }

  # archive does not exist, but we have saved subversion number
  if(not -f $archive and defined $PKG{subversion} and $PKG{subversion}) {
    my $next = $PKG{subversion};
    $PKG{next} = $next;
    $PKG{next} ++;
    $PKM{next} = "<= $next $PKM{subversion}";
    return }

  # archive does not exist, but release package does, start subreleases with "a" or "0"
  if(not -f $archive and -f $release) {
    $PKG{next} = $next;
    $PKM{next} = "<= $release";
    return }

  # nor archive nor release package exist, none next
  if(not -f $archive) { return }

  # archive exists, get list of subversions from the list of files in archive
  my @a;
  for(sort split /\n/,`tar tf $archive`) { push @a,$1 if /^[^\/]+\/([^\/]+)\/?$/ }
  # print "subs: @a\n";

  # find the biggest subbversion in the list
  $next = $1 if @a and @a[$#a]=~/$PKG{delimiter}$PKG{version}(.*?)(\.|$)/;
  # print " max: $next\n";

  # init/change $next to $PKG{subversion} if defined and bigger then in archive
  $next = $PKG{subversion} if defined $PKG{subversion} and $PKG{subversion} and $PKG{subversion} gt $next;

  # find the first free subversion (but bigger then the current $next)
  my sub inarch { my $v=quotemeta $_[1]; for(@{$_[0]}) { return 1 if /$v/ }}
  $next++ while inarch \@a,"$PKG{delimiter}$PKG{version}$next";

  $PKG{next} = $next;
  $PKM{next} = "<- $archive"; }

# R.Jaksa 2001,2023 GPLv3
