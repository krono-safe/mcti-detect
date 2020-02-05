# Examples

This directory contains two kinds of JSON files:
- description of tasks; and
- description of exclusion groups.

The `img/` directory lists some scenarios that are described in the
`scripts/test.sh` file. They are shown below. Each figure shows the different
tasks that compose the application. Red temporal transitions are the ones that
were in the same exclusion group but overlap (the first overlap date is
specified).  Green temporal transitions are the ones that do not overlap with
others.  If all temporal transitions are green, it means there are no overlap,
and the exclusion group holds.


## A-B-no-overlap

![A-B-no-overlap](img/A-B-no-overlap.dot.jpeg)

## A-B-with-overlap

![A-B-with-overlap](img/A-B-with-overlap.dot.jpeg)

## B-C-with-overlap

![B-C-with-overlap](img/B-C-with-overlap.dot.jpeg)

## B-C-with-overlap2

![B-C-with-overlap2](img/B-C-with-overlap2.dot.jpeg)

## C-D-with-overlap

![C-D-overlap](img/C-D-overlap.dot.jpeg)

## D-E-no-overlap

![D-E-no-overlap](img/D-E-no-overlap.dot.jpeg)

## D-E-with-overlap

![D-E-with-overlap](img/D-E-with-overlap.dot.jpeg)

## A-F-no-overlap

![A-F-no-overlap](img/A-F-no-overlap.dot.jpeg)
