# scron

Scheduler for laptops which aren't on 24/7.

## Install

**Mac**

```
brew install hughbien/tap/scron
```

This will install Crystal as a dependency. If you already have a non-homebrew Crystal installed, you
can use the `--ignore-dependencies crystal` option.

**Linux**

Download the latest binary and place it in your `$PATH`:

```
wget -O /usr/local/bin/scron https://github.com/hughbien/scron/releases/download/v0.1.1/scron-linux64
chmod +x /usr/local/bin/scron
```

MD5 checksum is: `8e0c7865f81261c871d6ba43c780af0a`

**From Source**

Checkout this repo, run `make` and `make install` (requires [Crystal](https://crystal-lang.org/install/)):

```
git clone https://github.com/hughbien/scron.git
cd scron
make
make install
```

## Usage

Configure scron to run every two hours:

```
$ crontab -e
0 */2 * * * scron
```

Configure jobs in `$HOME/.scron`. This example runs `cmd arg1 arg2` at least once every 30 days.

```
30d cmd arg1 arg2
```

You can also specify lower bounds like day of week (Su, Mo, Tu, We, Th, Fr, Sa), day of month
(23rd), or day of year (4/15):

```
Mo,Fr    cmd1
1st,23rd cmd2
4/15     cmd3
```

`cmd1` will attempt to run on Monday and Friday. If your machine is off the entire day, it will run
as soon as possible. Here's an example timeline:

* Mo: machine is off, nothing happens
* Tu: machine is on, cmd1 runs to make up for Monday
* We: already ran, nothing happens
* Th: already ran, nothing happens
* Fr: machine is on, cmd1 runs

An exit status of 0 is considered a success. Anything else is considered a failure and scron will
attempt to re-run it again in 2 hours.

`$HOME/.scrondb` keeps the timestamps of the last run commands.

`$HOME/.scronlog` has the stdout, timestamps, and exit status of last scheduled commands.

## Development

Use `make` for common tasks:

```
make build                   # to create a release binary in the bin directory
make build-static            # to build static binary for Linux
make install                 # to copy release binary into system bin (uses $INSTALL_BIN)
make spec                    # to run all tests
make spec ARGS=path/to/spec  # to run a single test
make clean                   # to remove build artifacts and bin directory
make run                     # to run locally
make run ARGS=-h             # to run with local arguments
```

## License

Copyright 2021 Hugh Bien.

Released under BSD License, see LICENSE for details.
