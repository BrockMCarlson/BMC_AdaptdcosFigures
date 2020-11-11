% dMUAdCOF
% Current adaptdcos figure 2 (or 3 I guess...)
% This runs in an old repository/archive. The goal of this code is to
% update it into the Modular Function Structure and create backup files on
% TEBA so it can be accesses, edited, and re-run anytime. 


% exampleKLS_condCompare
% taken from... EyeOriPref


clear
close all


flag_saveFigs = true;

cd('D:\5 diIDX dir')
if ~exist('diIDX_AUTO.mat')
    % No inputs or outputs are required. This will run all of the _AUTO
    % files found on TEBA in T:\diSTIM - adaptdcos&CRF\STIM and save the
    % diIDX variable will all of of the saved photo-diode triggered SDFs
    % etc. to the pre-determined IDX direcotry. This should be backed up on
    % TEBA. The IDX variable is 183 MB.
    AUTOdiIDX
else
    load('diIDX_AUTO.mat')
end

%% Figures!
close all
visIDX_fig3_fromAUTO(IDX,'z-scored');
zScored = gcf;
zScored.Name = 'zScored';
visIDX_fig3_fromAUTO(IDX,'raw');
raw = gcf;
raw.Name = 'raw';



if flag_saveFigs
    cd('D:\6 Plot Dir')
    saveas(zScored,'dMUA_allV1_dCOF_zScored.svg');
    saveas(raw,'dMUA_allV1_dCOF_raw.svg');
end


