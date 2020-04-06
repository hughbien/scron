INSTALL_BIN ?= /usr/local/bin

spec: test
test:
	crystal spec $(ARGS)

build: target/scron
target/scron:
	crystal build src/cli.cr --release
	mkdir -p target
	mv cli target/scron
	rm cli.dwarf

install: build
	cp target/scron $(INSTALL_BIN)

clean:
	rm -rf cli cli.dwarf target

run:
	crystal run src/cli.cr -- $(ARGS)
