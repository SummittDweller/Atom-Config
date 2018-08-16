# atom-timestamp

Update timestamp comments like `Time-stamp: <Jun 02 2006>`, `Time-stamp: <2006-01-02 15:04:05>` to current date/time

This package uses [Moment.js](http://momentjs.com/) library for parsing/updating timestamp

## Installation

Use apm command:

```sh
$ apm install atom-timestamp
```

or search for `atom-timestamp` in Atom.

## Usage

### Settings

* `Timestamp Prefix`, `Timestamp Suffix` - Regular expression pattern for timestamp prefix/suffix.
* `Timestamp Formats` - Format-string for parsing/updating timestamp. Use [Moment.js format](http://momentjs.com/docs/#/displaying/format/). Time zone tokens (`z`, `zz`) and localized formats (`L`, `l`, ...) do not work.
* `Scope Selector` - Regular expression pattern for [scope name](http://flight-manual.atom.io/behind-atom/sections/scoped-settings-scopes-and-scope-descriptors/) in syntax. By default, atom-timestamp only works in comments in syntax or plain text file.
* `Number Of Lines` - Number of lines from the beginning to search timestamp comments.

### Commands

* `atom-timestamp:update-timestamp` - Update timestamp comments to current date/time
