# Sumo Match Fixing in R #

## Introduction ##
In Duggan and Levitt's 2002 paper "Winning Isn’t Everything: Corruption in Sumo Wrestling", 
they carried out an analysis that showed evidence of widespread match fixing in sumo wrestling. 
Their results, which were included in the bestselling book Freakonomics, were ultimately 
validated by Japan's premier sumo authoiry, the NSK. In 2011 they cancelled a tournament and 
expelled a large number of wrestlers due to exactly the kind of match fixing described 
by Duggan and Levitt.

# Methods #
This project expands Duncan and Levitt's analysis as shown in Table 1 of their paper. 
The table "Excess Win Percentages For Wrestlers On The Margin For Achieving An Eighth 
Win, By Day Of The Match", lays out six models with differing parameters for analyzing 
the problem. The paper's original method is using linear probability models. This 
approach, using OLS on a binary output variable, has a number of problems and has 
largely fallen out of favor. Because of this, this project also fits a binomial logistic 
model for each linear probability model described in the paper.

Also, the original paper examined data from January 1989 to January 2000. 
This project adds an additional ten years of data, from 1989 to 2010.
