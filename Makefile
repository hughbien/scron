INSTALL_BIN ?= /usr/local/bin

spec: test
test:
	crystal spec $(ARGS)

build: bin/scron
bin/scron:
	shards build --production
	rm bin/scron.dwarf

install: build
	cp bin/scron $(INSTALL_BIN)

clean:
	rm -rf bin

run:
	crystal run src/cli.cr -- $(ARGS)
