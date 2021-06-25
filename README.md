# mcti-detect

[![Build Status](https://github.com/krono-safe/mcti-detect/workflows/CI/badge.svg)](https://github.com/krono-safe/mcti-detect/actions)

Multi-Core Time-Interferences Detector (or `mcti-detect`) is a program written
using the [D programming language][1] that analyses a **time-constrained
application** and checks whether the provided exclusion groups hold or not.

It is a proof-of-concept for the algorithms described in the paper
[Non-Simultaneity as a Design Constraint][5].

## Building from sources

You first need to install a [D toolchain][2] for your specific platform.  Then,
you just have to run the `make check` command. It will compile `mcti-detect`
and run the test harness.

## Usage

After compiling using either the `Makefile` (or directly the [dub package
manager][3]), you will find `mcti-detect` in the top source directory.
It is a command-line tool that accepts JSON files.

### Command-Line Interface

- `-t`: provide a new task, through a JSON file stored on the filesystem.
- `-g`: provide the exclusion groups, through a JSON file stored on the filesystem.
- `--show-dates`: display in the standard output the dates at which each
  temporal transition is reachable.
- `--dot-output`: produce in the specified file a dot representation of the set
  of tasks provided through `-t` and the result of the exclusion groups provided
  through `-g`.

### JSON File Formats

#### Tasks

Two top-level keys:
- `start`: the name (string) of the node that is the entry point;
- `display`: a structure to change how [dot][4] produces its files;
- `graph`: an array of nodes (see below).

A node is an object with the following structure:
- `source`: the name (string) of a node;
- `targets`: a list (non-empty) of objects with the following keys:
  - `node`: the name of the node that the source can reach;
  - `transition`: the name of the transition along the arc joining `source`
    and `node`.

The `display` key contains an array of objects, each of them containing the
following keys:
- `id` (mandatory): the name of the transition or node;
- `html`: an HTML representation of the label, that dot understands.


#### Exclusion Groups

This file shall contain a single key `"groups"` that is a list of list of
strings. Each string being a temporal transition that must be present in
the tasks.

```json
{ "groups": [ [string] ] }
```

## Example

Once you have compiled `mcti-detect`, run the following:

```bash
./mcti-detect -t examples/tasks/taskA.json \
              -t examples/tasks/taskB.json \
              -g examples/groups/A-B-with-overlap.json \
              --show-dates \
              --dot-output example.dot
```

This shall print the following:

```
B1: [{ 1 + 4k }]
B4: [{ 4 + 4k }]
B3: [{ 3 + 4k }]
B0: [{ 0 }]
B2: [{ 2 + 4k }]
A2: [{ 2 + 2k }]
A1: [{ 1 + 2k }]
A0: [{ 0 }]
Found intersection between 'A1' and 'B3' at date '3'
```

Then, convert the dot file to PDF, to observe the system that was just
described (you will need [dot][4]):

```
dot -Tpdf example.dot > example.pdf
```

In the standard output, you can see the expression of dates at which each
temporal transition is reachable. The last line states that A1 and B3 share at
least a date in common, the first one being 3. If you go through the two graphs
in the resulting PDF, and you synchronously advance by one transition in
simultaneously both graphs, you will find that after 3 transitions taken both
`A1` and `B3` can be activated at the same date. The exclusion group in this
example expected for `A1` and `B3` not to overlap. This is an example of design
that does not verify a non-interferent property.

For more examples, have a look at the [`examples/`](examples/) directory.


## Known Limitations

Currently, the JSON input files are not thouroughly checked. Ill-formatted
input files may lead to an exception being thrown at run-time.


## Contributing

Please refer to the file [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This repository is under the [Apache-V2 license](LICENSE).


[1]: https://dlang.org/
[2]: https://dlang.org/download.html
[3]: https://dub.pm/getting_started
[4]: https://graphviz.org
[5]: https://doi.org/10.4230/LIPIcs.TIME.2020.13
