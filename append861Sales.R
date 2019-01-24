#######################################################
### Append EIA 861 Data: Currently for 2001 to 2017 ###  
#######################################################

append861Sales = function(datadir) {

  setwd(datadir)

  f = list.files(datadir, pattern = "eia861Year")
  m = regexpr('[0-9]{4}', f)
  y = as.integer(regmatches(f, m))
  v = c('year', 'utilityid', "utilityname", "part", "servicetype", "datatype", "state", "ownership", 'resrev', 'resq', 'resn', 'comrev', 'comq', 'comn', 'indrev', 'indq', 'indn', 'transrev', 'transq', 'transn', 'totalrev', 'totalq', 'totaln')

  ### Read 2007 to 2017 Data Files

  f1 = f[y>2007]
  d1 = data.frame()

  for (i in 1:length(f1)) {
    temp = read.csv(f1[i], stringsAsFactors=FALSE)
    names(temp) = gsub("[_]+", ".", names(temp))
    names(temp) = gsub("[.]+", "", names(temp))
    names(temp) = gsub("Thousands", "Thousand", names(temp))
    names(temp) = gsub("SERVICETYPE", "ServiceType", names(temp))
    names(temp) = gsub("BACODE", "BACode", names(temp))
    if (!"BACode" %in% names(temp)) {
    temp$BACode = NA
    }
    if (is.na(temp[nrow(temp), 'DataYear'])) {
    temp = temp[-nrow(temp),]
    }
    temp = temp[order(names(temp))]
    d1 = data.frame(rbind(d1, temp))
  }

  names(d1) = c('bacode', 'resn',  'comn', 'indn', 'transn', 'totaln', 'datatype', 'year','resq','comq', 'indq', 'transq', 'totalq', "ownership", "part", "servicetype", "state",'resrev', 'comrev', 'indrev', 'transrev', 'totalrev', "utilityname", 'utilityid')

  ### Read 2001 to 2007 Data Files

  d2 = data.frame()
  f2 = f[ y > 2000 & y < 2008 ]
  
  for (i in 1:length(f2)) {
    temp = read.csv(f2[i], stringsAsFactors=FALSE)
    names(temp) = v
    d2 = data.frame(rbind(d2, temp))
  }

  d2$bacode = NA
  d2 = d2[order(names(d2))]

  ### Bind first two and clean for further binding
  
  d = data.frame(rbind(d1, d2))
  d$servicetype = gsub("Bundle", "Bundled", d$servicetype)
  d$servicetype = gsub("Bundledd", "Bundled", d$servicetype)
  d$ownership = gsub("Power Marketer", "Retail Power Marketer", d$ownership)
  d$ownership = gsub("Retail Retail Power Marketer", "Retail Power Marketer", d$ownership)
  d$ownership[is.na(d$ownership) & d$utilityid == 99999] = "Adjustment"
  numvars = c('resrev', 'resq', 'resn', 'comrev', 'comq', 'comn', 'indrev', 'indq', 'indn', 'transrev', 'transq', 'transn', 'totalrev', 'totalq', 'totaln')
  ###2001-2007 missing data - must remove NAs before string matching
  d[numvars][is.na(d[numvars])] = '0'
  ###2008-2017 missing data
  d[numvars][d[numvars]=='.'] = '0'
  d[numvars] = lapply(d[numvars], as.numeric)
  ### Alter some other NAs
  #d$bacode[is.na(d$bacode)] = ""
  d$utilityid[is.na(d$utilityid) & d$utilityname=="withheld"] = 88888
  ### Make a ownership cross walk
  own = d[d$year==2001, c('utilityid', 'ownership')]
  own = own[!duplicated(own),]

  ### Read 1999 and 2000 Data Files

  f3 = f[ y > 1998 & y < 2001 ]
  y3 = y[y > 1998 & y < 2001]
  d3 = data.frame()

  for (i in 1:length(f3)) {
    temp = read.csv(f3[i], stringsAsFactors=FALSE)
    names(temp) = tolower(names(temp))
    names(temp) = gsub("_", "", names(temp))
    names(temp) = gsub("sales$", "q", names(temp))
    names(temp) = gsub("cons$", "n", names(temp))
    names(temp) = gsub("^util", "utility", names(temp))
    names(temp) = gsub("^tot", "total", names(temp))
    names(temp) = gsub("^hwy", "trans", names(temp))
    names(temp) = gsub("code$", "id", names(temp))
    temp = temp[!grepl("^oth", names(temp))]
    temp$datatype = ""
    temp$part = ""
    temp$year = y3[i]
    temp = merge(temp, own, all.x=TRUE)
    if (i == 1 | i == 3) {
    temp$servicetype = "Bundled"
    }
    if (i == 2 | i == 4) {
    temp$servicetype = "Energy"
    ### perhaps all should be rpm
    #temp$ownership[is.na(temp$ownership)] = "Retail Power Marketer"
    temp$ownership = "Retail Power Marketer"
    }
    if (i == 5) { 
    temp$servicetype = "Delivery"
    }
    temp = temp[v]
    d3 = data.frame(rbind(d3, temp))
  }
  
  d3$bacode = NA
  
  ### Merge with 1 and 2
  
  dd = data.frame(rbind(d, d3))

  ### Read 1990 to 1999 Data Files
  
  d4 = data.frame()
  f4 = f[ y < 1999 ]
  y4 = y[ y < 1999 ]

  for (i in 1:length(f4)) {
    temp = read.csv(f4[i], stringsAsFactors=FALSE)
    q = grepl("MWH1", names(temp))
    n = grepl("CONSUM1", names(temp))
    r = grepl("REV1", names(temp))
    qq = grepl("MWH2", names(temp))
    nn = grepl("CONSUM2", names(temp))
    rr = grepl("REV2", names(temp))

    ###Check into the stcode2 thing , "STCODE2_1"
    temp1 = temp[c("UTILCODE", "UTILNAME", "STCODE1_1", names(temp)[q|n|r])]
    names(temp1) =  c('utilityid', 'utilityname', 'state', 'resrev', 'comrev', 'indrev', 'transrev', 'othrev', 'totalrev', 'resq', 'comq', 'indq', 'transq', 'othq', 'totalq', 'resn',  'comn',  'indn',  'transn', 'othn', 'totaln')
    temp1$year = y4[i]
    temp2 = temp[c("UTILCODE", "UTILNAME", "STCODE2_1", names(temp)[qq|nn|rr])]
    names(temp2) =  c('utilityid', 'utilityname', 'state', 'resrev', 'comrev', 'indrev', 'transrev', 'othrev', 'totalrev', 'resq', 'comq', 'indq', 'transq', 'othq', 'totalq', 'resn',  'comn',  'indn',  'transn', 'othn', 'totaln')
    temp2$year = y4[i]
    d4 = data.frame(rbind(d4, temp1, temp2))
  }

  d4 = d4[!grepl("^oth", names(d4))]
  d4$datatype = ""
  d4$part = ""
  d4$servicetype = "Bundled"
  d4 = merge(d4, own, all.x=TRUE)
  ### ownership = NA entries are likely the ones who went off the main dataset into the S dataset
  d4 = d4[v]
  d4$bacode = NA
 
  ### Merge with 1, 2, and 3

  ddd = data.frame(rbind(dd, d4))
  ddd = ddd[order(ddd$year, ddd$utilityid),]
  ddd
}
