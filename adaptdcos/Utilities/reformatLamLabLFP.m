function reformatLamLabLFP(IDX)
%% format the LFP (ch x time x trls) for each session and export
flag_saveIDX = true;


%% find the number of sessions
for i = 1:size(IDX.allV1,2)
    sessions{i} = IDX.allV1(i).penetration; 
end
individualSes = unique(sessions)';

%% For loop on session
for i = 1:length(individualSes)
    disp(individualSes(i))
    % Electrode contact loop
    clear chCount LFP
    sesIdx = strfind(sessions, individualSes{i});
    chCount = 0;
    for j = 1:size(sesIdx,2)
        if sesIdx{j}
            chCount = chCount + 1;
            LFP(chCount,:,:) = IDX.allV1(j).SDF_crop;
            
        end
        
    end

    % SAVE
    if flag_saveIDX
        cd('E:\5 diIDX dir\laminarLabelingLFPs')
        saveName = strcat(individualSes{i},'_LFP_4LLC.mat');
        save(saveName,'LFP','-v7.3')
    else
        warning('LFP not saved')
    end

end

%%




load gong
sound(y,Fs)







end