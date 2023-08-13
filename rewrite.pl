# include tore.pl

{ # SUBVERSION REWRITE

# the SUBVERS(ION) keyword plus whitespaces and begine of line
my $SU = qr/\h*SUBVERS(ION)?\h*?/;

# replace SUBVERSION=a by SUBVERSION=b, requires %PKG
our sub rewrite_sub {
  my $s = `cat $PKG{file}`;
  my $s0 = $s;
  my $next = $PKG{next};

  # comments have priority, otherwise the language will match
  if($PKG{comment}) {
    my $re = tore '( (?:(?:SUBVERS(?:ION))|(?:[Ss]ubvers(?:ion))) )([a-z0-9\.]*?)([^a-z0-9\.])';
    $s =~ s/$re/$1$next$3/ }

  # we prefer Makefiles
  elsif($PKG{file} eq "Makefile") {
    my $re = enre '(~SUBVERS(?:ION)?~:?=~)([^#]*?)(~(?:#.*)?)';		# any
    $s =~ s/$re/$1$next$3/ }

  # universal configs still before languages
  elsif($PKG{language} eq "cfg") {
    my $re = enre '(~SUBVERS(?:ION)?~: )([^#]*?)(~(?:#.*)?)';		# any
    $s =~ s/$re/$1$next$3/ }

  elsif($PKG{language} eq "c") {
    my $re1 = enre '(~#~define SUBVERS(?:ION)? ")([^"]*)(".*)';		# quoted
    my $re2 = enre '(~#~define SUBVERS(?:ION)?\h?)(~)';			# empty!
    my  $ok = $s=~s/$re1/$1$next$3/;
              $s=~s/$re2/$1"$next"$2/ if not $ok; }

  elsif($PKG{language} eq "perl") {
    my $re1 = enre '(~(?:our|my\h+)?\$SUBVERS(?:ION)?~=~")([^"]*)(".*)'; # quoted
    my $re2 = enre '(~(?:our|my\h+)?\$SUBVERS(?:ION)?~=~)([^\h;]*)(.*?)'; # plain
    my  $ok = $s=~s/$re1/$1$next$3/;
              $s=~s/$re2/$1$next$3/ if not $ok; }

  elsif($PKG{language} eq "sh" or $PKG{language} eq "python") {
    my $re1 = enre '(~SUBVERS(?:ION)?~=~")([^"]*)(".*)';		# quoted
    my $re2 = enre '(~SUBVERS(?:ION)?~=~)([^\h#;]*)(.*?)';		# plain
    my  $ok = $s=~s/$re1/$1$next$3/;
              $s=~s/$re2/$1$next$3/ if not $ok; }

  # nothing rewriten
  return if $s eq $s0;

  # make copy of orig version to tmpdir
  cmd "mkdir -p $PKG{tmpdir}",$CK_ if not -d $PKG{tmpdir};
  cmd "$cp $PKG{file} $PKG{tmpdir}",$CK_;

  # verbose
  my $from = $PKG{subversion}; $from = '""' if $PKG{subversion} eq "";
  my   $to = $PKG{next};         $to = '""' if $PKG{next} eq "";
  print "${CK_}rewrite$CD_ $CG_$PKG{file}$CK_:$PKK{subversion}$CD_ $from $CK_->$CD_ $CC_$to$CD_\n";

  # rewrite SOURCE
  writefile $PKG{file},$s if -f $PKG{file}; }

} # R.Jaksa 2022 GPLv3
