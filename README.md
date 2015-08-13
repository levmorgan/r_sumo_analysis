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

# Results: #
## Excess Win Percentages For Wrestlers On The Margin By Day Of The Match ##
## LPM ##
|On the Margin On:   				| (1)			| (2)           | (3)			| (4)           |
|-----------------------------------|---------------|---------------|---------------|---------------|
|Day 15              				|.344 (.035)	|.282 (.036)    |.192 (.035)	|.189 (.035)    |
|Day 14              				|.317 (.030)	|.266 (.033)    |.174 (.032)	|.172 (.032)    |
|Day 13              				|.292 (.033)	|.248 (.033)    |.158 (.032)	|.158 (.032)    |
|Day 12              				|.265 (.033)	|.229 (.033)    |.151 (.032)	|.150 (.032)    |
|Day 11              				|.173 (.034)	|.144 (.032)    |.088 (.032)	|.087 (.032)    |
|Rank Difference     				|--				|-.011 (.003)   |--				|-.002 (.003)   |
|Constant            				|.5			    |.5             |--			    |--             |
|Wrestler & Opponent Fixed Effects   |No				|No             |Yes			|Yes            |
|Wrestler-Opponent Interactions      |No				|No             |No				|No             |

## Logit ##
|On the Margin On:   				| (1)			| (2)           | (3)			| (4)           |
|-----------------------------------|---------------|---------------|---------------|---------------|
|Day 15              				|1.58 (.017)	|1.36 (.017)	|1.05 (.017)	|1.04 (.018)	|
|Day 14              				|1.48 (.016)	|1.30 (.016)	|.981 (.017)	|.976 (.017)	|
|Day 13              				|1.38 (.016)	|1.22 (.016)	|.919 (.016)	|.915 (.016)	|
|Day 12              				|1.27 (.016)	|1.14 (.016)	|.884 (.016)	|.887 (.016)	|
|Day 11              				|.889 (.016)	|.779 (.016)	|.593 (.017)	|.590 (.017)	|
|Rank Difference     				|--				|-.459 (.003)   |--				|-.008 (.001)   |
|Constant            				|0.0		    |0.0            |--			    |--             |
|Wrestler & Opponent Fixed Effects   |No				|No             |Yes			|Yes            |
|Wrestler-Opponent Interactions      |No				|No             |No				|No             |

Figures for models 5 and 6 are omitted, as software limitations prevented them from being run. 

# Conclusions #
The results of the analysis generally matched those of Duncan and Levitt. In all cases, wrestlers 
on the bubble had statistically significant increases in their odds of winning their matches 
in the last four days of the tournament. Unlike in Duncan and Levitt's analysis, the increase in 
probability of winning for wrestlers on the margin increases as fixed and interaction effects for 
wrestlers are added to the model, but in this analysis they decreased. Though all increases are still 
statistically significant (p < 0.01), this could indicate that the correlation is not as strong in this 
dataset as it was in Duncan and Levitt's.
