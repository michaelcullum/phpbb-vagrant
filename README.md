## Summary
This is a customised base for phpBB based upon rasmus' php7dev stuff. It uses his Debian 8 [Vagrant image](https://atlas.hashicorp.com/rasmus/boxes/php7dev) which is preconfigured for testing PHP apps and developing extensions across many versions of PHP. It is customised to be a bit more awesome and install phpBB automatically for you.

## Installation

* Install vagrant and virtual box

* `git clone git@github.com:michaelcullum/phpbb-vagrant.git && cd phpbb-vagrant`

* `git clone git@github.com:phpbb/phpbb.git --branch master phpbb`

* `vagrant up`

## Important Information (Like login details)

If you have issues with `vagrant up` due to not being able to find a box run `vagrant box add rasmus/php7dev`. See https://github.com/rlerdorf/php7dev/blob/master/README.md for more information on the box.

phpBB will install using sqlite automatically.

Run `vagrant provision` and this will kill your db and make a new one

The password for everything server-y (root, mysql etc.) is **vagrant**

Login for the phpBB installation: username `admin` // password `adminadmin`

If you want latest composer and not the composer.phar in the phpBB repo,
just use `composer`, it updates on every provision.

Feel free to adapt .bashrc in this repo with your aliases etc.

Use `scripts/customize.sh` if you want to run any other shell commands, change
the default php version from PHP 7 or set it to recompile php7 from source on
`vagrant provision`.

PHP7 is likely out of date so going onto the vm and running
`/vagrant/makephp 7 && /vagrant/newphp 7 debug` is recommended after first
setting up the vm. You can set it to do this automatically on provision by
uncommenting lines in `scripts/customize.sh` but it is quite slow (hence
commented for now).

phpBB will be accessible from your localmachine at localhost:8000

To check stuff out feel free to put the following in `phpbb/phpBB/phpinfo.php`:

```
<?php
phpinfo();
```

and navigate to http://localhost:8000/phpinfo.php to check your php settings.

I've left some relevant notes of rasmus' below. Enjoy!

## Updating your php7dev (Rasmus' box) image

```
$ vagrant box outdated
Checking if box 'rasmus/php7dev' is up to date...
A newer version of the box 'rasmus/php7dev' is available! You currently
have version '0.0.3'. The latest is version '0.0.4'. Run
`vagrant box update` to update.

$ vagrant box update
...

$ vagrant box list
rasmus/php7dev (virtualbox, 0.0.3)
rasmus/php7dev (virtualbox, 0.0.4)
```

At this point you have two versions of the box. It won't automatically destroy your current one since you could have added some important data to it.
To use this new version, make sure anything you need from your current one is saved elsewhere and do:

```
$ vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...

$ vagrant up
...
```

## Compiling the latest PHP 7

There is a script called *makephp* which does unattended builds.
To build and install the latest PHP 7.0 and PHP 7.0-debug just do:

```
$ makephp 7
```

Or you can build it manually like this:

```bash
$ cd php-src
$ git pull -r
$ make distclean
$ ./buildconf -f
$ ./cn
$ make
$ sudo make install
$ newphp 7 debug
```

Note the **./cn** script. The **--prefix** setting specifies where to install to. Make sure the path matches your debug/zts setting. You can change that script to build the non-debug version by changing **--enable-debug** to **--disable-debug** and removing **-debug** from the *--prefix**. In that case you would just do: **newphp 7**

## Adding Shared Folders

Add shared folders by adding them to the folders section in the php7dev.yaml configuration file.

## Add MySQL databases

Add the name of the database you want to be created in the databases section of the php7dev.yaml configuration file.

## Switching PHP versions

New in version 0.0.3 of the image is the ability to switch the entire PHP environment quickly. Every version of PHP since 5.3 is precompiled and installed in /usr/local/php*. There are actually 4 builds for each version. debug, zts, debug-zts and the standard non-debug, non-zts. To switch versions do:

```
$ newphp 55 debug zts
Activating PHP 5.5.22-dev and restarting php-fpm
```
If you reload **http://php7dev/** you will see the PHP 5.5 info page, but much more importanly, if you run **phpize** in an extension directory it will now build the extension for PHP 5.5-debug-zts and install it in the correct place. You can quickly switch between versions like this and build your extension for 20 different combinations of PHP versions (this was requested by @auroraeosrose so if it is useful to you, she is partly to blame - if it isn't, blame me).

For quick testing there are symlinks in */usr/local/bin* to the various versions, so you can quickly check **php56 -a** without activating it. Similarly, you can do:

```
$ service php-fpm stop
$ service php56-fpm start
```

## Debugging Tools

For debugging, you have many options. Valgrind is installed and the suppressions file is up to date. I have included a helper script I use called *memcheck*. Try it:

```valgrind
$ memcheck php -v
==3788== Memcheck, a memory error detector
==3788== Copyright (C) 2002-2011, and GNU GPL'd, by Julian Seward et al.
==3788== Using Valgrind-3.7.0 and LibVEX; rerun with -h for copyright info
==3788== Command: php -v
==3788==
PHP 7.0.0-dev (cli) (built: Jan 28 2015 15:53:12) (DEBUG)
Copyright (c) 1997-2015 The PHP Group
Zend Engine v3.0.0-dev, Copyright (c) 1998-2015 Zend Technologies
    with Zend OPcache v7.0.4-dev, Copyright (c) 1999-2015, by Zend Technologies
==3788==
==3788== HEAP SUMMARY:
==3788==     in use at exit: 19,112 bytes in 17 blocks
==3788==   total heap usage: 29,459 allocs, 29,442 frees, 3,033,303 bytes allocated
==3788==
==3788== LEAK SUMMARY:
==3788==    definitely lost: 0 bytes in 0 blocks
==3788==    indirectly lost: 0 bytes in 0 blocks
==3788==      possibly lost: 0 bytes in 0 blocks
==3788==    still reachable: 0 bytes in 0 blocks
==3788==         suppressed: 19,112 bytes in 17 blocks
==3788==
==3788== For counts of detected and suppressed errors, rerun with: -v
==3788== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 28 from 6)
```

Also, sometimes it is easier to track down issues with a single standalone process instead of using php-fpm. You can do this like this:

```
$ sudo service php-fpm stop
$ sudo php-cgi -b /var/run/php-fpm.sock
```

The debug build will report memory leaks and you can of course run it
under gdb or valgrind as well. See the */usr/local/bin/memcheck* script
for how to run Valgrind.

You will also find a .gdbinit symlink in *~vagrant* which provides a number of useful gdb macros. The symlink into php-src should ensure you have the right set for the current checked out version of the code.

## APT

And a tiny apt primer:
* update pkg list: **sudo apt-get update**
* search for stuff: **apt-cache search stuff**
* install stuff: **sudo apt-get install stuff**
* list installed: **dpkg -l**
* upgrade installed: **apt-get upgrade**
