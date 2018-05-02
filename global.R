# convert matrix to dataframe
# state_stat <- data.frame(state.name = rownames(state.x77), state.x77)
library(plyr)
library(data.table)
library(dplyr)
library(RSQLite)
library(DBI)
library(tools)
library(DT)
library(plotly)
library(scales)


dbname = "tree_2015.sqlite"
tablename = "tree2015_clean_dt"

dbConnector <- function(session, dbname) {
  require(RSQLite)
  ## setup connection to database
  conn <- dbConnect(drv = SQLite(), 
                    dbname = dbname)
  ## disconnect database when session ends
  session$onSessionEnded(function() {
    dbDisconnect(conn)
  })
  ## return connection
  conn
}




# Bring SQLite data in as data.table
db = src_sqlite('./tree_2015.sqlite')

sql_data <- tbl(db, tablename)
# We can pass SQL directly here to select only the columns of interest
# I 'rename' the columns with spaces to be able to properly access them in dplyr
sql_data <- tbl(db, sql('SELECT tree_id, block_id, created_at, status, health, spc_common, latitude, longitude,
                        borocode, borough, address, postcode, user_type, steward,	guards,	sidewalk, problems 
                        FROM tree2015_clean_dt'))

chart_data = sql_data %>% 
  select(., borough, health, problems, steward,	guards,	sidewalk) %>% 
  group_by(., borough, health) %>% 
  mutate(., tot = n())

health_g = chart_data %>% 
  group_by(., borough, health) %>% 
  summarise(., Total_trees = n())


chart_tdb = dbConnect(RSQLite::SQLite(), './tree_2015.sqlite')

chart_query ='SELECT tree_id, block_id, created_at, status, health, spc_common, latitude, longitude,
                      borocode, borough, address, postcode, user_type, steward,	guards,	sidewalk, problems 
                      FROM tree2015_clean_dt
                      WHERE health = "Poor" OR health = "Good" OR health = "Fair"'

chart_health_result=dbGetQuery(chart_tdb,chart_query)

# Grouped item for Tree Health
nyc_trees = chart_health_result %>% 
  group_by(., borough) %>% 
  summarise(., Total_trees = n()) %>% 
  mutate(., prop = Total_trees/sum(Total_trees))


# Grouped item for Tree Health
health_g = chart_health_result %>% 
  group_by(., borough, health) %>% 
  summarise(., Total_trees = n()) %>% 
  mutate(., prop = Total_trees/sum(Total_trees)) 

health_g$health <- factor(health_g$health, levels = c('Good','Fair','Poor'))





  #geom_bar(stat = 'identity', position=position_dodge(), show.legend = T) + xlab(NULL) + ylab(NULL)


# head_ <- function(x, n = 5) kable(head(x, n))
# head_(sql_data)

# dbGetData <- function(conn, tablename) {
#      query <- paste("SELECT tree_id, block_id, created_at, status, health, spc_common, latitude, longitude,
#                      borocode, borough, address, postcode, user_type, steward,	guards,	sidewalk, problems 
#                      FROM", tablename)  
#      as.data.table(dbGetQuery(conn = conn, statement = query))
# }


tree_2015_data=read.csv("./Tree_2015_boro_nta.csv", stringsAsFactors =FALSE)
tree_2015_data2=read.csv("./Tree_2015_boro_spc.csv", stringsAsFactors =FALSE)

pop_tree_comp=read.csv("./2005_2015_pop_comp.csv", stringsAsFactors =FALSE)

v = tree_2015_data2['spc_common']
v = sapply(X = v, FUN = as.character)
v = sapply(v, toTitleCase)
tree_2015_data2['spc_common'] = v


tree_2005_data=read.csv("./Tree_2005_boro_nta.csv", stringsAsFactors =FALSE)
tree_2005_data2=read.csv("./Tree_2005_boro_spc.csv", stringsAsFactors =FALSE)




#tree2015_clean = read.csv('./Tree_2015_clean.csv', stringsAsFactors = F, header=TRUE)

# remove row names
#rownames(tree2015_clean) <- NULL
#tree2015_clean['X'] <- NULL

#tree2015_tc = tree2015_clean %>% 
#  select(., c(1,2,3,7,8,10,38,39,29,30,25,26,14))

# create variable with colnames as choice
#choice <- colnames(tree2015_tc)[-1]


#tree2015_group = tree2015_tc %>% 
#  group_by(., block_id) 

#tree2015_group2 = tree2015_group %>% 
#  summarise(., Block_total = n(), 
#            Latitude = mean(latitude),
#            Longitude = mean(longitude))



