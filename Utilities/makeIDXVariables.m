%% Make IDX Variables

% dMUAdCOF
% Current adaptdcos figure 2 (or 3 I guess...)
% This runs in an old repository/archive. The goal of this code is to
% update it into the Modular Function Structure and create backup files on
% TEBA so it can be accesses, edited, and re-run anytime. 


% exampleKLS_condCompare
% taken from... EyeOriPref


clear
close all


cd('D:\5 diIDX dir')
       cd('D:\5 diIDX dir')
            if ~exist('D:\5 diIDX dir\diIDX_AUTO_JoVContrast.mat','file')
                AUTOdiIDX_JoVContrast
            end
            if ~exist('D:\5 diIDX dir\diIDX_AUTO_highContrast.mat','file')
                AUTOdiIDX_highContrast
            end
            if ~exist('D:\5 diIDX dir\diIDX_AUTO_MediumMediumContrast.mat','file')
                AUTOdiIDX_MediumMediumContrast
            end








