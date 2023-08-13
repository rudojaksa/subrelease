SHELL	:= /bin/bash	
PATH	:= $(PATH):UTIL
PACKAGE	:= subrelease
VERSION	:= 0.11
PROJECT	:= makeutils
AUTHORS	:= R.Jaksa 2001,2021,2023 GPLv3
CAPTION := minimal subrelease snapshotting
SUBVERS	:= 
BUILT	:= $(shell echo `date +%Y-%m-%d`)

BIN := getversion subrelease
SRC := $(BIN:%=%.pl)
DOC := $(BIN:%=doc/%.md)
LIB := $(shell ls -d *.pl)
LIB := $(filter-out $(SRC),$(LIB))

all: $(BIN) $(DOC)

%: %.pl $(LIB) .version.pl .built.%.pl Makefile
	@echo -e '#!/usr/bin/perl\n' > $@
	perlpp-simple $< >> $@
	@chmod 755 $@

.version.pl: Makefile
	@echo 'our $$PACKAGE = "$(PACKAGE)";' > $@
	@echo 'our $$VERSION = "$(VERSION)";' >> $@
	@echo 'our $$PROJECT = "$(PROJECT)";' >> $@
	@echo 'our $$AUTHOR = "$(AUTHORS)";' >> $@
	@echo 'our $$SUBVERSION = "$(SUBVERS)";' >> $@
	@echo "update $@"

.PRECIOUS: .built.%.pl
.built.%.pl: %.pl $(LIB) .version.pl Makefile
	@echo 'our $$BUILT = "$(BUILT)";' > $@
	@echo "update $@"

# install symlinks to private ~/bin
install: $(BIN) subls
	@echo install symlinks to ~/bin:
	@mkdir -p ~/bin
	@for i in $+; do ln -sf `pwd`/$$i ~/bin/`basename $$i`; done
	@for i in $+; do ls -l --color ~/bin/`basename $$i`; done
	@if test ! `echo $$PATH | grep ~/bin`; then echo "~/bin missing in your PATH: $$PATH"; fi

$(DOC): doc/%.md: % | doc
	$< -h | man2md > $@

clean:
	rm -f .version.pl
	rm -f .built.*.pl

mrproper: clean
	rm -f $(BIN)
	rm -f $(DOC)

include ~/.gitlab/Makefile.git
