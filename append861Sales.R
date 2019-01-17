#######################################################
### Append EIA 861 Data: Currently for 2001 to 2017 ###  
#######################################################

append861Sales = function(datadir) {

  setwd(datadir)

  f = list.files(datadir, pattern = "eia861Year")
  m = regexpr('[0-9]{4}', f)
  y = as.integer(regmatches(f, m))

  ### Post 2007 Files

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

  names(d1) = c('baCode', 'ResN',  'ComN', 'IndN', 'TransN', 'TotalN', 'dataType', 'year','ResQ','ComQ', 'IndQ', 'TransQ', 'TotalQ', "ownership", "part", "serviceType", "state",'ResRev', 'ComRev', 'IndRev', 'TransRev', 'TotalRev', "utilityName", 'utilityID')

  v = c('year', 'utilityID', "utilityName", "part", "serviceType", "dataType", "state", "ownership", 'ResRev', 'ResQ', 'ResN', 'ComRev', 'ComQ', 'ComN', 'IndRev', 'IndQ', 'IndN', 'TransRev', 'TransQ', 'TransN', 'TotalRev', 'TotalQ', 'TotalN')

  #####2001 to 2007 Data Files Processing #####

  v = c('year', 'utilityID', "utilityName", "part", "serviceType", "dataType", "state", "ownership", 'ResRev', 'ResQ', 'ResN', 'ComRev', 'ComQ', 'ComN', 'IndRev', 'IndQ', 'IndN', 'TransRev', 'TransQ', 'TransN', 'TotalRev', 'TotalQ', 'TotalN')

  d2 = data.frame()

  f2 = f[y<2008]
  for (i in 1:length(f2)) {
    temp = read.csv(f2[i], stringsAsFactors=FALSE)
    names(temp) = v
    d2 = data.frame(rbind(d2, temp))
  }

  d2$baCode = NA
  d2 = d2[order(names(d2))]

  d = data.frame(rbind(d1, d2))

  ### Some Cleaning

  d$ownership = gsub("Power Marketer", "Retail Power Marketer", d$ownership)
  d$ownership = gsub("Retail Retail Power Marketer", "Retail Power Marketer", d$ownership)
  d$ownership[is.na(d$ownership) & d$utilityID == 99999] = "Adjustment"

  numvars = c('ResRev', 'ResQ', 'ResN', 'ComRev', 'ComQ', 'ComN', 'IndRev', 'IndQ', 'IndN', 'TransRev', 'TransQ', 'TransN', 'TotalRev', 'TotalQ', 'TotalN')
  ###2001-2007 missing data - must remove NAs before string matching
  d[numvars][is.na(d[numvars])] = '0'
  ###2008-2017 missing data
  d[numvars][d[numvars]=='.'] = '0'
  d[numvars] = lapply(d[numvars], as.numeric)

  ### Alter some other NAs
  d$baCode[is.na(d$baCode)] = ""
  d$utilityID[is.na(d$utilityID) & d$utilityName=="withheld"] = 88888
  d

}
