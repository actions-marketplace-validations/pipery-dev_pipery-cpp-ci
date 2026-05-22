.PHONY: all test

all:
	mkdir -p build
	printf '#!/bin/sh\nexit 0\n' > build/pipery-failing-test
	chmod +x build/pipery-failing-test

test: all
	@echo "intentional test failure"
	@exit 2
