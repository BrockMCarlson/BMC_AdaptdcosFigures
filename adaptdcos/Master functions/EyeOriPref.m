% EyeOriPref
% 2x2 Eye vs ori raster and SDF plots
% Fill with NaN's if data not present.
% plot for all available conditions on every unit.

clear
close all

PostSetup('brock')
global STIMDIR 
cd(STIMDIR)
list = recursdir(STIMDIR,'KLS');

for i = 1:length(list)
    clear RESP SDF STIM SUA psthtm sdftm win_ms
    load(list{i}) 
    load(strcat(list{i}(1:end-8),'.mat'))
   
    % Pull out trials with monocular conditions
        % get monocular tilts
        brfsFileNum = STIM.units(1).fileclust(1);
        clear I
        I = STIM.ditask...
            & STIM.filen == brfsFileNum ...
            & ~STIM.blank ...
            & STIM.rns == 0 ...
            & STIM.cued == 0 ...
            & STIM.motion == 0;
        tilts = nanunique(STIM.tilt(I,:));
   
        % get condition matrix
           condition= table(...
            [2  3  2  3]',... %eyes1
            [tilts(1)  tilts(1)  tilts(2)  tilts(2) ]',... %tilt1
            [1   1   1   1  ]',... %tiltmatch
            [0   0   0   0  ]',... %suppressor
            [0   0   0   0  ]',... %soa
            [1   1   1   1  ]',... %monoc
            'VariableNames',{'eyes1','tilt1','tiltmatch','suppressor','soa','monoc'});

    condition.Properties.RowNames = {...
        'Monocualr eye2 tilt1',...
        'Monocualr eye3 tilt1',...
        'Monocualr eye2 tilt2',...
        'Monocualr eye3 tilt2',...
        };
    conditionarray = table2array(condition);

    for cond = 1:4
        trls = I &...
            STIM.eye        == conditionarray(cond,1) &...
            STIM.tilt(:,1)  == conditionarray(cond,2) & ...
            STIM.tiltmatch  == conditionarray(cond,3) & ...
            STIM.suppressor == conditionarray(cond,4) & ...
            STIM.soa        == conditionarray(cond,5) & ...
            STIM.monocular  == conditionarray(cond,6) & ...
            (STIM.contrast(:,1)  >= .3 & STIM.contrast(:,1) <= 1); 
        CondTrials{cond} = find(trls);
        CondTrialNum(cond) = sum(trls);
    end
   
   % loop units
   nel = length(STIM.units);
   for e = 1:nel
       sdf = squeeze(SDF(e,:,:));
       sua = squeeze(SUA(e,:,:));
       % Store each trial's data for 2x2 matrix
       sdfwin  = [-0.05  .4];
       clear cond IndvTrlOut_SDF IndvTrlOut_SUA MeanSDFOut
       for cond = 1:4
           SDF_fulltm = nan(size(CondTrials{cond},1),size(sdf,1));
           SUA_fulltm = nan(size(CondTrials{cond},1),size(sua,1));
           for trial = 1:CondTrialNum(cond)
               SDF_fulltm(trial,:) = sdf(:,CondTrials{cond}(trial));
               SUA_fulltm(trial,:) = sua(:,CondTrials{cond}(trial));
           end
           [croppedSDF] = cropDATA(SDF_fulltm,sdftm,sdfwin); 
           [croppedSUA] = cropDATA(SUA_fulltm,sdftm,sdfwin);
           IndvTrlOut_SDF{cond} = croppedSDF;
           IndvTrlOut_SUA{cond} = croppedSUA;
           MeanSDFOut(cond,:) = nanmean(croppedSDF,1);
      end
           [holder,TM] = cropDATA(SUA_fulltm,sdftm,sdfwin);

       % Plot 2x2 raster and sdf
        newTM = TM(50:50:end);
        if newTM(9) ~= .4
            error('check the manual TM input')
        end
        newNewTM = nan(1,length(newTM)+1);
        newNewTM(1) = -.050;
        newNewTM(2:length(newTM)+1) = newTM;
        
        close all
        figure
        
        % raster
        rasterPos = [3,4,7,8];
        clear cond
        for cond = 1:4
            subplot(4,2,rasterPos(cond))
            spikesIn = IndvTrlOut_SUA{cond} == 1;
            MarkerFormat.MarkerSize = 5;
            MarkerFormat.Marker = '.';
            plotSpikeRaster(spikesIn,'PlotType','scatter','MarkerFormat',MarkerFormat);
            xticks(0:50:450);
            xticklabels(newNewTM);
            vline(50) % This unfortunatly is an index and not a label.
            if cond == 3
                ylabel('Trial Number')
                xlabel('Time(sec)')
            end
        end

        % Subplot of mean SDF ---
        sdfPos = [1,2,5,6];
        maxFr  = max(max(MeanSDFOut));
        clear cond
        for cond = 1:4      
            subplot(4,2,sdfPos(cond))
            SDFTrlsMean   = MeanSDFOut(cond,:);    % Use trls to pull out continuous data   
            plot(TM,SDFTrlsMean)  
            % ylim([0 spkMax])
            xlim([TM(1) TM(end)])
            ylim([0 maxFr])
            vline(0)
            subTitleText = {strcat('Eye=',string(conditionarray(cond,1))),...
                strcat('Tilt=',string(conditionarray(cond,2))),...
                strcat('TrialNum=',string(CondTrialNum(cond)))};
            title(subTitleText)
            if cond == 3
                ylabel('spks/sec')
            end
        end
        set(gcf, 'Position', [89.8000 77.8000 958.4000 684]);
        textForTitle = {strcat('Unit ID =',string(STIM.units(e).fileclust(2))),...
            strcat('Unit depth =',string(STIM.units(e).depth(2))),...
            strcat('Firing Rate =',string(STIM.units(e).rate))};
        sgtitle(textForTitle)
       
        global OUTDIR
        cd(OUTDIR)
        textForSave = strcat(STIM.header,'_depth-',string(STIM.units(e).depth(2)));
        export_fig(textForSave,'-pdf','-nocrop')
   end
    
    
end