function CODEDIR = PostSetup(user)

% helper function 
% MAC, Feb 2020
global HOMEDIR NS6DIR AUTODIR SORTDIR ALIGNDIR IDXDIR STIMDIR SAVEDIR CODEDIR OUTDIR tasks LFPDIR
 

switch user
    
    case {'BrockWork'}
        NS6DIR   = 'T:\Brock - backups\Backup - WD harddrive - 220311\1 brfs ns6 files\';
        CODEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\laminarLabelingCollab\MasterScripts';
        IDXDIR   = 'T:\Brock - backups\Backup - WD harddrive - 220311\5 diIDX dir\';
        STIMDIR  = 'T:\Brock - backups\Backup - WD harddrive - 220311\2 all LFP STIM\';
        OUTDIR   = 'C:\Users\Brock\Documents\MATLAB\formattedDataOutputs\JASP output for brfs\';
        LFPDIR   = [];

        tasks    = 'brfs';
        
        cd(CODEDIR)



    case {'BrockHome'}
        NS6DIR   = 'D:\brfs ns6 files\';
        CODEDIR  = 'C:\Users\Brock Carlson\Documents\GitHub\BMC_AdaptdcosFigures\adaptdcos\Master figure releases\1.5 - Gramm';
        IDXDIR   = 'D:\5 diIDX dir';
        STIMDIR  = 'E:\2 all LFP STIM';
        OUTDIR   = 'E:\6 Plot Dir\1.5 Gramm\outputs from 1.5 master code';
        
        tasks    = 'brfs';
        
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
