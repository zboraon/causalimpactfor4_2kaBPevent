# causalimpactfor4_2kaBPevent
The functions and data used for the manuscript for the *"A Bayesian test for the 4.2 ka BP abrupt climatic change event in southeast Europe and southwest Asia using structural time series analysis of paleoclimate data"*

See: [https://link.springer.com/article/10.1007/s10584-021-03010-6]([https://pages.github.com/](https://link.springer.com/article/10.1007/s10584-021-03010-6))


For cross-validation please run the following command in your R console. At the end you will end up with two .csv files for each response variable, one is the whole cross-validation results and the other one is the minimum values of cross-validation results. However, notice that the following command runs cross_validation_4_2ka_bp which calls the loop_4_2ka_BP.R function and make 20,000 MCMC runs for 10 different values for each response variable, i.e. it takes time.

```{r, eval = F}
library(RCurl)
script <- getURL("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/cross_validation_4_2ka_bp.R", ssl.verifypeer = FALSE)
eval(parse(text = script))
```
After you get the cross-validation results, you can run the following command to get the impact results. While this one is faster than the previous run it takes amount in your storage. However, you can turn off the line where it saves the whole results to your disk.

```{r, eval = F}
library(RCurl)
script <- getURL("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/path_causalimpact_after_cv.R", ssl.verifypeer = FALSE)
eval(parse(text = script))
```
