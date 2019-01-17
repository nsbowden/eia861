# EIA 861 

This repository is intended to provide tools for processing the Energy Information Agency (EIA) 861 Data.

The get861.R file contains a single function `getEIA861()`.  The function takes a single write directory argument. The `getEIA861()` function downloads, unzips, extracts the Sales to Ultimate Customers (previously file2) .xls/.xlsx files across several years (2001 to present) and writes them as a series of csv files of the form:  

eia861Year2001.csv     
eia861Year2002.csv    
...  
eia861Year2017.csv  

The `getEIA861()` function can be sourced and then passed the write directory argument, for example `datadir` shown here.

```{r}
> source('get861.R')
> datadir = "/home/nicholas/Documents/eia861/datadownload/"
> getEIA861(datadir)
```

The append861Sales.R file contains a single function `append861Sales()`.  Pass the read directory (where we just wrote the files) to the function and it returns a dataframe of the appended csv, returned from `getEIA861()`.  The `getEIA861()` function steps into the datadownload directory, so I source append861Sales.R using its full path. 

```{r}
> source("/home/nicholas/Documents/eia861/append861Sales.R")
> d = append861Sales(datadir)
```

The data frame should contain approximatley 58,000 rows and can be analyzed directly or writen to disk. The two functions together should take only a few minutes to run. 
