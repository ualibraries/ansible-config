# ualibraries/ansible-config

## Disclaimer.

*WORK IN PROGRESS*

Mike Simpson is to blame for this.

Some day, this will hopefully expand to control some non-trivial
proportion of our inventory and service offerings; starting out small
by managing the Open Arizona service hosts. Once this stabilizes, you
should generally expect to find the master branch checked out into
ansible1.library.arizona.edu:/etc/ansible. That instance of Ansible
will probably wind up being mostly for checking the whole fleet for
deviations from the official configuration, and reporting those
differences to some mailing list or another, probably out of a
cron job of some kind.

## Running local.

To run Ansible on your local development environment, you could do
something like this (if you're on a Mac, and already have Homebrew
installed) while at the root of your Github repository clone:

    % brew update
    % brew install pyenv
    % brew install pyenv-virtualenv

        [ add shim lines into shell startup files per output ]

    % pyenv install 2.7.15
    % pyenv virtualenv 2.7.15 ual-ansible-config
    % pyenv local ual-ansible-config
    % pip install ansible
    % pip install pyvmomi

That should get you running on a sandboxed Python with latest-version
Ansible plus module dependencies installed.

# TBD.

More documentation.

Remember, this is Mike's fault.

