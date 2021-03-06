#
# Makefile.fpc for the Testsuite of the hash-lists Project
#

[package]
main=hash-lists

[install]
fpcpackage=y

[default]
fpcdir=/usr/share/fpcsrc/3.0.0
rule=target_none

[compiler]
sourcedir=src

[target]
units=tests_pointerhash tests_objecthash tests_stringhash

[prerules]
ifdef $(TRAVIS_TEST)
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

.PHONY: test test_debug

test_debug:
      # Compile the Testsuite Application
	@$(ECHO) Tests Application: compiling ...
	@$(ECHO) "Work Directory: '${wrkdir}'"
	$(COMPILER) -MObjFPC -Scaghi -Cg -CirotR -gw2 -godwarfsets -gl -gh -Xg -gt -l -vewnhibq -Fi./lib/x86_64-linux -Fl../src -Fu../src  -Fu./ -Fu./src -Fu../../epiktimer -Fu../../fptest/src -Fu/usr/lib/lazarus/2.0.0/packager/units/x86_64-linux -FU./lib/x86_64-linux/ -FE./ -o${wrkdir}/tests_hash-lists.dbg.run ./testshashlists.lpr
	@$(ECHO) Tests Application - Executable:
        ls -lah ${wrkdir}/tests_hash-lists.dbg.run
	@$(ECHO) Tests Application: Compilation done.

test: test_debug
        # Run the Testsuite Application
	@$(ECHO) Run the Testsuite Application
	@$(ECHO) "Work Directory: '${wrkdir}'"
        #Execute the Application Tests
	@$(ECHO) "Application Tests: Executing ..."
	$(eval error_code := $(shell export HEAPTRC="log=test_heap.log" ; echo -n "" >./test_heap.log ; ${wrkdir}/tests_hash-lists.dbg.run 2>./tests_error.log 1>./tests_exec.log ; echo "$$?"))
	@$(ECHO) Application Tests: Execution finished with [${error_code}]
        #Application Tests Execution Report
	@$(ECHO) "Tests Execution - Log:"
        cat ./tests_exec.log
	@$(ECHO) "Tests Execution - Error:"
        cat ./tests_error.log
	@$(ECHO) "Tests Execution - Heap:"
        cat ./test_heap.log
        $(eval is_error := $(shell if [ "${error_code}" = "0" ]; then echo false ; else echo true ; fi ;))
ifeq (${is_error}, true)
        @$(ECHO) Exit Code non cero: '${error_code}'
        @$(ECHO) "Tests failed with Error [Code: '${error_code}']"
        @exit ${error_code}
endif
	error=`cat ./tests_error.log` ; if [ -n "$$error" ]; then echo "Tests failed with Error [Code: '${error_code}']" && exit 1; fi ;
	leak=`cat ./test_heap.log | grep -i "unfreed memory blocks" | awk '{print $$1}'` ; if [ $$leak -gt 0 ]; then echo "Memory Leaks: $$leak" && exit 1; else echo "Memory Leaks: NONE"; fi ;
	@$(ECHO) "Application Tests: PASS"

