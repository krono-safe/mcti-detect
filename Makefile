.PHONY: all check help

DUB ?= dub
PROGRAM := mcti-detect

all: $(PROGRAM)

$(PROGRAM): FORCE
	$(DUB) build

check: $(PROGRAM)
	scripts/test.sh

FORCE:

help:
	@echo "Targets:"
	@echo "    all: build $(PROGRAM)"
	@echo "  check: run the test suite"
