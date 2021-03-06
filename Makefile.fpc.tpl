#
# Main Makefile.fpc for hash-lists Project
#

[package]
name=hash-lists
version=1.1.0

[install]
fpcpackage=y

[default]
fpcdir=/usr/share/fpcsrc/3.0.0
dir=tests
rule=target_none

[compiler]
sourcedir=src

[target]
units=pointerhash objecthash stringhash
exampledirs=./
examples=demohashlists

[prerules]
travis_test := $(shell if [ -n "$$TRAVIS_TEST" ]; then echo true ; else echo false ; fi ;)
ifeq (${travis_test}, true)
override DEFAULT_FPCDIR=/usr/share/fpcsrc/3.0.0
endif


[rules]
.NOTPARALLEL:

wrkdir := $(shell $(PWD))

.PHONY: target_none
target_none:
      # Compile the Demo Application
	@$(ECHO) "Don't do anything."
	@exit

.PHONY: test examples_debug

examples_debug:
      # Compile the Demo Application
	@$(ECHO) Demo Application: compiling ...
	@$(ECHO) "Work Directory: '${wrkdir}'"
	$(COMPILER) -MObjFPC -Scaghi -Cg -CirotR -gw2 -godwarfsets -gl -gh -Xg -gt -l -vewnhibq -Fi./lib/x86_64-linux -Fu./src -Fu./ -FU./lib/x86_64-linux/ -FE./ -o${wrkdir}/demo_hash-lists.dbg.run demohashlists.pas
	@$(ECHO) Demo Application - Executable:
        ls -lah ${wrkdir}/demo_hash-lists.dbg.run
	@$(ECHO) Demo Application: Compilation done.

test: examples_debug
        # Try the Demo Application
	@$(ECHO) Try the Demo Application
	@$(ECHO) "Work Directory: '${wrkdir}'"
        #Execute the Demo Application
	@$(ECHO) "Demo Application: Executing ..."
        $(eval error_code := $(shell export HEAPTRC="log=demo_heap.log" ; echo -n "" >./demo_heap.log ; ./demo_hash-lists.dbg.run 2>./demo_error.log 1>./demo_exec.log ; echo "$$?"))
	@$(ECHO) Demo Application: Execution finished with \[${error_code}\]
        #Demo Application Execution Report
	@$(ECHO) "Demo Execution - Log:"
        cat ./demo_exec.log
	@$(ECHO) "Demo Execution - Error:"
        cat ./demo_error.log
	@$(ECHO) "Demo Execution - Heap:"
        cat ./demo_heap.log
        $(eval is_error := $(shell if [ "${error_code}" = "0" ]; then echo false ; else echo true ; fi ;))
ifeq (${is_error}, true)
        @$(ECHO) Exit Code non cero: '${error_code}'
        @$(ECHO) "Demo failed with Error [Code: '${error_code}']"
        @exit ${error_code}
endif
        $(eval error := $(shell cat ./demo_error.log))
ifeq ($(strip $(error)),)
        @$(ECHO) "NO Error: '${error}'"
else
        @$(ECHO) "Error detected: '${error}'"
        $(error "Demo failed with Error [Code: '${error_code}']")
        @exit 1
endif
	$(eval leak := $(shell cat ./demo_heap.log | grep -i "unfreed memory blocks" | awk '{print $$1}'))
        $(eval has_leak := $(shell if [ "${leak}" = "0" ]; then echo false ; else echo true ; fi ;))
ifeq (${has_leak}, true)
        @$(ECHO) "Memory Leaks: ${leak}"
        @exit 1
else
        @$(ECHO) "Memory Leaks: NONE"
endif
	@$(ECHO) "Demo Application: PASS"
        $(MAKE) --directory=tests $@

