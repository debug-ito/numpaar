Numpaar: NUMber Pad As A Remote
===============================

Numpaar is a program that turns your (possibly wireless) number pad
into a remote that controls your computer. You can think of it as just
another keyboard shortcut program, but it's more powerful and
extendable than traditional ones.


FEATURES
--------

* Runs on Linux. (Tested under Ubuntu Linux)
* Bind any key on a number pad to any script written in Perl.
* Automatically change key bindings according to the active window.
* Stateful key bindings.
* Object-oriented key binding customization (based on Perl modules).


PREREQUISITES
-------------

* xdotool and libxdo
    * http://www.semicomplete.com/projects/xdotool/
    * The latest version is recommended.
    * Requires libxtst to build it.
* Perl environment
    * Class::Inspector module
* Python environment
    * PyGTK


INSTALL
-------

1. Place the source tree somewhere, say /opt/numpaar/
2. Build

        $ cd /opt/numpaar
        $ make

3. Set PATH and PERL5LIB to /opt/numpaar and /opt/numpaar/lib, respectively. For example,

        $ echo 'export PATH="/opt/numpaar:$PATH"' >> ~/.profile
        $ echo 'export PERL5LIB="/opt/numpaar/lib:$PERL5LIB"' >> ~/.profile

4. Create configuration file '.numpaar' in your home directory.

        $ cp /opt/numpaar/dot.numpaar.sample ~/

5. Edit ~/.numpaar as you like.



HOW TO USE
----------

Simply execute numpaar.

    $ numpaar

If you already run numpaar, it is killed.



TODO
----

* Internationalization.
* Write document on how to configure Numpaar.
* Automate installation process.



AUTHOR
------

Toshio Ito

* https://github.com/debug-ito
* debug.ito@gmail.com



