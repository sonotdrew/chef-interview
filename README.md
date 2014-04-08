# Background
We've recently begun work on separating our applications out into sections, to be serviced by different front end routing systems.  Think of it as the beginnings of [SOA](http://en.wikipedia.org/wiki/Service-oriented_architecture).  Unfortunately, we're having trouble getting a second application working successfully :frowning:.

# Your Mission
> Should you choose to accept it

Is to fix the deployment of the applications so that both of them are accessible.  Feel free to refactor if necessary.

While you're at it, we're fairly new to ruby and chef (not really, but let's pretend), and would like some input on better ways of doing things.  We'll take whatever method works best for you to provide the input.

# Some Details
The application is just a dummy application with some basic data storage requirements, such as redis, mysql, mongo, etc.  While it's important that these things work, if you find a bug within the application itself, don't worry about it... just assume we have a bug filed already :wink:.

The applications will listen on different ports:
* alpha - 8901
* beta - 8902

I suspect there's some inefficiencies in the recipes causing problems.

The application installation is based on [Vagrant](http://www.vagrantup.com), so you'll need that installed (and [VirtualBox](https://www.virtualbox.org)).  Clone this repo, run `vagrant up`, and use `vagrant ssh` if you need to access the system.

Any time you provision the vagrant (using `vagrant provision`) it'll deploy the applications.  I'm not sure if the person that wrote this expected that, but it seems weird to redeploy the same revision multiple times...

# Anyway, Good Luck!
