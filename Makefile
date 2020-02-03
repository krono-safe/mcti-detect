.PHONY: all check

DUB ?= dub
PROGRAM := mcti-detect

$(PROGRAM): FORCE
	$(DUB) build

check: $(PROGRAM)
	scripts/test.sh

FORCE:
