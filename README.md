# BMC_AdaptdcosFigures
This is the GitHub repository for the following manuscript in preparation:

Does V1 response suppression initiate binocular rivalry?				
Brock M. Carlson, Blake A. Mitchell1, Kacie Dougherty, Jacob A. Westerberg, Michele A. Cox, & Alexander Maier
- Corresponding author: alex.maier@vanderbilt.edu
- Repository manager: brock.m.carlson@vanderbilt.edu

## HIGHLIGHTS
-	The role of primary visual cortex (V1) for binocular rivalry (BR) is unclear.
-	V1 population spiking is reduced at the onset of BR, providing a potential trigger.
-	However, this broad spiking suppression in does not occur for a variant of BR.
-	The BR variant reduces subpopulation responses, a potential alternate trigger. 

## SUMMARY 
In binocular rivalry (BR) only one’s view is perceived. The neural underpinnings of BR are debated. Recent studies suggest that primary visual cortex (V1) initiates BR. One such trigger might be response-suppression across most V1 neurons at the onset of BR. Here we utilize a variant of BR called binocular rivalry flash suppression (BRFS) to test this hypothesis. BRFS is identical to binocular rivalry, except stimuli are shown with a ~1s delay. If V1 response suppression was required to initiate BR, it should occur during BRFS as well. To test this hypothesis, we compared V1 spiking in two macaques observing BRFS. We found that BRFS resulted in response-facilitation rather than response-suppression across V1 neurons. However, BRFS still reduces responses in a subset of V1 neurons due to the adaptive effects of asynchronous stimulus presentation. We argue that this selective response suppression could serve as an alternate initiator of BR. 

# USING THIS REPOSITORY
This repository is written in MATLAB. The user interface is Controller_iScienceSubmission.mlx, which is a MATLAB Live Script. 
The filtered and event-locked data have been published in an open-science directory on Zenodo.
You can download the data at: https://doi.org/10.5281/zenodo.7949494
### Carlson, Brock, M., Mitchell, Blake, A., Kacie Dougherty, Westerberg, Jacob, A., & Maier, Alexander. (2023). Does V1 response suppression initiate binocular rivalry? Iscience. https://doi.org/10.5281/zenodo.7949494

## Dependencies
This script is dependent on Gramm which can be found at https://github.com/piermorel/gramm

## Controller
The controlling interface for this repository is the MATLAB Live Script Controller_iScienceSubmission.mlx. 
Please follow instructions in this notebook to recreate the figures for our manuscript in revision.
This notebook performs the following tasks:
1. Each muti-unit in the event-locked data has its tuning preferences evaluated (for occularity and orientation).
2. From the perspective of each unit's tuning preference for doiminant eye (DE) and preferred stimulus (PS), trial-wise data are sorted into relevant categorical events. The output of this stage is the index variable: IDX.
3. Aggregate data are plotted using Gramm.
4. .CSV outputs are formatted for JASP and saved to the rootdirectory.

## Expected outputs to ROOTDIR:
You will have to create a base directory called ROOTDIR to download the Zenodo data to. These other outputs will be generated and saved to this directory.
- **carlsonEtAl_iScienceFigs_allTunedUnits.mat** is a MATLAB data file that contains the IDX and ERR variable. IDX contains all 91 tuned multi-units used in subsequent analyses. Note that a copy of this variable is available in the Zenodo directory for any desired comparison.
- Gramm generates all figures used in the manuscript and saves outputs to the ROOTDIR as .svgs and .pngs. The .svg files are used to create final figure outputs with Adobe Illustrator.
- **JASP_transient.csv** and **JASP_sustained.csv** are outputs for repeated measures ANOVA analysis using JASP. JASP is a statistical package: JASP Team (2023). JASP (Version 0.17.2)[Computer software].
https://jasp-stats.org/

----
Thank you for your interest in our project! Please do not hesitate to reach out to brock.m.carlson@vanderbilt.edu with any questions or comments.
