function setup(user)

% helper function 
% MAC, Feb 2020
global HOMEDIR RIGDIR AUTODIR SORTDIR ALIGNDIR STIMDIR SAVEDIR CODEDIR
 

switch user
              
    case {'brock'}
        HOMEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\';
        RIGDIR   = 'C:\Users\Brock\Desktop\151221_E_eD\';
        AUTODIR  = 'C:\Users\Brock\Desktop\151221_E_eD\';
        SORTDIR =  'C:\Users\Brock\Desktop\151221_E_eD\';
        ALIGNDIR = 'C:\Users\Brock\Desktop\151221_E_eD\';
        STIMDIR  = 'C:\Users\Brock\Desktop\151221_E_eD\';
        SAVEDIR  = 'C:\Users\Brock\Desktop\151221_E_eD\';
        CODEDIR =  'C:\Users\Brock\Documents\MATLAB\GitHub\PostProcessing';
           
   
        
    case {'brockHdMUA'}
        HOMEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\';
        RIGDIR   = 'T:\SANDBOX diSTIM Pipeline\NeurophysData\';
        AUTODIR  = 'T:\SANDBOX diSTIM Pipeline\AutoSort-ed\';
        SORTDIR  = 'T:\SANDBOX diSTIM Pipeline\KiloSort-ed\';
        ALIGNDIR = 'T:\SANDBOX diSTIM Pipeline\V1Limits\';
        STIMDIR  = 'T:\SANDBOX diSTIM Pipeline\STIM-HdMUA\';
        SAVEDIR  = 'C:\Users\Brock\Documents\MATLAB\Working IDX Dir\HdMUA_test\';

    
       
end


 addpath(...
            [HOMEDIR 'ephys-analysis'],...
            [HOMEDIR 'ephys-analysis' filesep 'stim'],...
            [HOMEDIR 'ephys-analysis' filesep 'stim' filesep 'NPMK'],...
            [HOMEDIR 'ephys-analysis' filesep 'stim' filesep 'NPMK' filesep 'NSx Utilities'],...
            [HOMEDIR 'ephys-analysis' filesep 'utils'],...
            [HOMEDIR 'MLAnalysisOnline'],...
            [HOMEDIR  'MLAnalysisOnline' filesep 'BHV Analysis'])
           
        
end
