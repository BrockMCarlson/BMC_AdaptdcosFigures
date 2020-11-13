# dMUA_visAllConds

## Brief Description
- Taken from, diIDX_AUTO_JoVContrast.mat found in D:\5 diIDX dir\ and plot 
all the conditions for each individual contact found with significant
responses within V1,

- Manually input the day to use. I will use 160108 first becuase of the
example KLS units that can go with this... However, I should also look at 161005.

- The bulk of this code will be in setting up a new visualization function
that, for each "unit" (Multi-unit in this case" plots the whole condition
matrix. I estimate four figures will be needed. They are as follows:



## Goal Figures
1. fig1 - Monoc 2x2 (perhaps I already have a vis funciton for this?)
1. fig2 - All simultaneous conditions. binocular and dichoptic. Done at JoV
% contrast to hopefully see dCOS
1. fig3 - binocular adapted conditions -- all of these are the same stim in
each eye, but with varying history and PS vs NS
1. fig4 - dichoptic adapted conditions - BRFS with each eye and ori. All
1. options are avaialbe. 
    1. Note - if you don't see a clean result in figure 4 make sure you
    check 161005
1. Figure code
    1. Monoc = visIDX_Monoc_fromAUTO(sdf,info);
    1. Simult = visIDX_Simult_fromAUTO(sdf,info);
    1. Csoa = visIDX_Csoa_fromAUTO(sdf,info);
    1. ICsoa = visIDX_ICsoa_fromAUTO(sdf,info);

## Directories
### Teba
- .ns6 dir                  = N/A
- KLS sorts                 = N/A
- Phy outputs of KLS sorts  = N/A
- STIM                      = 'T:\diSTIM - adaptdcos&CRF\STIM\'
- STIM_Data                 = 'T:\diSTIM - adaptdcos&CRF\STIM\'
- *Figure Outputs*          = T:\Adaptdcos\dMUAdCOF\160108 all contacts


### HDD
- .ns6 dir                  = N/A
- KLS sorts                 = N/A
- Phy outputs of KLS sorts  = N/A
- STIM                      = 'T:\diSTIM - adaptdcos&CRF\STIM\'
- STIM_Data                 = 'T:\diSTIM - adaptdcos&CRF\STIM\'
- diIDXdir                  = D:\5 diIDX dir
- *Figure Outputs*          = D:\6 Plot Dir\dMUAdCOF

   
## Dependencies
### diIDX needed
load('diIDX_AUTO_160108')

### Sub-functions
- **AUTOdiIDX_160108allCond** --> note the new 16 condition structure
1. Figure code
    1. Monoc = visIDX_Monoc_fromAUTO(sdf,info);
    1. Simult = visIDX_Simult_fromAUTO(sdf,info);
    1. Csoa = visIDX_Csoa_fromAUTO(sdf,info);
    1. ICsoa = visIDX_ICsoa_fromAUTO(sdf,info);


### BMC_AdaptdcosPostProcessing update info
- 11/13/20
- 1.2.1 dMUAdCOF branch merged and released.
