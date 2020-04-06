# scron

Scheduler for laptops which aren't on 24/7.

## Install

Download [scron v0.1.0](https://github.com/hughbien/scron/releases/download/v0.1.0/scron)
and place it in your `$PATH`. Configure cron to run it every two hours with:

```
$ crontab -e
0 */2 * * * scron
```


## Usage

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

* `make spec` to run all tests
* `make spec ARGS=path/to/spec` to run a single test
* `make build` to create a release binary in the target directory
* `make clean` to remove build artifacts and release binary
* `make run` to run locally
* `make run ARGS=-h` to run with local arguments

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
