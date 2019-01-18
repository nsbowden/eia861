### Automating the download of EIA 861 zip files and the extraction of specific datasets and the append across years. 

getEIA861 = function(datadir) {

  if(! "RCurl" %in% installed.packages()){
  install.packages("RCurl")
  } 
  library(RCurl)

  if(! "XML" %in% installed.packages()){
  install.packages("XML")
  } 
  library(XML)

  if(! "readxl" %in% installed.packages()){
  install.packages("XML")
  } 
  library(readxl)

  if(dir.exists(datadir)){
    setwd(datadir)
    } else {
    dir.create(datadir)
    setwd(datadir)
  }

  ### Get the 861 Zip File Links from EIA
  url = "https://www.eia.gov/electricity/data/eia861/"
  page = getURLContent(url)
  html = htmlParse(page)
  tda = getNodeSet(html, "//table/tr/td[2]/a")
  urlTails = sapply(tda, function(x) xmlGetAttr(x, 'href'))
  links = paste(url, urlTails, sep="")

  ### Need to loop over accounting for heterogeneity in the file names (2012 versus 07), then make all 19XX ore 20XX.

  in1 = lapply(links, function(x) strsplit(x, 'f861')[[1]][2])
  in2 = lapply(in1, function(x) strsplit(x, '\\.')[[1]][1])

  in2 = lapply(in2, function(x) ifelse((nchar(x) == 2 & as.integer(x) < 90), paste0('20', x), x))
  in2 = lapply(in2, function(x) ifelse((nchar(x) == 2 & as.integer(x) > 20), paste0('19', x), x))

  z = which(in2 == "1990")

  for (i in 1:z) {

    temp = tempfile()
    download.file(links[i], temp)
    files = unzip(temp, list=TRUE)[[1]]
    
    if (i < which(in2 == "2012")) {
    file = files[grepl("sales_ult_cust_2", files, ignore.case=TRUE)]
    stateSheet = excel_sheets(unzip(temp, file, exdir = datadir, junkpaths=FALSE))[[1]]
    d = data.frame(read_excel(unzip(temp, file, exdir = datadir, junkpaths=FALSE), sheet=stateSheet, skip = 2))
    write.csv(d, paste0(datadir, "eia861Year", in2[i], ".csv"), row.names=FALSE)
    unlink(temp)
    file.remove(file)
    }

    if (i == which(in2 == "2012")) {
    file = files[grepl("retail_sales_2012", files, ignore.case=TRUE)]
    stateSheet = excel_sheets(unzip(temp, file, exdir = datadir, junkpaths=FALSE))[[1]]
    d = data.frame(read_excel(unzip(temp, file, exdir = datadir, junkpaths=FALSE), sheet=stateSheet, skip = 2))
    write.csv(d, paste0(datadir, "eia861Year", in2[i], ".csv"), row.names=FALSE)
    unlink(temp)
    file.remove(file)
    }

    if (i > which(in2 == "2012") & i < which(in2=="2000")) {
    file = files[grepl("file2", files, ignore.case=TRUE)]
    stateSheet = excel_sheets(unzip(temp, file, exdir = datadir, junkpaths=FALSE))[[1]]
      if ( i < which(in2 == "2007")) {
      d = data.frame(read_excel(unzip(temp, file, exdir = datadir, junkpaths=FALSE), sheet=stateSheet, skip = 2))
      } else {
      d = data.frame(read_excel(unzip(temp, file, exdir = datadir, junkpaths=FALSE), sheet=stateSheet))
      }
    write.csv(d, paste0(datadir, "eia861Year", in2[i], ".csv"), row.names=FALSE)
    unlink(temp)
    file.remove(file)
    }

    if (i == which(in2 == "2000") | i == which(in2=="1999")) {
    file = files[grepl("file2", files, ignore.case=TRUE) | grepl("file3", files, ignore.case=TRUE)]
      for (j in 1:length(file)) {
        stateSheet = excel_sheets(unzip(temp, file[j], exdir = datadir, junkpaths=FALSE))[[1]]
        d = data.frame(read_excel(unzip(temp, file[j], exdir = datadir, junkpaths=FALSE), sheet=stateSheet))
        write.csv(d, paste0(datadir, "eia861Year", in2[i], "file", j, ".csv"), row.names=FALSE)
        file.remove(file[j])
      }
    unlink(temp)
    }
    if (i > which(in2 == "1999")) {
    file = files[grepl("f861typ1", files, ignore.case=TRUE)]
    stateSheet = excel_sheets(unzip(temp, file, exdir = datadir, junkpaths=FALSE))[[1]]
    d = data.frame(read_excel(unzip(temp, file, exdir = datadir, junkpaths=FALSE), sheet=stateSheet))
    write.csv(d, paste0(datadir, "eia861Year", in2[i], ".csv"), row.names=FALSE)
    unlink(temp)
    file.remove(file)
    }
  }
  unlink(list.dirs(), recursive=TRUE)
}
