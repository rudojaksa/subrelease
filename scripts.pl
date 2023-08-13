
# resolve automatic variables in the script command line
our sub resolve {
  my $cmd = $_[0];
  $cmd =~ s/%%/__%__/g;
  
  $cmd =~ s/%f/$PKG{filename}/g;
  $cmd =~ s/%F/$PKG{tgzdir}\/$PKG{filename}/g;
  $cmd =~ s/%d/$PKG{tgzdir}/g;

  $cmd =~ s/%v/$PKG{version}/g;
  my $full = "$PKG{version}$PKG{next}"; $full.=".$PKG{variant}" if defined $PKG{variant};
  $cmd =~ s/%V/$full/g;
  $cmd =~ s/%s/$PKG{next}/g; # next is actually the subversion to be used in the result

  $cmd =~ s/%p/$PKG{package}/g;
  $cmd =~ s/%P/$PKG{pkgname}/g;
  $cmd =~ s/%b/$PKG{variant}/g;
  $cmd =~ s/%B/$PKG{fullname}/g;

  $cmd =~ s/%a/$PKG{authors}/g;
  $cmd =~ s/%c/$PKG{caption}/g;
  $cmd =~ s/%x/$PKG{project}/g;
  $cmd =~ s/%l/$PKG{language}/g;

  $cmd =~ s/__%__/%/g;
  return $cmd }

