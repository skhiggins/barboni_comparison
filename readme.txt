# Replication instructions for the Barboni (2021) comparison figure

## Introduction
This document explains how to replicate the comparison figure used to compare the results on Barboni, et. al. (2021) with similar papers.

## Data 

The data sets used by this package were obtained from the puclicly replication codes of the papers used in the comparison figure.
Microdata from the replication files from other studies is used to compare the effect size in the Barboni, et. al. (2021) study to those of other studies.

The `data/` folder contains the following subfolders; the subsections below describe the source for the data that go into each subfolder.

  - `angelucci15`
  - `augsburg15`
  - `banerjee15`
  - `crepon15`
  
Specifically, the following replication data sets from the following studies are used:
  - `data/angelucci15/analysis_data_AEJ_pub.dta` is from the replication package for Angelucci, Karlan, and Zinman (2015) available here: https://www.openicpsr.org/openicpsr/project/116334/version/V1/view
  - `data/augsburg15/Baseline` and `data/augsburg15/Followup` subfolders contain data from the replication package for Augsburg, De Haas, Harmgart, and Meghir (2015) available here: https://www.openicpsr.org/openicpsr/project/113588/version/V1/view
  - `data/augsburg15/indicator-reinterviewed.dta` is from the replication package for Augsburg, De Haas, Harmgart, and Meghir (2015) available here: https://www.openicpsr.org/openicpsr/project/113588/version/V1/view
  - `data/augsburg15/incentive.given.dta` is from the replication package for Augsburg, De Haas, Harmgart, and Meghir (2015) available here: https://www.openicpsr.org/openicpsr/project/113588/version/V1/view
  - `data/banerjee15/2013-0533_data_endlines1and2.dta` is from the replication package for Banerjee, Duflo, Glennerster, and Kinnan (2015) available here: https://www.openicpsr.org/openicpsr/project/113599/version/V1/view
  - `data/crepon15/Output/endline_baseline_outcomes.dta` is created from the replication package for Crépon, Devoto, Duflo, and Parienté (2015) available here: https://www.openicpsr.org/openicpsr/project/116333/version/V1/view

In the mentioned subfolders inside the `data/` folder, there are other dofiles that belong to replication packages. They are there to give a more complete version of the replication packages.

For other studies included in our comparison, we used the point estimates and standard errors from the paper; see `scripts/barboni_comparison_dataprep.do` for more detail.

The file `data/barboni_comparison_metadata.xlsx` includes metadata about the studies included in the comparison figure. It is included with the replication data.

## Computational requirements
Most of the code was run on a computer with 8GB of RAM.

### Software requirements
The following software programs and packages are required.

#### Stata 14.0
Earlier versions of Stata (13 or newer) should work as well but have not been tested. 
The Stata code was run using 4-core Stata-MP 14.0.
All user-written .ado files required for replication are included in the `scripts/programs/` folder, so they do not need to be separately installed to run the replication package. They include:
- .ado files we've written
  - `time`
- .ado files written by others
  - `svmat2` (Nicholas J. Cox) and the .ado files needed for it to function.

#### R 3.6.3
The following list includes the R packages used and the version used; all of these packages and their dependencies are listed in the `renv.lock` file and can be installed using the `renv` package (installation instructions below).
  - `tidyverse` (1.3.0)
  - `magrittr` (1.5)
  - `here` (0.1)
  - `metafor` (3.0-2)
  - `renv` (0.12.0)

## Folder structure

After downloading the replication code and data, unzip it into a folder on your computer. After unzipping, the project root directory containing the folders described below should be thought of as the `main` folder when editing the `00_run.do` script to run on another machine. The folders inside of the zipped replication file should be placed in a folder that you will denote as `global main` in `00_run.do`. These folders are:

  - `data` and its subfolders are for raw data.
  - `figures` is the folder to which the comparison figure produced by the scripts will be written.
  - `logs` is the folder in which log files will be written.
  - `papers` is the folder that contains all the papers used for comparison in a .pdf format.
  - `proc` is the folder in which processed data sets will be saved.
  - `renv` contains the information needed to install all needed R packages and dependencies.
  - `scripts` contains the replication codes and the files that produce the comparison figure.
  - `programs` subfolder in the `scripts` folder contains the `.ado` files required to run our Stata scripts.
  
