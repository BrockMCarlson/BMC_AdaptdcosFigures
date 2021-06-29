% Test monocular trials
%% Initial settings
    clear
    close all
    PostSetup('BrockWork')
    flag_SaveFigs = false;

% load session data
    penetration = '151221_E_eD_LFP.mat';
    sdfwin  = [-0.150  .5];

% Assign preferences
    X.DE  = 2;
    X.NDE = 3;
    X.PS  = 0;
    X.NS  = 90;
    IDX = singleSessionIDX(penetration,sdfwin,X);
    
% Get monocular SDF
NonDomEyeMonocularSDF = IDX.allV1(1).SDF_crop{2,1};
DominantEyeMonocSDF = IDX.allV1(1).SDF_crop{3,1};

if sum(isnan(NonDomEyeMonocularSDF),'all')
    error('NaNs')
end
if sum(isnan(DominantEyeMonocSDF),'all')
    error('NaNs')
end