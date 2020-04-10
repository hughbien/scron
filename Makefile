INSTALL_BIN ?= /usr/local/bin
VERSION = $(shell cat shard.yml | grep version | sed -e "s/version: //")

spec: test
test:
	crystal spec $(ARGS)

build: bin/scron
bin/scron:
	shards build --production
	rm bin/scron.dwarf

release: build
	mv bin/scron bin/scron-darwin64-$(VERSION)
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:latest-alpine shards build --production --static
	mv bin/scron bin/scron-linux64-$(VERSION)

install: build
	cp bin/scron $(INSTALL_BIN)

clean:
	rm -rf bin

run:
	crystal run src/cli.cr -- $(ARGS)
