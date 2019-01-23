#
# Common Makefile for building RPMs
#

SPECFILE := i3.spec

WORKDIR := $(CURDIR)
SPECDIR ?= $(WORKDIR)
SRCRPMDIR ?= $(WORKDIR)/../srpm
BUILDDIR ?= $(WORKDIR)
RPMDIR ?= $(WORKDIR)/../rpm
SOURCEDIR := $(WORKDIR)

RPM_DEFINES := --define "_sourcedir $(SOURCEDIR)" \
               --define "_specdir $(SPECDIR)" \
               --define "_builddir $(BUILDDIR)" \
               --define "_srcrpmdir $(SRCRPMDIR)" \
               --define "_rpmdir $(RPMDIR)"

DIST_DOM0 ?= fc20

VER_REL := $(shell rpm $(RPM_DEFINES) -q --qf "%{VERSION}-%{RELEASE}\n" --specfile $(SPECFILE)| head -1|sed -e 's/fc../$(DIST_DOM0)/')
NAME := $(shell rpm $(RPM_DEFINES) -q --qf "%{NAME}\n" --specfile $(SPECFILE)| head -1)

URL := $(shell spectool $(RPM_DEFINES) --list-files --source 0 $(SPECFILE) 2> /dev/null| cut -d ' ' -f 2- )
ifndef SRC_FILE
ifdef URL
	SRC_FILE := $(notdir $(URL))
endif
endif

help:
	@echo "make rpms        -- generate binary rpm packages"
	@echo "make srpms       -- generate source rpm packages"

get-sources: $(SRC_FILE)

$(SRC_FILE):
ifneq ($(SRC_FILE), None)
	@spectool $(RPM_DEFINES) --get-files $(SPECFILE) 2> /dev/null
endif

.PHONY: verify-sources

verify-sources: $(SRC_FILE)
ifneq ($(SRC_FILE), None)
	@sha256sum --quiet -c sources
endif

.PHONY: clean-sources
clean-sources:
ifneq ($(SRC_FILE), None)
	-rm $(SRC_FILE)
endif

rpms: rpms-dom0

rpms-vm:

rpms-dom0:
	rpmbuild $(RPM_DEFINES) -bb $(SPECFILE)

srpms: verify-sources
	rpmbuild $(RPM_DEFINES) -bs $(SPECFILE)

update-repo-current:
	ln -f $(RPMDIR)/x86_64/$(NAME)*$(VER_REL)*.rpm ../../yum/current-release/current/dom0/rpm/

update-repo-current-testing:
	ln -f $(RPMDIR)/x86_64/$(NAME)*$(VER_REL)*.rpm ../../yum/current-release/current-testing/dom0/rpm/

update-repo-unstable:
	ln -f $(RPMDIR)/x86_64/$(NAME)*$(VER_REL)*.rpm ../../yum/current-release/unstable/dom0/rpm/

update-repo-installer:
	ln -f $(RPMDIR)/x86_64/$(NAME)*$(VER_REL)*.rpm ../../installer/yum/qubes-dom0/rpm/

clean:
