PACKAGE	:= subrelease
VERSION	:= 0.12
AUTHORS	:= R.Jaksa 2001,2021,2023 GPLv3
SUBVERS	:= c

SHELL	:= /bin/bash
PATH	:= usr/bin:$(PATH)
PKGNAME	:= $(PACKAGE)-$(VERSION)$(SUBVERSION)
PROJECT := $(shell getversion -prj)
DATE	:= $(shell date '+%Y-%m-%d')

BIN	:= getversion subrelease
DEP	:= $(BIN:%=.%.d)
DOC	:= $(BIN:%=%.md)

all: $(BIN) $(DOC)

$(BIN): %: %.pl .%.d .version.pl .%.built.pl Makefile
	@echo -e '#!/usr/bin/perl' > $@
	@echo "# $@ generated from $(PKGNAME)/$< $(DATE)" >> $@
	pcpp $< >> $@
	@chmod 755 $@
	@sync

$(DEP): .%.d: %.pl
	pcpp -d $(<:%.pl=%) $< > $@

$(DOC): %.md: %
	./$* -h | man2md > $@

.version.pl: Makefile
	@echo 'our $$PACKAGE = "$(PACKAGE)";' > $@
	@echo 'our $$VERSION = "$(VERSION)";' >> $@
	@echo 'our $$AUTHOR = "$(AUTHORS)";' >> $@
	@echo 'our $$SUBVERSION = "$(SUBVERS)";' >> $@
	@echo "update $@"

.PRECIOUS: .%.built.pl
.%.built.pl: %.pl .version.pl Makefile
	@echo 'our $$BUILT = "$(DATE)";' > $@
	@echo "update $@"

# /map install, requires /map directory and getversion and mapinstall tools
ifneq ($(wildcard /map),)
install: $(BIN) subls
	mapinstall -v /box/$(PROJECT)/$(PKGNAME) /map/$(PACKAGE) bin $^
	mapinstall -v /box/$(PROJECT)/$(PKGNAME) /map/$(PACKAGE) doc $(DOC) README.md
	mkdir -p /map/$(PACKAGE)/doc/img
	mapinstall -v /box/$(PROJECT)/$(PKGNAME) /map/$(PACKAGE) doc/img img/*

# /usr/local install
else
install: $(BIN)
	install $(BIN) /usr/local/bin
endif

clean:
	rm -f .version.pl
	rm -f .*.built.pl
	rm -f $(DEP)

mrproper: clean
	rm -f $(DOC) $(BIN)

-include $(DEP)
-include ~/.github/Makefile.git
