# dMUAdCOF

## Brief Description
Current adaptdcos figure 2 (or 3 I guess...)
This runs in an old repository/archive. The goal of this code is to
update it into the Modular Function Structure and create backup files on
TEBA so it can be accesses, edited, and re-run anytime. 
- dMUAdCOF is a master function that plots the dCOF effect previously seen in the AUTO-sorted data (previously fig 3).
- The entire STIM directory that has all AUTO sorted data on TEBA is scanned for days with brfs session. On days with brfs session, all files with the correct conditions established by conditionArray are analyzed.
- Only high-contrast stimuli (.8-1 Michelson contrast) are analyzed across all condition types.

## Goal Figures
- z-scored dMUA cond compare. "Fig3"
- raw dMUA cond compare. "Fig3"
- sub-functions are AUTOdiIDX.m and visIDX_fig3_fromAUTO:
   - AUTODdiIDX_JoVContrast or AUTOdiIDX_highContrast can be found in "Event-alignment fuctions." It takes all STIM_AUTO.mat inputs, finds relevant conditions, makes sure the contact is  tuned, and then saves results in a diIDX matrix which is stored locally on HDD D:\5 diIDX dir\. Note that all the STIM_AUTO.mat files are already photo-diode triggered and this function does not do any triggering.
   - viIDX_fig3_fromAUTO.m can be found in Visualization functions. It takes the SDFs from all of V1 in the IDX variable and averages them together. This can be done with raw dMUA inputs or z-scored inputs. Both are plotted in dMUAdCOF master fuction


## Directories
### Teba
- .ns6 dir                  = N/A
- KLS sorts                 = N/A
- Phy outputs of KLS sorts  = N/A
- STIM                      = 'T:\diSTIM - adaptdcos&CRF\STIM\'
- STIM_Data                 = 'T:\diSTIM - adaptdcos&CRF\STIM\' 
- IDX data                  = 'T:\Adaptdcos\dMUAdCOF' - diIDX_Auto_JoVContrast
- *Figure Outputs*          = T:\Adaptdcos\dMUAdCOF


### HDD
- .ns6 dir                  = N/A
- KLS sorts                 = N/A
- Phy outputs of KLS sorts  = N/A
- STIM                      = 'T:\diSTIM - adaptdcos&CRF\STIM\'
- STIM_Data                 = 'T:\diSTIM - adaptdcos&CRF\STIM\'
- diIDXdir                  = D:\5 diIDX dir
- *Figure Outputs*          = D:\6 Plot Dir\dMUAdCOF

   
## Dependencies
### Sub-functions
- **AUTOdiIDX** 
- **visIDX_fig3_fromAUTO**


### BMC_AdaptdcosPostProcessing update info
- 11/11/20
- 1.2.1 dMUAdCOF branch merged and released.
