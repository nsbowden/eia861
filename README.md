# R Tools for Energy Information Agency (EIA) 861 Sales Data

The get861.R file contains a single function `getEIA861()`.   The `getEIA861()` function downloads, unzips, extracts the Sales to Ultimate Customers (previously file2) .xls/.xlsx files across all available years (1990 to present) and writes them as a series of csv files of the form:  

eia861Year1990.csv
...
eia861Year2001.csv     
eia861Year2002.csv    
...  
eia861Year2017.csv  

There are a few devaitions, namely in 1999 and 2000 when retail competition led to the genisis of retail power marketers and delivery service by formerly vertically integrated utilities. In 1999, retail power marketers were published to a seperate file and in 2000 retail power marketers and delivery service were published in seperate files.  Seperate from the primarly bundled service file. The `getEIA861()` functions handles this. 
 
The append861Sales.R file contains a single function `append861Sales()`.  The function reads the csv files above, appends the data within them and returns a dataframe. Orignally developed for 2001 to 2017, the function now handles the multiple files from 1999 and 2000, as well as a material formating difference that transitions at 1999. Prior to 1998, utilities operating in multiple states under a single eiaid, have multiple revenue, sales and customer numbers in the same row, i.e. there are a lot more columns. The `append861Sales()` function handles this by subsetting the columns, effectivley doubling the number of rows. Most of the members of the second subset contain only zeros because a relatively small number of utilities operate across state boundries.  However, these rows with all zero entries are not deleted from the dataframe (subject to change). 
  
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

The data frame should contain approximatley 123,000 rows and can be analyzed directly or writen to disk. The two functions together should take only a few minutes or less to run. 
