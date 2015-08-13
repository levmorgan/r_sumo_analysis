library("XML")

# Loop: fetch and merge sumo tables

test_elFun = function(node) {
    if(length(node) > 0 && xmlName(node[[1]]) == "img") {
        node_attrs <- xmlAttrs(node[[1]])
        if(any(node_attrs == "img/hoshi_kuro.gif") || any(node_attrs == "img/hoshi_fusenpai.gif")) {
            return("0")
        }
        if(any(node_attrs == "img/hoshi_shiro.gif") ||  any(node_attrs == "img/hoshi_fusensho.gif")) {
            return("1")
        }
        return(node_attrs[[1]])
    }
    value <- xmlValue(node)
    if(any(grep("[YOSKMJ][0-9]{1,2}[we]", value))) {
        rank <- value
        num_rank <- 0
        num_rank <- num_rank + switch(substr(rank, 1, 1), "Y"=0, "O"=3, "S"=6, "K"=8, "M"=10, "J"=42)
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

on_margin <- function(wins, day) {
    # Return whether a wrestler is in the running for a positive score (8 wins)
    # in the last 5 days of a tournament, but doesn't yet have them
    days.left <- 16 - as.integer(day)
    wins.needed = 8 - as.integer(wins)
    if(wins.needed > 0 && wins.needed <= days.left) {
        return(1)
    }
    return(0)

}

setup_table_for_regression = function(row) {
    tryCatch({
        rank.difference.1 <- as.integer(row[3]) - as.integer(row[9])
        #rank.difference.2 <- as.integer(row[9]) - as.integer(row[3])
        interaction <- paste(sort(c(row[4], row[10])), collapse=" ")
        wins.1 =  as.integer(sub("\\(?([0-9]+)[ \\-]([0-9]+)\\)?.*", "\\1", row[5]))
        wins.2 =  as.integer(sub("\\(?([0-9]+)[ \\-]([0-9]+)\\)?.*", "\\1", row[11]))
        # wins.1 <- as.integer(unlist(strsplit(row[5], " "))[1])
        # wins.2 <- as.integer(unlist(strsplit(row[9], " "))[1])
        bubble.1 <- on_margin(wins.1, row[2])
        bubble.2 <- on_margin(wins.2, row[2])
    }, warning = function(w) {
        print(sprintf("Got a warning %s", as.character(w)))
        print("While working on row:")
        print(row)
    })

    if(bubble.1 == bubble.2) {
        bubble.1 <- 0
        bubble.2 <- 0
    } else if (bubble.1 == 1) {
        bubble.2 <- -1
    } else if (bubble.2 == 1) {
        bubble.1 <- -1
    }

    # Compute bubble
    return(c(row[1], row[2], rank.difference.1, row[4], row[10], wins.1, row[6], row[7], bubble.1))
             #row[1], row[2], rank.difference.2, row[10], wins.2, row[8], row[7], bubble.2, interaction))
}

if(!file.exists("Sumo data 1989.01-2010.01 with 2 Shikona.Rda")) {
    if(!file.exists("Sumo data 1989.01-2010.01 with 2 Shikona raw.Rda")) {
        print("Couldn't find data files, downloading match data from SumoDB")
        # Fetch sumo data from sumodb
        ## Get the number of items to fetch
        url = "http://sumodb.sumogames.de/Query_bout.aspx?show_form=0&year=1989.01-2010.01&m=on&rowcount=5&offset=%d"
        tree = htmlTreeParse(sprintf(url, 0))
        num_results <- as.integer(strsplit(grep("[0-9]+ results found", unlist(tree$children$html[["body"]]), value=TRUE), " ")[[1]][[1]])

        fetch_table <- function(offset) {
            return(readHTMLTable(sprintf(url, offset), skip.rows=c(1), which=1, elFun=test_elFun, stringsAsFactors=FALSE))
        }

        ## Scrape each 1000 item page to a table, then merge the tables
        big_table_list <- Map(fetch_table, seq(from=0, to=num_results-1, by=1000))
        big_table <- Reduce(function(...) merge(..., all=T, sort=FALSE), big_table_list)
    } else {
        load("Sumo data 1989.01-2010.01 with 2 Shikona.Rda")
    }
    names(big_table) <- c("Basho", "Day", "Rank.1", "Shikona.1", "Result.1", "Outcome.1", "Kimarite", "Outcome.2", "Rank.2", "Shikona.2", "Result.2")

    # Reformat the table so we can perform our regressions
    formatted_table <- t(apply(big_table, 1, setup_table_for_regression))
    sumo.data <- data.frame("Basho"=formatted_table[,1], "Day"=formatted_table[,2], "Rank.Difference"=formatted_table[,3], 
                                 "Shikona.1"=formatted_table[,4], "Shikona.2"=formatted_table[,5], "Wins"=formatted_table[,6], "Match.Outcome"=formatted_table[,7], 
                                 "Kimarite"=formatted_table[,8], "Bubble"=formatted_table[,9])
} else {
    load("Sumo data 1989.01-2010.01 with 2 Shikona.Rda")
}
sumo.data$Rank.Difference <- as.integer(as.character(sumo.data$Rank.Difference))
sumo.glmdata <- sumo.data
sumo.lmdata <- sumo.data
sumo.lmdata$Match.Outcome <- as.integer(as.character(sumo.data$Match.Outcome))

# Create linear probability models, exactly as specified in (Duggan, Levitt 2002)
lm.1 <- lm(Match.Outcome ~ Bubble*Day, data=sumo.lmdata) 
lm.2 <- lm(Match.Outcome ~ Bubble*Day + Rank.Difference, data=sumo.lmdata) 
lm.3 <- lm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2, data=sumo.lmdata) 
lm.4 <- lm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2 + Rank.Difference, data=sumo.lmdata)
lm.5 <- lm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2 + Shikona.1*Shikona.2, data=sumo.lmdata)
lm.6 <- lm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2 + Shikona.1*Shikona.2 + Rank.Difference, data=sumo.lmdata)

