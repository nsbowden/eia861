### Automating the download of EIA 861 zip files and the extraction of specific datasets and the append across years. 

library(RCurl)
library(readxl)
library(XML)

### Get the 861 Zip File Links from EIA
url = "https://www.eia.gov/electricity/data/eia861/"
page = getURLContent(url)
html = htmlParse(page)
tda = getNodeSet(html, "//table/tr/td[2]/a")
urlTails = sapply(tda, function(x) xmlGetAttr(x, 'href'))
links = paste(url, urlTails, sep="")

### Need to loop over accounting for heterogeneity in the files.  PJM LoadDataRead addresses similar problem. 
### First only years after 2001

in1 = lapply(links, function(x) strsplit(x, 'f861')[[1]][2])
in2 = lapply(in1, function(x) strsplit(x, '\\.')[[1]][1])

### Look at in2 interactively to determine a cutoff
### Here it is based on the genesis of retail power marketers

outdir = "/home/nicholas/Documents/EIA861/eia861/"

z = which(in2 == "01")

for (i in 1:z) {

  temp = tempfile()
  download.file(links[i], temp)
  files = unzip(temp, list=TRUE)[[1]]
  
  if (i < which(in2 == "2012")) {
  file = files[grepl("sales_ult_cust_2", files, ignore.case=TRUE)]
  stateSheet = excel_sheets(unzip(temp, file, exdir = outdir, junkpaths=TRUE))[[1]]
  data = data.frame(read_excel(unzip(temp, file, exdir = outdir, junkpaths=TRUE), sheet=stateSheet, skip = 2))
  write.csv(data, paste0(outdir, "eia861Year", in2[i], ".csv"), row.names=FALSE)
  unlink(temp)
  }

  if (i == which(in2 == "2012")) {
  file = files[grepl("retail_sales_2012", files, ignore.case=TRUE)]
  stateSheet = excel_sheets(unzip(temp, file, exdir = outdir, junkpaths=TRUE))[[1]]
  data = data.frame(read_excel(unzip(temp, file, exdir = outdir, junkpaths=TRUE), sheet=stateSheet, skip = 2))
  write.csv(data, paste0(outdir, "eia861Year", in2[i], ".csv"), row.names=FALSE)
  unlink(temp)
  }

  if (i > which(in2 == "2012")) {
  file = files[grepl("file2", files, ignore.case=TRUE)]
  stateSheet = excel_sheets(unzip(temp, file, exdir = outdir, junkpaths=TRUE))[[1]]
    if ( i < which(in2 == "07")) {
    data = data.frame(read_excel(unzip(temp, file, exdir = outdir, junkpaths=TRUE), sheet=stateSheet, skip = 2))
    } else {
    data = data.frame(read_excel(unzip(temp, file, exdir = outdir, junkpaths=TRUE), sheet=stateSheet))
    }
  write.csv(data, paste0(outdir, "eia861Year", in2[i], ".csv"), row.names=FALSE)
  unlink(temp)
  }
}