### Additional files
The project root directory contains the following files:
  - `.here` is included to enable R's `here::here()` function to work with relative file paths.
  - `.Rprofile` contains information to install all needed R packages and dependencies.
  - `README.md` is a markdown README file for the replication package.
  - `README.txt` is identical to `README.md` but included for those unsure how to open an `.md` file.
  - `renv.lock` contains information to install all needed R packages and dependencies.

## Instructions

### Set up
All the needed Stata packages (.ado files) are included in the `programs/` folder and do not need to be installed. The list of needed R packages, including their versions and dependencies, are included in `renv.lock`, `.Rprofile`, and the `renv/` folder, and can be installed by opening R from the project's root directory (or, equivalently, opening R and setting the working directory as the project's root directory), then running:
```r 
renv::restore()
```

### Scripts
- To create the comparison figure, first run `scripts/barboni_comparison_dataprep.do`.
- Details on the `scripts/barboni_comparison_dataprep.do` file:
	- Change the directory in line 17 of the do file. 
	- It contains locals. Thus, it is not recommended to be run in parts.
	- It also contains parts of the replication scripts from other papers, but has some modifications. The main one is that for some papers, it creates a new variable that measures total income. Do not modify those parts of the code.
- Once the `scripts/barboni_comparison_dataprep.do` do file has been run, run the `barboni_comparison_graph.R` script.
- The product of the R script is a graph saved both in a .eps file and a .jpg file.

## References

Angelucci, Manuela, Dean Karlan, and Jonathan Zinman. 2015. "Microcredit Impacts: Evidence from a Randomized Microcredit Program Placement Experiment by Compartamos Banco." _American Economic Journal_: Applied Economics_, 7 (1): 151-82.

Augsburg, Britta, Ralph De Haas, Heike Harmgart, and Costas Meghir. 2015. "The Impacts of Microcredit: Evidence from Bosnia and Herzegovina." _American Economic Journal: Applied Economics_, 7 (1): 183-203.

Barboni, Giorgia, Erica Field, and Rohini Pande. 2021. Rural Banks Can Reduce Poverty: Experimental Evidence from 870 Indian Villages. Working paper.

Banerjee, Abhijit, Esther Duflo, Rachel Glennerster, and Cynthia Kinnan. 2015. "The Miracle of Microfinance? Evidence from a Randomized Evaluation." _American Economic Journal: Applied Economics_, 7 (1): 22-53.

Breza, Emily, and Cynthia Kinnan. 2021. "Measuring the Equilibrium Impacts of Credit: Evidence from the Indian Microfinance Crisis." _The Quarterly Journal of Economics_: Oxford University Press, vol. 136(3): pages 1447-1497.

Bruhn, M., and Love, I. 2014. "The Real Impact of Improved Access to Finance: Evidence from Mexico." _Journal of Finance_, 69: 1347-1376.

Callen, Michael, Suresh de Mel, Craig McIntosh, and Christopher Woodruff. 2019. "What Are the Headwaters of Formal Savings? Experimental Evidence from Sri Lanka." _Review of Economic Studies_: Oxford University Press, vol. 86(6): 2491-2529.

Crépon, Bruno, Florencia Devoto, Esther Duflo, and William Parienté. 2015. "Estimating the Impact of Microcredit on Those Who Take It Up: Evidence from a Randomized Experiment in Morocco." _American Economic Journal: Applied Economics_, 7 (1): 123-50.

Stein, Luke, Constantine Yannelis. 2020. "Financial Inclusion, Human Capital, and Wealth Accumulation: Evidence from the Freedman’s Savings Bank." _The Review of Financial Studies_, Volume 33, Issue 11: 5333–5377.

