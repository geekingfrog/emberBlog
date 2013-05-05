# Toy project

The goal is to learn ember.js, and later on, the Foundation framework (or
how to design a responsive website).

# Build end develop
This project is not really meant to be develop by other people, however, sice I'll forget, I'm writing down here what is needed to build this webapp.

* grunt cli (npm install -g grunt-cli)
* ruby and sass gem installed check out [rvm](http://https://rvm.io) 
* npm install
* grunt // build all the stuff for dev
* grunt dist // build stuff for production
* grunt server // launch a local server for dev: head to localhost:4445/devIndex.html
* grunt watch

You'll need to enable cross domain request to get something from the server since the backend url is hardcoded as my blog (and this is obviously different from localhost).

# Stuff to improve

user input validation on comments. Currently, I silently don't do anything if the input is invalid. A better way would do to display some warning messages.
