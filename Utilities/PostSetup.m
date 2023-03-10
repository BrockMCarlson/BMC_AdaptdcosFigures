function CODEDIR = PostSetup(user)

% helper function 
% MAC, Feb 2020
global  LFPDIR RIGDIR CODEDIR IDXDIR STIMDIR OUTDIR
 

switch user
 
    case {'Neuropixel'}
        CODEDIR  = 'C:\Users\neuropixel\Documents\GitHub\BMC_AdaptdcosFigures\Master figure releases\1.9 - iScience Submission';
        IDXDIR   = 'C:\Users\neuropixel\Box\BRFS to iScience\FormattedDataOutputs\';
%         STIMDIR  = 'C:\Users\Brock\Documents\MATLAB\brfs_STIM_220827\';
        OUTDIR   = 'C:\Users\neuropixel\Box\BRFS to iScience\plot outputs for BRFS to iScience\';

        
        cd(CODEDIR)

    case {'BrockWork'}
        CODEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\BMC_AdaptdcosFigures\Master figure releases\1.9 - iScience Submission';
        IDXDIR   = 'C:\Users\Brock\Box\BRFS to iScience\FormattedDataOutputs\';
        STIMDIR  = 'C:\Users\Brock\Documents\MATLAB\brfs_STIM_220827\';
        OUTDIR   = 'C:\Users\Brock\Box\BRFS to iScience\plot outputs for BRFS to iScience\';

        
        cd(CODEDIR)

    case {'BrockHome'}
        RIGDIR   = 'S:\all BRFS\';
        CODEDIR  = 'C:\Users\Brock Carlson\Documents\GitHub\BMC_AdaptdcosFigures\adaptdcos\Master figure releases\1.9 - iScience Submission';
        IDXDIR   = 'S:\FormattedDataOutputs';
        STIMDIR  = 'S:\brfs_STIM_220827\';
        OUTDIR   = 'S:\PlotOutputs';
        cd(CODEDIR)
        
    case {'BrockHome_LLC'}
        CODEDIR  = 'C:\Users\Brock Carlson\Documents\GitHub\laminarLabelingCollab\MasterScripts';
        IDXDIR   = 'D:\5 diIDX dir\';
        STIMDIR  = 'D:\2 all LFP STIM\';
        LFPDIR   = 'D:\6. laminarLabelingLFPs\';
        cd(CODEDIR)
  
              
    case {'BrockExUnitTest'}
        CODEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\BMC_AdaptdcosFigures\adaptdcos\Master figure releases\1.6 - JakesAdditions';
        IDXDIR   = 'E:\5 diIDX dir';
        STIMDIR  = 'E:\SANDBOX\STIM';
        OUTDIR   = 'E:\6 Plot Dir\SANDBOX_OUTDIR';
        
        tasks    = 'brfs';
        
        cd(CODEDIR)
   
        
    case {'BrockHdMUA'}
        HOMEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\';
        NS6DIR   = 'T:\SANDBOX diSTIM Pipeline\NeurophysData\';
        AUTODIR  = 'T:\SANDBOX diSTIM Pipeline\AutoSort-ed\';
        SORTDIR  = 'T:\SANDBOX diSTIM Pipeline\KiloSort-ed\';
        ALIGNDIR = 'T:\SANDBOX diSTIM Pipeline\V1Limits\';
        STIMDIR  = 'T:\SANDBOX diSTIM Pipeline\STIM-HdMUA\';
        SAVEDIR  = 'C:\Users\Brock\Documents\MATLAB\Working IDX Dir\HdMUA_test\';

    
       
end



           
        
end
