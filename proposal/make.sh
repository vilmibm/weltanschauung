#!/bin/bash

latex   $1
bibtex  $1
latex   $1
latex   $1
dvipdfm $1.dvi
