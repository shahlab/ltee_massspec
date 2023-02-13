This is the repository for the code associated with the paper "Linking genetic and phenotypic changes in the LTEE using metabolomics".
The raw mass spectrometry data is deposited at metabolomics workbench under the study ID ST002431.
The data required for running this code can be found in the `data_frames` folder in this repository. 
To begin, start by cloning this repo and following the instructions.
Each Rmd lists the packages and versions used at the bottom of 

## Preparing the data

The data is already prepared and is located at `data_frames/targeted_with_imps.csv`.
This is the complete dataset with imputations performed.
If you want to start from scratch, you can start at `code/data_prep/data_processing.Rmd`.
However, rerunning the imputations will not result in the same numbers as was used in the manuscript.

## Generating the figures

The figures can be made once the data is generated.
In general, there is no particular order in which one must run the code to make the figures, with the exception that the PCA results used in `/code/figures/data_comparisons.Rmd` are saved as an `Rdata` object and used in `/code/figures/pca_heatmaps.Rmd`.
Additionally, panel C in `/code/figures/data_comparisons.Rmd` requires the script at `code/analysis/randomizations_for_boxplot.R` to be run.
Other than that, the code can be run in any order.
Each figure should generate and save with no issues.

## Software versions
```
R version 4.2.2 Patched (2022-11-10 r83330)  
Platform: x86_64-pc-linux-gnu (64-bit)  
Running under: Ubuntu 18.04.6 LTS  

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/atlas/libblas.so.3.10.3  
LAPACK: /usr/lib/x86_64-linux-gnu/atlas/liblapack.so.3.10.3  

locale:  
[1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8   
[6] LC_MESSAGES=en_US.UTF-8    LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

attached base packages:  
[1] parallel  grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:  
[1] forcats_0.5.2         stringr_1.4.1         dplyr_1.0.10          purrr_0.3.4           readr_2.1.3           tidyr_1.2.1          
[7] tibble_3.1.8          tidyverse_1.3.2       sinib_1.0.0           scales_1.2.1          patchwork_1.1.2       mvtnorm_1.1-3        
[13] ggrepel_0.9.1         ggpubr_0.4.0          ggplot2_3.3.6         ggplotify_0.1.0       corrr_0.4.4           ComplexHeatmap_2.12.1
[19] circlize_0.4.15       broom_1.0.1          

loaded via a namespace (and not attached):
[1] matrixStats_0.62.0  fs_1.5.2            lubridate_1.8.0     doParallel_1.0.17   RColorBrewer_1.1-3  httr_1.4.4          tools_4.2.2        
[8] backports_1.4.1     utf8_1.2.2          R6_2.5.1            DBI_1.1.3           BiocGenerics_0.42.0 colorspace_2.0-3    GetoptLong_1.0.5   
[15] withr_2.5.0         tidyselect_1.1.2    gridExtra_2.3       compiler_4.2.2      rvest_1.0.3         cli_3.4.1           xml2_1.3.3         
[22] digest_0.6.29       yulab.utils_0.0.5   rmarkdown_2.16      pkgconfig_2.0.3     htmltools_0.5.3     dbplyr_2.2.1        fastmap_1.1.0      
[29] readxl_1.4.1        rlang_1.0.6         GlobalOptions_0.1.2 rstudioapi_0.14     shape_1.4.6         gridGraphics_0.5-1  generics_0.1.3     
[36] jsonlite_1.8.2      car_3.1-0           googlesheets4_1.0.1 magrittr_2.0.3      Rcpp_1.0.9          munsell_0.5.0       S4Vectors_0.34.0   
[43] fansi_1.0.3         abind_1.4-5         viridis_0.6.2       lifecycle_1.0.2     stringi_1.7.8       yaml_2.3.5          carData_3.0-5      
[50] crayon_1.5.2        haven_2.5.1         hms_1.1.2           knitr_1.40          pillar_1.8.1        rjson_0.2.21        ggsignif_0.6.3     
[57] codetools_0.2-18    stats4_4.2.2        reprex_2.0.2        glue_1.6.2          evaluate_0.16       modelr_0.1.9        png_0.1-7          
[64] vctrs_0.4.2         tzdb_0.3.0          foreach_1.5.2       cellranger_1.1.0    gtable_0.3.1        clue_0.3-61         assertthat_0.2.1   
[71] xfun_0.33           rstatix_0.7.0       googledrive_2.0.0   viridisLite_0.4.1   gargle_1.2.1        iterators_1.0.14    IRanges_2.30.1     
[78] cluster_2.1.4       ellipsis_0.3.2     
```