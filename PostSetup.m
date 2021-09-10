function PostSetup(user)

% helper function 
% MAC, Feb 2020
global HOMEDIR NS6DIR AUTODIR SORTDIR ALIGNDIR IDXDIR STIMDIR SAVEDIR CODEDIR OUTDIR tasks 
 

switch user
    
    case {'BrockHome'}
        NS6DIR   = 'D:\brfs ns6 files\';
        CODEDIR  = 'C:\Users\Brock Carlson\Documents\GitHub\BMC_AdaptdcosFigures\adaptdcos\Master figure releases\1.4 - LaminarAnalysis';
        IDXDIR   = 'D:\5 diIDX dir';
        STIMDIR  = 'D:\STIM for CRF data';
        OUTDIR   = 'E:\6 Plot Dir\1.5 Gramm\outputs from 1.5 master code';
        
        tasks    = 'brfs';
        
        cd(CODEDIR)
       
    
    case {'BrockWork'}
        NS6DIR   = 'E:\brfs ns6 files\';
        CODEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\BMC_AdaptdcosFigures\adaptdcos\Master figure releases\1.4 - LaminarAnalysis';
        IDXDIR   = 'E:\5 diIDX dir';
        STIMDIR  = 'E:\STIM for CRF data';
        OUTDIR   = 'E:\6 Plot Dir\1.5 Gramm\outputs from 1.5 master code';
        
        tasks    = 'brfs';
        
        cd(CODEDIR)
       
              
    case {'BrockExUnitTest'}
        HOMEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\';
        NS6DIR   = 'C:\Users\Brock\Desktop\151221_E_eD\';
        AUTODIR  = 'C:\Users\Brock\Desktop\151221_E_eD\';
        ALIGNDIR = 'C:\Users\Brock\Desktop\151221_E_eD\';
        STIMDIR  = 'C:\Users\Brock\Desktop\151221_E_eD\';
        SORTDIR  =  'C:\Users\Brock\Desktop\151221_E_eD\KLSoutputs\';
        SAVEDIR  = 'C:\Users\Brock\Desktop\151221_E_eD\';
        CODEDIR  =  'C:\Users\Brock\Documents\MATLAB\GitHub\';
        OUTDIR   =  'C:\Users\Brock\Desktop\151221_E_eD\Plot Directory\';
        tasks    = 'brfs';
           
   
        
    case {'BrockHdMUA'}
        HOMEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\';
        NS6DIR   = 'T:\SANDBOX diSTIM Pipeline\NeurophysData\';
        AUTODIR  = 'T:\SANDBOX diSTIM Pipeline\AutoSort-ed\';
        SORTDIR  = 'T:\SANDBOX diSTIM Pipeline\KiloSort-ed\';
        ALIGNDIR = 'T:\SANDBOX diSTIM Pipeline\V1Limits\';
        STIMDIR  = 'T:\SANDBOX diSTIM Pipeline\STIM-HdMUA\';
        SAVEDIR  = 'C:\Users\Brock\Documents\MATLAB\Working IDX Dir\HdMUA_test\';

    
       
end


%  addpath(...
%             [HOMEDIR 'ephys-analysis'],...
%             [HOMEDIR 'ephys-analysis' filesep 'stim'],...
%             [HOMEDIR 'ephys-analysis' filesep 'stim' filesep 'NPMK'],...
%             [HOMEDIR 'ephys-analysis' filesep 'stim' filesep 'NPMK' filesep 'NSx Utilities'],...
%             [HOMEDIR 'ephys-analysis' filesep 'utils'],...
%             [HOMEDIR 'MLAnalysisOnline'],...
%             [HOMEDIR  'MLAnalysisOnline' filesep 'BHV Analysis'])
           
        
end
