Collatio
========

** Introduction **
---------------

A tool for the creation of electronic text collatios and variorums.

** Tests **
----------

Tests are currently being developed using GTest and you'll need it to run the 
suite. You can download it from: http://code.google.com/p/googletest/

To run the test suite just run "make test-all".


GIT SETUP
==========

Global setup:
----------

  Download and install Git
  git config --global user.name "user name"
  git config --global user.email "user-email"

To Get the Git Repo:
--------------------

  mkdir Collatio
  cd Collatio
  git init
  git remote add origin git@github.com:nhocki/Collatio.git
  git pull origin master

To commit something:
--------------------

  cd Collatio
  git add <files> (you can use '.' to add everything)
  git commit -m 'commit message'
  git push origin master


