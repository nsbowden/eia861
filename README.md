# Working with US EIA 861 data

This repository is intended to provide tools for accelerating the preprocessing of EIA 861 Data.

get861.R creates a directory, downloads, unzips, extracts the Sales to Ultimate Customers (previously file2) .xls/.xlsx files across several years (2001 to present) and writes them as a series of csv files of the form:

eia861Year2001.csv
eia861Year2002.csv
...
eia861Year2017.csv

append861Sales.csv unifies the columns, appends the files and write a single csv file. 

Some simple functions will be provided to process some basic economic measures, like market concerntration and HHI.
