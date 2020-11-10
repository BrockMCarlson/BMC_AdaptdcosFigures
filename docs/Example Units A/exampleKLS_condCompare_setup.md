# exampleKLS_condCompare_setup.md

## Brief Description
- taken from EyeOriPref
- plots rasters based on the conditions pulled out in "makeConditionArray.m
- changes in the condition array led to two different figure outputs

## Goal Figures
- each session (brfs001 or brfs002) gets...
   - raster (all trials)
   - SDF (trl-avg)
- monoc eye and ori examined. 
Notes: each brfs session was only given two tilts as inputs.

## Directories
### Teba
- .ns6 dir                  = T:\diSTIM - adaptdcos&CRF\Neurophys Data.
    - files transfered with GitHub\BMC_KiloSortUtils\bmc_transferFiles.m
- KLS sorts                 = T:\Adaptdcos\Example Units A\2 brfs KLS sorts - setting4
- Phy outputs of KLS sorts  = T:\Adaptdcos\Example Units A\3 brfs Phy outputs of KLS sorts
- STIM                      = T:\Adaptdcos\Example Units A\4 stimdir for KLS ex units
- STIM_Data                 = T:\Adaptdcos\Example Units A\4 stimdir for KLS ex units
- *Figure Outputs*          = two outputs - see below
   - T:\Adaptdcos\Example Units A\figure Outputs\CC_option1_holdDE-PS
   - T:\Adaptdcos\Example Units A\figure Outputs\CC_option2_flipIC-DE-NS

### HDD
- .ns6 dir                  = D:\1 brfs ns6 files
- KLS sorts                 = D:\2 brfs KLS sorts - setting4
- Phy outputs of KLS sorts  = D:\3 brfs Phy outputs of KLS sorts
- STIM                      = D:\4 stimdir for KLS ex units
- STIM_Data                 = D:\4 stimdir for KLS ex units
- *Figure Outputs*          = two outputs - see below
   - C:\Users\Brock\Documents\MATLAB\Working IDX Dir\KLSsandboxTest\CC_option1_holdDE-PS
   - C:\Users\Brock\Documents\MATLAB\Working IDX Dir\KLSsandboxTest\CC_option2_flipIC-DE-NS

## Dependencies
### ephys-analysis
- 11/10/20
- branch = imporPhyExUnits

### BMC_KiloSortUtils
- 11/10/20
- branch - ModularFunction Structure

### BMC_AdaptdcosPostProcessing
- 11/10/20
- branch - ModularFunctionStructure (same name as KiloSortUtils)
