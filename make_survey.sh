#!/bin/bash

latex natesurvey
bibtex natesurvey
latex natesurvey
latex natesurvey
dvipdfm natesurvey.dvi
