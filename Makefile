PACKAGE	:= subrelease
VERSION	:= 0.12
PROJECT	:= makeutils
AUTHORS	:= R.Jaksa 2001,2021,2023 GPLv3
CAPTION := directory to package snapshotting
SUBVERS	:= b

SHELL	:= /bin/bash
PATH	:= usr/bin:$(PATH)
PKGNAME	:= $(PACKAGE)-$(VERSION)$(SUBVERSION)
DATE	:= $(shell date '+%Y-%m-%d')

BIN := getversion subrelease
SRC := $(BIN:%=%.pl)
DOC := $(BIN:%=doc/%.md)
LIB := $(shell ls -d *.pl)
LIB := $(filter-out $(SRC),$(LIB))

all: $(BIN) $(DOC)

%: %.pl $(LIB) .version.pl .built.%.pl Makefile
	@echo -e '#!/usr/bin/perl' > $@
	@echo "# $@ generated from $(PKGNAME)/$< $(DATE)" >> $@
	pcpp $< >> $@
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
	@echo 'our $$BUILT = "$(DATE)";' > $@
	@echo "update $@"

$(DOC): doc/%.md: % | doc
	$< -h | man2md > $@

# /map install (also subls)
ifneq ($(wildcard /map),)
install: $(BIN) subls
	mapinstall -v /box/$(PROJECT)/$(PKGNAME) /map/$(PACKAGE) bin $^

# /usr/local install
else
install: $(BIN)
	install $^ /usr/local/bin
endif

clean:
	rm -f .version.pl
	rm -f .built.*.pl

mrproper: clean
	rm -f $(BIN)
	rm -f $(DOC)

-include ~/.github/Makefile.git
