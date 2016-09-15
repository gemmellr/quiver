export PATH := ${PWD}/install/bin:${PATH}

DESTDIR := ""
PREFIX := ${HOME}/.local
QUIVER_HOME = ${PREFIX}/lib/quiver

.PHONY: default
default: devel

.PHONY: help
help:
	@echo "build          Build the code"
	@echo "install        Install the code"
	@echo "clean          Clean up the source tree"
	@echo "devel          Build, install, and test in this checkout"

.PHONY: clean
clean:
	rm -rf build
	rm -rf install

.PHONY: build
build: build/exec/quiver-qpid-messaging-cpp build/exec/quiver-qpid-proton-cpp build-java
	scripts/configure-file exec/quiver-qpid-proton-python.in build/exec/quiver-qpid-proton-python \
		quiver_home ${QUIVER_HOME}
	scripts/configure-file exec/quiver-qpid-jms.in build/exec/quiver-qpid-jms \
		quiver_home ${QUIVER_HOME}
	scripts/configure-file exec/quiver-qpid-messaging-python.in build/exec/quiver-qpid-messaging-python \
		quiver_home ${QUIVER_HOME}
	scripts/configure-file bin/quiver.in build/bin/quiver \
		quiver_home ${QUIVER_HOME}

.PHONY: build-java
build-java:
	rm -rf build/java
	mkdir -p build/java
	cd java && mvn package
	cp java/target/quiver-*-jar-with-dependencies.jar build/java/quiver.jar

.PHONY: install
install: build
	mkdir -p ${DESTDIR}${QUIVER_HOME}
	scripts/install-files python ${DESTDIR}${QUIVER_HOME}/python \*.py
	scripts/install-files build/java ${DESTDIR}${QUIVER_HOME}/java \*
	scripts/install-files build/exec ${DESTDIR}${QUIVER_HOME}/exec \*
	scripts/install-executable build/bin/quiver ${DESTDIR}${PREFIX}/bin/quiver

.PHONY: devel
devel: PREFIX := ${PWD}/install
devel: clean install
	scripts/smoke-test 10

build/exec/quiver-qpid-messaging-cpp: exec/quiver-qpid-messaging-cpp.cpp
	mkdir -p build/exec
	gcc -std=c++11 -lqpidmessaging -lqpidtypes -lstdc++ $< -o $@

build/exec/quiver-qpid-proton-cpp: exec/quiver-qpid-proton-cpp.cpp
	mkdir -p build/exec
	gcc -std=c++11 -lqpid-proton -lstdc++ $< -o $@
