Title:		*ton* and TON
Subtitle:   Tcl Object Notation and some code to manipulate it
Author:		Georg Lehner
Copyright:	Georg Lehner <jorge@at.anteris.net>, 2018, 2019


What is it
----------

*ton* was born as a pure Tcl JSON parser. It parses JSON from right to
left and it is faster than other comparable tools, at least on Tcl8.6
and in March 2018.


How to use it
-------------

*ton* provides the `json2ton` function which convert a JSON string
with a single value or object to the TON format - a data
representation equivalent to JSON.

TON can be converted into Tcl data structures by decoders which are
trivial to write.

To decode a JSON string in `$json` into the format returned by the
Tcllib JSON parser use:

	namespace eval ton::json2dict [ton::json2ton $json]]


How it works
------------

TON stands for Tcl Object Notation, every TON representation is a Tcl
script.

TON is decoded by defining six functions: `o`, `a`, `s`, `i`, `d` and
`l`, which decode their argument(s) as object, array, string, number
(`i` .. integer, `d` .. double float)  and literal respectively.

*ton* provides namespaces with these function sets for decoding TON
 into:

`ton::2list`:
:    a nested Tcl lists

`ton::2dict`:
:    a Tcl dictionary with the same structure as returned by the
	 jimhttp JSON parser (see note below).

`ton::a2dict`:
:    a Tcl dictionary with the same structure as returned by the
     Tcllib JSON parser (see note below).

`ton::json2dict`:
:    a Tcl dictionary in the same format as the Tcllib JSON parser.

`ton::2json`:
:__  an unformatted JSON string.


Note: All but the `json2dict` decoder return strings 'as is', without
  backslash substitution.  `json2dict` uses the `subst` function for
  backslash substitution which a) might not comply with JSON, b) might
  not be 100% compatible with the Tcllib JSON parser.  Reports, tests
  and fixes are welcome.


How to choose a Tcl decoder
---------------------------

`ton::a2dict` is the most user friendly decoder, and the fastest one
for general workload.  All data is extracted with a single:

	dict get $data key key ...


`ton::2list` allows for type checking on access and is faster for huge
arrays.  Data is extracted best with a provided access function

	ton::2list::get $data key key ...


`ton::2dict` seems fastest when processing small JSON strings.  Data
extraction for mixed array and object data is cumbersome.  Suppose we
have an array of objects and want to get the email of the 43rd object:

	dict get [lindex $data 43] email


Design Goals
------------

*ton* provides a small parser implementation which can be included
directly in source code into a Tcl script and parses JSON correctly,
without overstretching correctness.


Caveats
-------

Other then taking care of backslash escaped quotes `\"` on parsing, no
processing for backslash escapes is done.

Numbers are only validated with Tcl's string is function. Hex or octal
numbers in the JSON string are therefore admissible.

**Security**: TON should be executed in a save slave interpreter to
avoid arbitrary code execution with malicious crafted JSON or TON
strings. I believe, that `ton::json2ton` does not generate dangerous
TON, but this has not been scrutinized.

ToDo
----

Craft test cases for each error in the code and for corner cases like
empty arrays.

Review the decoded data with respect to empty arrays and objects and
guarantee, that JSON -> TON -> JSON is the identity function.


References
----------

Original article:
http://at.magma-soft.at/sw/blog/posts/Reverse_JSON_parsing_with_TCL

Tcler's Wiki: http://wiki.tcl.tk/55239

Repository: http://at.magma-soft.at/darcs/ton


License Terms
-------------

In order to comply with general usage in the Tcl/Tk community *ton* is
released under a BSD style license, copied directly from the Tcllib
source tree and available in the file `license.terms`


Testing
-------

json.org offers a small test suite on the page
http://www.json.org/JSON_checker/ which we use to test ton.


http://seriot.ch/parsing_json.php goes wild about (non)-compliance and
missing clarity of specifications. Its test suite is here:
https://github.com/nst/JSONTestSuite

Changes in Version 0.5
----------------------

Added the `json2dict` decoder.  Thanks to [pozix604][] for pointing
out the inconsistency in the documentation and make me take the time
to work out a (trivial) solution.


Bugs fixed in Version 0.3
-------------------------

An invalid literal like `[0e]` would not be recognized as such, but
rather emit a string exhausted error.

Empty objects or arrays must not have an empty list as argument in
TON, e.g.: `o {}` -> `o`



Bugs fixed in Version 0.2
-------------------------

Thanks to the test suite, we could identify a list of bugs:


The following two valid JSON strings produce an error in
`ton::json2ton`:

	"k":{}
	"k":[]

The following invalid JSON string (and also any extra `]`) sends *ton*
into an infinite loop:

	]

A stray string gives an error (the double quote must be the first
character):

	"x"

An empty JSON string sends *ton* into an infinite loop.

White space in keys result in wrong or invalid TON.

`ton::json2ton` will parse the rightmost valid JSON construct in a
string, and terminate. No check is done for extra characters.


[pozix604]: https://github.com/pozix604