# Linear probability models have a lot of problems, like not being bounded in the output variable.
# Let's try our regression using a logit model instead, since it matches the demands of this problem better,
glm.1 <- glm(Match.Outcome ~ Bubble*Day, data=sumo.glmdata, family="binomial") 
glm.2 <- glm(Match.Outcome ~ Bubble*Day + Rank.Difference, data=sumo.glmdata, family="binomial") 
glm.3 <- glm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2, data=sumo.glmdata, family="binomial") 
glm.4 <- glm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2 + Rank.Difference, data=sumo.glmdata, family="binomial")
glm.5 <- glm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2 + Shikona.1*Shikona.2, data=sumo.glmdata, family="binomial")
glm.6 <- glm(Match.Outcome ~ 0 + Bubble*Day + Shikona.1 + Shikona.2 + Shikona.1*Shikona.2 + Rank.Difference, data=sumo.glmdata, family="binomial")

# TEST per-cell processing
test.cellwise.processiong = function() {
    sumo_data_table <- readHTMLTable("http://sumodb.sumogames.de/Query_bout.aspx?show_form=0&year=1989.01-2000.01&m=on&rowcount=1&offset=0", header=c("Basho", "Day", "Rank.1", "Shikona.1", "Result.1", "Outcome Icon.1", "Kimarite", "Rank.2", "Shikona.2", "Result.2", "Outcome Icon.2"), skip.rows=c(1:2, 5:50), which=1, elFun=test_elFun, stringsAsFactors=FALSE)
    sumo_data_table
}
# END TEST

# TEST table processing
test.table.processing = function() {
    url = "http://sumodb.sumogames.de/Query_bout.aspx?show_form=0&year=1989.01-2000.01&m=on&rowcount=1&offset=%d"
    fetch_table <- function(offset) {
        print(offset)
        return(readHTMLTable(sprintf(url, offset), skip.rows=c(1), which=1, elFun=test_elFun, stringsAsFactors=TRUE))
    }
    big_table_list <- Map(fetch_table, seq(from=0, to=150-1, by=50))
    big_table <- Reduce(function(...) merge(..., all=T, sort=FALSE), big_table_list)
    names(big_table) <- c("Basho", "Day", "Rank.1", "Shikona.1", "Result.1", "Outcome.1", "Kimarite", "Outcome.2", "Rank.2", "Shikona.2", "Result.2")
    formatted_table <- sapply(big_table, setup_table_for_regression)
    formatted_table <- matrix(formatted_table, 2*nrow(big_table), 8)
}


# END TEST
