% dMUAdCOF
% Current adaptdcos figure 2 (or 3 I guess...)
% This runs in an old repository/archive. The goal of this code is to
% update it into the Modular Function Structure and create backup files on
% TEBA so it can be accesses, edited, and re-run anytime. 


% exampleKLS_condCompare
% taken from... EyeOriPref


clear
close all


flag_saveFigs = false;

cd('D:\5 diIDX dir')
list = {'JoVContrast','HighContrast','LowLow','MedMed'};
[indx,tf] = listdlg('ListString',list);

list2 = {'all V1 contacts','I 34 contacts only'};
[indx2,tf2] = listdlg('ListString',list2);

% for indx = 1:4
%     for indx2 = 1:2
       cd('D:\5 diIDX dir')
        if indx == 1 
            if ~exist('D:\5 diIDX dir\diIDX_AUTO_JoVContrast.mat','file')
                % No inputs or outputs are required. This will run all of the _AUTO
                % files found on TEBA in T:\diSTIM - adaptdcos&CRF\STIM and save the
                % diIDX variable will all of of the saved photo-diode triggered SDFs
                % etc. to the pre-determined IDX direcotry. This should be backed up on
                % TEBA. The IDX variable is 183 MB.
                AUTOdiIDX_JoVContrast
            end
            load('D:\5 diIDX dir\diIDX_AUTO_JoVContrast.mat')
        elseif indx == 2 
            if ~exist('D:\5 diIDX dir\diIDX_AUTO_highContrast.mat','file')
                AUTOdiIDX_highContrast
            end
            load('D:\5 diIDX dir\diIDX_AUTO_highContrast.mat')
        elseif indx == 3
            if ~exist('D:\5 diIDX dir\diIDX_AUTO_LowLowContrast.mat','file')
                AUTOdiIDX_LowLowContrast
            end
            load('D:\5 diIDX dir\diIDX_AUTO_LowLowContrast.mat')
        elseif indx == 4
            if ~exist('D:\5 diIDX dir\diIDX_AUTO_MediumMediumContrast.mat','file')
                AUTOdiIDX_MediumMediumContrast
            end
            load('D:\5 diIDX dir\diIDX_AUTO_MediumMediumContrast.mat')
        end



        %% Figures!
        if flag_saveFigs
            close all
        end
        
        if indx2 == 1
            visIDX_fig3_fromAUTO(IDX,'z-scored');
            zScored = gcf;
            zScored.Name = 'zScored';
            visIDX_fig3_fromAUTO(IDX,'raw');
            raw = gcf;
            raw.Name = 'raw';
        elseif indx2 == 2
            visIDX_fig3_fromAUTO_I34Only(IDX,'z-scored');
            zScored = gcf;
            zScored.Name = 'zScored';
            visIDX_fig3_fromAUTO_I34Only(IDX,'raw');
            raw = gcf;
            raw.Name = 'raw';
        end



        if indx2 == 1 && flag_saveFigs
            cd('D:\6 Plot Dir\dMUAdCOF\Contrast comparison across 2 monkeys')
            if indx == 1 
                saveas(zScored,'dMUA_allV1_dCOF_zScored-JoVContrast.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-JoVContrast.png');
            elseif indx == 2
                saveas(zScored,'dMUA_allV1_dCOF_zScored-HighContrast.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-HighContrast.png');
            elseif indx == 3 
                saveas(zScored,'dMUA_allV1_dCOF_zScored-LowLowC.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-LowLowC.png');
            elseif indx == 4 
                saveas(zScored,'dMUA_allV1_dCOF_zScored-MedMedC.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-MedMedC.png');
            end

        elseif indx2 == 2 && flag_saveFigs
            cd('D:\6 Plot Dir\dMUAdCOF\Contrast comparison in I34 only')
            if indx == 1 
                saveas(zScored,'dMUA_allV1_dCOF_zScored-JoVContrast-I34.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-JoVContrast-I34.png');
            elseif indx == 2
                saveas(zScored,'dMUA_allV1_dCOF_zScored-HighContrast-I34.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-HighContrast-I34.png');
            elseif indx == 3 
                saveas(zScored,'dMUA_allV1_dCOF_zScored-LowLowC-I34.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-LowLowC-I34.png');
           elseif indx == 4 
                saveas(zScored,'dMUA_allV1_dCOF_zScored-MedMedC-I34.png');
                saveas(raw,'dMUA_allV1_dCOF_raw-MedMedC-I34.png');

            end
            
            
        end
%     end
% end



