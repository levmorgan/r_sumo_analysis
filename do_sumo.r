library("xml")

# Loop: fetch and merge sumo tables

test_elFun = function(node) {
    if(length(node) > 0 && xmlName(node[[1]]) == "img") {
        node_attrs <- xmlAttrs(node[[1]])
        if(any(node_attrs == "img/hoshi_kuro.gif")) {
            return("0")
        }
        if(any(node_attrs == "img/hoshi_shiro.gif")) {
            return("1")
        }
        return(node_attrs[[1]])
    }
    value <- xmlValue(node)
    if(any(grep("[YOSKM][0-9]{1,2}[we]", value))) {
        rank <- value
        num_rank <- 0
        num_rank <- num_rank + switch(substr(rank, 1, 1), "Y"=0, "O"=3, "S"=6, "K"=9, "M"=12)
        if(any(grep("[0-9]", substr(rank, 3, 3)))) {
            num_rank <- num_rank + as.integer(substr(rank, 2, 3))
            if(substr(rank, 4, 4) == "w") num_rank <- num_rank + 1
        } else {
            num_rank <- num_rank + as.integer(substr(rank, 2, 2))
            if(substr(rank, 3, 3) == "w") num_rank <- num_rank + 1
        }
        return(num_rank)
    }
    parsed_win_lose_record = sub("([0-9]+)-([0-9]+) \\([0-9]+-[0-9]+\\)", "\\1 \\2", value)
    if (parsed_win_lose_record != value) {
        return(parsed_win_lose_record)
    }
    return(value)
}

sumo_data_table <- readHTMLTable("http://sumodb.sumogames.de/Query_bout.aspx?show_form=0&year=1989.01-2000.01&m=on&rowcount=1&offset=0", header=c("Basho", "Day", "Rank 1", "Shikona 1", "Result 1", "Outcome Icon 1", "Kimarite", "Rank 2", "Shikona 2", "Result 2", "Outcome Icon 2"), skip.rows=c(1:2, 5:50), which=1, elFun=test_elFun)
sumo_data_table

#num_results = as.integer(unlist(strsplit(xmlValue(tree$children$html[['body']][['div']][['div']][['div']][['div']
url = "http://sumodb.sumogames.de/Query_bout.aspx?show_form=0&year=1989.01-2000.01&m=on&rowcount=1&offset=%d"
tree = htmlTreeParse(sprintf(url, 0))
num_results <- as.integer(strsplit(grep("[0-9]+ results found", unlist(tree$children$html[["body"]]), value=TRUE), " ")[[1]][[1]])

fetch_table <- function(offset) {
    return(readHTMLTable(sprintf(url, offset), skip.rows=c(1:2), which=1, elFun=test_elFun))


big_table_list <- apply(seq(from=0, to=num_results, by=1000), 1, fetch_table)

# Use sapply to create rank difference, bubble, and constant columns, as well as to duplicate needed data for rikishi
# Make columns:
# Basho 1 Day 1 Rank Difference 1 Shikona 1 Result 1 Kimarite 1 Basho 2 Day 2 Rank Difference 2 Shikona 2 Result 2 Kimarite 2 
# Make into 6 x 2*nrows(original) matrix
# Convert to dataframe?
# Carry out linear regression
