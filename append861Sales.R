#######################################################
### Append EIA 861 Data: Currently for 2001 to 2017 ###  
#######################################################

datadir = "/home/nicholas/Documents/EIA861/eia861/download/"
setwd(datadir)

f = list.files(datadir)
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

d[d=='0.0'] = '0'
d[d=='.'] = '0'
numvars = c('ResRev', 'ResQ', 'ResN', 'ComRev', 'ComQ', 'ComN', 'IndRev', 'IndQ', 'IndN', 'TransRev', 'TransQ', 'TransN', 'TotalRev', 'TotalQ', 'TotalN')

d[numvars] = apply(d[numvars], 2, function(i) as.numeric(gsub(",", "", i)))
d[numvars][is.na(d[numvars])] = 0

