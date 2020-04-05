# scron

Scheduler for laptops which aren't on 24/7.

## Install

Download the `scron` binary in the latest release and place it in your `$PATH`. Then configure cron
to run it every two hours with:

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

Use the `bin/build` script for tasks:

* `bin/build run -- -h` to run locally
* `bin/build spec` to run tests
* `bin/build release` to build a release binary
* `bin/build clean` to clean build artifacts

## TODO

* add logging to `.scronlog`
* add history reading/parsing
* add history writing/touch
* add schedule parsing
* hook up history/schedule/overdue checking

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
