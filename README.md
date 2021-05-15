# # BMC_AdaptdcosFigures

This is "release issue" formatted code. 
The idea is that the process to produce a figure for every step along a given paper's progression is stored here.
When a goal for a figure is made, the following steps are executed:
1. the "master branch" is branched and named for the goal figure.
1. The code is tested and figure outputs are shown to PI/Lab.
1. The data directories and repositories are then stored in the "Docs" page for each figures' master fucntion.
1. The docs page contains required data input directories, pre-processing repositories, and workflow for fast recreation of the figure in the future. The Docs page is named for each release update (i.e. 1.1, 1.2, 1.3, 1.4, etc...)
1. The branch is then merged with a pull request back into master and deleted.
1. A "release" of master **must** be issued at this point.


## Description: 
The adaptdcos project is looking at dioptic and dichoptic stimuli under varying history conditions. The included levels of analysis are currently 
- dMUA from AUTO-sorted data
- KLS on a few example sessions.

We are interested in probing data types, history, and contrast across a complex stimuli matrix to descriminate the origns of bincoular fusion.


## Table of Contents:
### Issues released
- 1.1 Example Units A
  - 11/10/20
  - looked at units from 151221_E, 160108_E, 160211_I, & 161005_E.
- 1.2 dMUA-dCOF
  - 11/10/20
  - current fig2. Code updated into "release" framework.
- 1.3 FullTimeClassicBRFS
  - 1/1/2021 - 5/15/2021
  - Spring 2021 semester
  - Plotted all figures 1-5 for manuscript draft in the master function
- 1.4 LaminarAnalysis
  - 5/15/2021 - present
  - 2021 Summer
  - dII by layers and Jake's adaptation analysis.

## Usage: 
Please access the accompanying Docs FILE_setup page for re-producing any set of figures. These contain the required direcotires and code repos to be accessed in the case of returning to a figure at a later date.
### For KiloSort
1. Batch – download ns6 files
1. Batch – process KLS sorts with correct kiloconfig files
1. Download a few Phy files to SSD
1. Analyze in phy
1. Export to external drive
   1. repeat 3-5 until entire directory is done.
1. Create STIM file (may already be done) from .bhv files and event codes
   1. Find/Load stim file if already created
1. run "master function" under PostProcessing (This repo) to viz. data.
   1. Run diNeuralDat.m – creates SDFs and RESP vectors
   1. Run continuousDatConditionsSelect.m  gets condition specific avg SDFs
   1. Crop continuous data
   1. Plot 
      1. Raster
      1. SDF.

### For all other file types (dMUA, LFP, CSD, etc.)
1. Create STIM file (may already be done) from .bhv files and event codes
   1. Find/Load stim file if already created
1. Create/find STIM_MUA.mat/STIM_LFP.mat etc.
   1. the data file contains the STIM and BHV info along with SDF variables.
1. run "master function" under PostProcessing (This repo) to viz. data.
   1. Run continuousDatConditionsSelect.m  gets condition specific avg SDFs
   1. Crop continuous data
   1. Plot 
      1. SDF.
      

## Contributing authors
Code within this direcotry is custome designed by Brock M. Carlson within the Maier Lab.
Production of this respository would not be possible wihout the guidance of **Alex Maier, PhD.**
Special influence, example code, and individual instruction was received from current and former senior lab members:
- Michele A. Cox
- Kacie Dougherty
- Jacob A Westerberg

Special thank you to other Maier Lab members for their influence and advice
- Loïc Daumail
- Blake Mitchell
