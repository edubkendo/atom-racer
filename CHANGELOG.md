# Changelog

## v0.17.2 (2015-09-11)
Workaround for race condition caused by multiple racer processes being opened as the user types.

## v0.17.1 (2015-08-16)
Prints error from stderr if there is any.

## v0.17.0 (2015-08-14)
Adds snippet functionality and shows return type of functions.

## v0.16.0 (2015-08-04)
Alert users with useful notifications when error conditions occur.

## v0.15.2 (2015-06-24)
Allow symbolic links to be used for racer executable and rustc sourcecode directory.

## v0.15.1 (2015-06-24)
Broken suggestions bug fix.

## v0.15.0 (2015-06-22)
Add a "find definition" feature.

## v0.14.2 (2015-06-19)
Update the README to mention our dependency on the language-rust package.

## v0.14.1 (2015-06-19)
Update the README to have a FAQ that serves as our manual.

## v0.14.0 (2015-06-15)
Put the temporary files directly into the project directory to help racer locate and use cargo and complete dependencies.

* move temp file to current file's directory.
* remove project path from RUST_SRC_PATH since it's automatically found by racer now the temp file is in the project directory.

## v0.13.0 (2015-06-09)
Skipped

## v0.12.0 (2015-06-09)
Avoid misconfiguration and try to help racer to find a Cargo.toml by writing temp files in the project directory

* Rewrite the README file so that it warns for misconfiguration and is more structured.
* Do not launch completion if the configuration is obviously wrong.
* Check that "racer.racerBinPath" points to a valid file.
* Check that "racer.rustSrcPath" points to a valid directory.
* Rescan the current project path for each completion because it can change during the editor's life.
* Write the temporary file directly in the project path to help racer locate a related Cargo.toml.
* Clean temp files immediately after racer returns.

## v0.11.0 (2015-05-19)
Migrate to autocomplete-plus v2.0 providers API

* Use the 2.0.0 Provider API from "autocomplete-plus"
* Add new setting to blacklist user-specified selectors from triggering completion
* Benefit from the new GUI possibilities of v2 provider's API to give clues about the types of the proposed completions
* Update dependencies

## v0.10.1 (2015-04-13)
Fixes Atom API deprecated use of project.getPath()

## v0.10.0 (2015-04-11)
Better handling of temp files

* Close temp files
* Dont run racer on temp file creation error

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
