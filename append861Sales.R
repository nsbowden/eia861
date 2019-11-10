#######################################################
### Append EIA 861 Data: Currently for 2001 to 2017 ###  
#######################################################

datadir = "/home/nicholas/Documents/EIA861/eia861/datadownload"

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
    temp$BACode = "Not Reported"
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
  d2$bacode = "Not Reported"
  #d2 = d2[order(names(d2))]

  ### Bind first two and clean for further binding
  
  d = data.frame(rbind(d1, d2))
  d$servicetype = gsub("Bundle", "Bundled", d$servicetype)
  d$servicetype = gsub("Bundledd", "Bundled", d$servicetype)
  d$ownership = gsub("Power Marketer", "Retail Power Marketer", d$ownership)
  d$ownership = gsub("Retail Retail Power Marketer", "Retail Power Marketer", d$ownership)
  d$ownership[is.na(d$ownership) & d$utilityid == 99999] = "Adjustment"
  numvars = c('resrev', 'resq', 'resn', 'comrev', 'comq', 'comn', 'indrev', 'indq', 'indn', 'transrev', 'transq', 'transn', 'totalrev', 'totalq', 'totaln')
  ###2001-2007 missing data - must remove NAs before string ('.') matching
  d[numvars][is.na(d[numvars])] = '0'
  ###2008-2017 missing data
  d[numvars][d[numvars]=='.'] = '0'
  d[numvars] = lapply(d[numvars], as.numeric)
  ### Alter some other NAs
  d$bacode[is.na(d$bacode)] = "Not Reported"
  d$utilityid[is.na(d$utilityid) & d$utilityname=="withheld"] = 88888
  d$utilityid[is.na(d$utilityid) & d$utilityname=="Withheld"] = 88888
  ### Make a ownership cross walk
  own = d[d$year==2001, c('utilityid', 'ownership')]
  own = own[!duplicated(own),]
  names(own) = c('utilityid', 'ownership2')

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
    temp$datatype = "Not Reproted"
    temp$part = "Not Reported"
    temp$year = y3[i]
    temp$ownership = "Not Reported"
    #temp = merge(temp, own, all.x=TRUE)
    if (i == 1 | i == 3) {
    temp$servicetype = "Bundled"
    #temp$ownership = "Not Reported"
    }
    if (i == 2 | i == 4) {
    temp$servicetype = "Energy"
    temp$ownership = "Retail Power Marketer"
    }
    if (i == 5) { 
    temp$servicetype = "Delivery"
    #temp$ownership = "Not Reported"
    }
    temp = temp[v]
    d3 = data.frame(rbind(d3, temp))
  }
  
  d32 = merge(d3, own, all.x=TRUE)

  ### This piece of logic might not be straight forward but it is used two more times with no unwanted consequences and much success to fill missing ownerhsip. 
  #################################################################################################################
  ### Use this df for help d32[c('ownership', 'ownership2')][,]
  d32$ownership2[is.na(d32$ownership2)] = "Not Matched"
  ### If they are not equal, original is not reported and the match is not not found, i.e. is found.  
  uneqnrom = (d32$ownership != d32$ownership2 & d32$ownership == "Not Reported" & d32$ownership2 != "Not Matched")
  ### Then replace not reported with the found value.
  d32$ownership[uneqnrom] =  d32$ownership2[uneqnrom]
  ### Else it is not reported and we didn't find a match in the future data. 
  d32$ownership[d32$ownership == "Not Reported"] = "Not Reported or Matched"
  #################################################################################################################

  ### Drop the ownership2 var and any others not wanted
  d33 = d32[v]
  d33$bacode = "Not Reported"
  ### Merge with 1 and 2 - no duplicated rows from merges at this point nrow(d1) + nrow(d2) + nrow(d3) == nrow(dd) or nrow(d33) == nrow(d3). 
  dd = data.frame(rbind(d, d33))

  ### Need to start here and do the same ownership correction, use future values first, then without future matchs try current matches. 
  ### Read 1990 to 1998 Data Files
  
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
    ovar = c("FEDERAL", "STATE", "MUNI", "PRIVATE", "COOP")

    ###Check into the stcode2 thing , "STCODE2_1"
    temp1 = temp[c("UTILCODE", "UTILNAME", "STCODE1_1", ovar, names(temp)[q|n|r])]
    names(temp1) =  c('utilityid', 'utilityname', 'state', 'federal', 'stateown', 'muni', 'private', 'coop', 'resrev', 'comrev', 'indrev', 'transrev', 'othrev', 'totalrev', 'resq', 'comq', 'indq', 'transq', 'othq', 'totalq', 'resn',  'comn',  'indn',  'transn', 'othn', 'totaln')
    temp1$year = y4[i]
    temp2 = temp[c("UTILCODE", "UTILNAME", "STCODE2_1", ovar, names(temp)[qq|nn|rr])]
    names(temp2) =  c('utilityid', 'utilityname', 'state', 'federal', 'stateown', 'muni', 'private', 'coop', 'resrev', 'comrev', 'indrev', 'transrev', 'othrev', 'totalrev', 'resq', 'comq', 'indq', 'transq', 'othq', 'totalq', 'resn',  'comn',  'indn',  'transn', 'othn', 'totaln')
    temp2$year = y4[i]
    d4 = data.frame(rbind(d4, temp1, temp2))
  }

  numvar = c('resn', 'comn', 'indn', 'transn', 'totaln', 'resq', 'comq', 'indq', 'transq', 'totalq', 'resrev', 'comrev', 'indrev', 'transrev', 'totalrev')
  drop = rowSums(d4[numvar])
  d4 = d4[!(drop==0),]

  d4$federal[is.na(d4$federal)] = 0
  d4$stateown[is.na(d4$stateown)] = 0
  d4$muni[is.na(d4$muni)] = 0
  d4$private[is.na(d4$private)] = 0
  d4$coop[is.na(d4$coop)] = 0
  d4$ownership = "Not Reported"
  d4$ownership[d4$federal == "X"] = "Federal" 
  d4$ownership[d4$stateown == "X"] = "State" 
  d4$ownership[d4$muni == "X"] = "Municipal" 
  d4$ownership[d4$private == "X"] = "Investor Owned" 
  d4$ownership[d4$coop == "X"] = "Cooperative" 

  ### Use Future values of ownership to fill in the missing ownership values.   
  d5 = merge(d4, own, all.x=TRUE)
  d5$ownership2[is.na(d5$ownership2)] = "Not Matched"
  uneqnrom = (d5$ownership != d5$ownership2 & d5$ownership == "Not Reported" & d5$ownership2 != "Not Matched")
  d5$ownership[uneqnrom] = d5$ownership2[uneqnrom]
  d5$ownership[d5$ownership == "Not Reported"] = "Not Reported or Matched"
  d5 = d5[!grepl("^oth", names(d5))]
  d5$datatype = "Not Reported"
  d5$part = "Not Reported"
  d5$servicetype = "Bundled"
  d5 = d5[v]
  d5$bacode = "Not Reported"
 
  ### Merge with 1, 2, and 3
  ddd = data.frame(rbind(dd, d5))
  ddd = ddd[order(ddd$year, ddd$utilityid),]
  ddd$ownership[ddd$ownership == 'Wholesale Retail Power Marketer'] = "Retail Power Marketer"
  ddd$ownership[ddd$ownership == 'Community Choice Aggregator'] = "Retail Power Marketer"

  ### Use the past/current values of ownership to fill those not matched.
  own2 = unique(d4[!d4$ownership == "Not Reported", c('utilityid', 'ownership')])
  names(own2) = c('utilityid', 'ownership2')
  own3 = own2[!duplicated(own2$utilityid),]  
  df = merge(ddd, own3, all.x=TRUE)
  df$ownership2[is.na(df$ownership2)] = "Not Matched"
  uneqnrom = (df$ownership != df$ownership2 & df$ownership == "Not Reported or Matched" & df$ownership2 != "Not Matched")
  df$ownership[uneqnrom] = df$ownership2[uneqnrom]
  df$ownership[df$ownership == "Not Reported or Matched"] = "Still Not Reported or Matched"  ### They all are quite obviously small political subdivision < 2000 n 

  return(df)
}
