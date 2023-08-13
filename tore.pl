# to-regex parser: regexes are hard to read, but simple task-specific language
# can be parsed to regex, and such language can be OK to read...
#
# open tore syntax:
# BGN~#~define KEY "[^"]*"
# BGN~#~define KEY [^\h]*\s
#
# enclosed enre syntax:
# (~#~define KEY ")([^"]*)(".*)

# create regex from array
sub tore { my @A=@_; my $s;
  for(@A) {

    # abc|cde|xyz -> (?:(?:abc)|(?:cde)|(?:xyz))
    while(s/(([a-zA-Z0-9]+\|)+[a-zA-Z0-9]+)/__TORE__/) {
      my $z; $z.="(?:$_)\|" for split /\|/,$1; $z=~s/\|$//;
      s/__TORE__/(?:$z)/ }

    s/~/\\h*/g;			# '~' is optional space
    s/ /\\h+/g;			# ' ' is mandatory space
    s/BGN/(?:^|\\n)/g;		# begin-of-line non-capture group
    s/END/(?:\\n|\$)/g;		# end-of-line
    $s .= $_; }
  return $s; }

# enclosed regex from array: (...) -> ((?:^|\n)...(?:\n|$))
sub enre {
  my $s = tore @_;
  $s =~ s/^\(/((?:^|\\n)/;	# first element starts with (?:^|\n) start of line
  $s =~ s/\)$/(?:\\n|\$))/;	# last element ends with (?:\n|$) end of line
  return $s }

