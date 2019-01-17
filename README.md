# EIA 861 

This repository is intended to provide tools for processing the Energy Information Agency (EIA) 861 Data.

The get861.R file contains a single function `getEIA861()`.   The `getEIA861()` function downloads, unzips, extracts the Sales to Ultimate Customers (previously file2) .xls/.xlsx files across several years (2001 to present) and writes them as a series of csv files of the form:  

eia861Year2001.csv     
eia861Year2002.csv    
...  
eia861Year2017.csv  

The append861Sales.R file contains a single function `append861Sales()`.  The function reads the csv files above, appends the data within them and returns a dataframe.

Source the `getEIA861()` and `append861Sales()` functions and then pass them each the directory where the files will be written and then read.  

```{r}
> source('get861.R')
> source("append861Sales.R")
```
```{r}
> datadir = "/home/nicholas/Documents/eia861/datadownload/"
> getEIA861(datadir)
```
```{r}
> d = append861Sales(datadir)
```

The data frame should contain approximatley 58,000 rows and can be analyzed directly or writen to disk. The two functions together should take only a few minutes or less to run. 
