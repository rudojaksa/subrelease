### NAME
getversion - get package version info for current directory

### USAGE
      getversion [OPTIONS]

### DESCRIPTION
The getversion utility auto-detects the version information for
the package rooted in current directory.  It does so by the
examination of present configuration files, or directory names.

### OPTIONS
        -h  This help.
      -pkg  Name of the package.
      -ver  Version number of the package.
      -sub  Subversion number of the package.
     -next  Next subversion number.
      -prj  Name of the project for this package.
      -pnm  Full package name including the version number.
      -cpy  Copyleft)/copyright announcement of the package.
      -del  The dot character between package name and version [.-].
      -src  File where the version info is defined.
      -cap  Package caption message.
      -lng  Language of the info file.
    -t DIR  Target directory instead of ../tgz (for correct next).
       -bw  Black & white.

### C LANGUAGE
      Files VERSION.h, then CONFIG.h or singlefile package:
      #define PACKAGE "package-name"
      #define VERSION "1.13" /* comment */
      #define PROJECT "project-name" // comment
      #define AUTHORS "The.Author 1996"

### PERL
      Files VERSION.pl, then CONFIG.pl or singlefile scripts, but also
      looks for the first perl file with $PACKAGE=... line:
      $PACKAGE="package-name";
      $VERSION="1.13";
      $PROJECT="project-name"; # comment
      $COPYLEFT="(c) The.Author 1999, GPL";

### SHELL OR PYTHON
      Shell singlefile scripts, or python files VERSION.py, CONFIG.py,
      or python singlefile scripts:
      PACKAGE="package-name"
      VERSION="1.13"
      PROJECT="project-name" # comment
      AUTHOR="(c) The.Author 2003"

### MAKEFILE
      PACKAGE := package-name
      VERSION := 1.13
      PROJECT := project-name # comment
      AUTHORS := The.Author 2016

### VERSION FILE
      Language-independent VERSION file:
      PACKAGE: package-name
      VERSION: 1.13
      AUTHORS: Author1, Author2, 2010 # comment

### HEAD-COMMENT
      A note in the head-comment of singlefile (comment in first ten
      lines) found by keywords: Version, Copyleft, Copyright, (c), (C):
      /* Package ABC Version 2.13, Subversion c, (c) A.Qwerty 2011*/

### KEYWORDS
      PACKAGE
      VERSION
      SUBVERS SUBVERSION
      PROJECT
      AUTHORS AUTHOR COPYLEFT COPYRIGHT
      CAPTION
      VARIANT BRANCH
      SUFFIX (the rest are config only, VERSION file or .subrelease)
      TGZDIR
      ALWAYS
      ONREL ONRELEASE
      ONSUB ONSUBRELEASE

### MULTI-LANGUAGE
      For multi-language packages use automatic conversion from the
      master file (Makefile, VERSION or even VERSION.h) into language
      specific temporary/hidden includes: .version.pl or .version.py ...

### SEE ALSO
subrelease -h

### VERSION
subrelease-0.12c R.Jaksa 2001,2021,2023 GPLv3 (built 2024-06-30)

