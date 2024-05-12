### NAME
subrelease - snapshot current directory to package or subrel. archive

### USAGE
        subrelease [OPTIONS] [PKGNAME]

### DESCRIPTION
Subrelease makes a snapshot package from the content of current
directory to the PKGNAME.tlz file in ../tgz, or .. directories. The
PKGNAME is optional, as the version, subversion and package name are
autodetected by getversion.  

### OPTIONS
        -h  This help.
        -d  Debug.
        -f  Forced no-questions noninteractive mode.
        -q  Query mode, don't write any files.
        -c  Run make clean before packing (dangerous with faulty Makefile).
        -R  Rewrite the release package, don't make subversions.
        -s  Save a snapshot, not archive subversion, like pkg-1.4c.tlz.
    -s STR  Save given variant snapshot, like pkg-1.4.variant.tlz.
    -v STR  Just set a variant.
    -t DIR  Target directory instead of ../tgz.
       -nb  No backups in ../tgz.
       -nt  No tmp-backups in /tmp/subrelease.
       -bw  Black & white.

### SUBVERSIONS
        If the archive pkg-1.4.tlz already exists, the subversions archive
        pkg.1.4.xlz will be created with subversions 1.4a, 1.4b inside.
        The subversion value is automatically incremented in its source
        file pointed out by getversion.

### FILES
        pkg-1.4.tlz   The .tar.lz release package.
        pkg-1.4c.tlz  Subrelease c snapshot of package.
        pkg-1.4.xlz   The .tar.lz archive containing subrelease snapshots.
        pkg-1.4.sub/pkg-1.4c  Particular subrelease snapshot subdir.
        pkg-1.4.sub/pkg-1.4c.david  Specific variant "david" (a branch).
        pkg-1.4c.beta.tlz  Variant "beta" of version 1.4 of package pkg.
        anything.bkp  Backup of previous version of given file.

### CONFIG
        The .subrelease file from the home directory and from the first
        parent directory is used as a config file for the subrelease run.  
        Syntax is the same as for the VERSION file (see getversion -h).
        Config-specific keywords are SUFFIX, TGZDIR, EXCLUDE and keywords
        ALWAYS, ONRELEASE and ONSUBRELEASE to define scripts to run.
        Possible suffixes for the archive files are:
    
                    short           full suffix
                +-------------+-----------------------+
                |  .tgz .xgz  |  .tar.gz .sub.tar.gz  |
                | .tbz2 .xbz2 | .tar.bz2 .sub.tar.bz2 |
        default |  .tlz .xlz  |  .tar.lz .sub.tar.lz  |
                | .tzst .xzst | .tar.zst .sub.tar.zst |
                +-------------+-----------------------+
                   rel.  arch.   release   archive
    
        Examples of scripts defintion with automatic variables:
        ALWAYS: echo `date -I` %P %f >> /var/log/subrelease.log
        ONSUBRELEASE: ~/util/mknews ./Changelog
        ONRELEASE: scp %f server:/archive/%x/
    
        %f  filename, %F full path, %d tgzdir
        %v  version, %V full version incl. subversion, %s subversion
        %p  package name, %P w. version, %b variant/branch, %B w. branch
        %a  authors, %c caption, %x project, %l language
        %%  the % character
    
        The EXCLUDE allows to exclude specified files from being archived.
        Exclude patterns are space separated glob patterns, can be quoted
        with double quotes:
        EXCLUDE: .git *.png "copy of *"

### RECOVERY
        In case of error (No space left on device, etc.) the re-packaging
        might be stopped in the middle.  For recovery check .bkp files in
        the ../tgz or .. directories.  Before any subrelease work (before
        the make clean etc.) copy of current dir is stored in the
        /tmp/subrelease under a snapshot name.

### SEE ALSO
getversion -h

### VERSION
subrelease-0.12 R.Jaksa 2001,2021,2023 GPLv3 built 2024-05-10

