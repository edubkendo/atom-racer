# Changelog

## v0.9.1 (2015-02-04)
Switch to registering a provider service declaratively through package.json

## v0.9.0 (2015-02-01)
Use the new Provider API from "autocomplete-plus"

* Conform to the new autocomplete-plus Providers API
* Back to calling the "racer" process asynchronously (along with temporary file creation)
* Code cleanup and safety

## v0.8.0 (2014-12-27)
Make it full synchronous to conform to the current "autocomplete-plus" API state.
This is temporary, waiting for an asynchronous API to emerge in the future.

* Call the "racer" process synchronously (along with temporary file creation)
* Remove unused or not required modules dependencies
* Update to conform to the autocomplete-plus Providers best practices

## v0.7.1 (2014-12-20)
Windows fix

* Use semicolon environment variable separator on win32

## v0.7.0 (2014-12-15)
Cleanup

* Remove filtering package from deps
* Don't filter suggestions
* Remove pathwatcher dep

## v0.6.0 (2014-11-27)
Full refactor

* Use Coffeescript instead of Ruby (+ Opal javascript conversion)
* Add a changelog
* Add a Travis CI file to build and test the module
* Update module dependencies
* Enrich the package.json
* Display the type and file along with the proposed completion (ex: "HashMap Struct (map.rs)")

## v0.5.0 (2014-11-10)
Conformance to atom

* Include tilt in the Rakefile
* Remove "atom-" prefix to access config elements

## v0.4.0 (2014-09-02)
Fix for changes in atom api

## v0.3.0 (2014-08-30)
Update package.json

## v0.2.2 (2014-05-13)
Update README.md with real example paths

## v0.2.1 (2014-05-07)
Remove hardcoded paths

## v0.2.0 (2014-05-06)
Fix picture for atom registry

## v0.1.0 (2014-05-06)
Initial release
