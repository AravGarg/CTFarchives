# Changelog

## 1.4.0
date: 2017-09-22

- add option to show full path to single file
- list actual list of generated wrappers in show

## 1.3.2
date: 2017-09-10

- Avoid nested chdir warnings #11

## 1.3.1
date: 2017-08-24

- detect ruby executables instead of using hardcoded list

## 1.3.0
date: 2017-07-08

- add check if target files actually exist and are executable, fix #9
- silence ivar warning in rubygems test suite, fix #7

## 1.2.7
date: 2014-10-10

- improved command handling

## 1.2.6.1
date: 2014-10-10

- improved output of listing executables

## 1.2.6
date: 2014-10-10

- show list of executables
- show info when `$GEM_WRAPPERS_DEBUG` is set

## 1.2.5
date: 2014-05-27

- allow generating formatted binary wrappers, fix #5

## 1.2.4
date: 2014-01-03

- require fileutils - needed on older rubies

## 1.2.3
date: 2013-12-31

- fix uninstalling gems and add tests for it

## 1.2.2
date: 2013-12-31

- improved tests
- improved code to detect and set executable bits for the created wrapper, fix #3

## 1.2.1
date: 2013-12-22

- Add `ri`, `rdoc` and `testrb` to the list of default ruby executables

## 1.2.0
date: 2013-12-22

- Add support for generating scripts wrappers
- Improved gems searching and tests

## 1.1.0
date: 2013-12-20

- Add functionality to uninstall wrappers when gem is uninstalled

## 1.0.0
date: 2013-12-19

- Stable version released
