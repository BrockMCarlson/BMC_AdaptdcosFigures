% dMUAdCOF
% Current adaptdcos figure 2
% This runs in an old repository/archive. The goal of this code is to
% update it into the Modular Function Structure and create backup files on
% TEBA so it can be accesses, edited, and re-run anytime. 


% exampleKLS_condCompare
% taken from... EyeOriPref


clear
close all

PostSetup('brock')
global STIMDIR 
cd(STIMDIR)
list = recursdir(STIMDIR,'KLS');
flag_saveFigs = false;

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
   

   % loop units
   nel = length(STIM.units);
   for e = 1:nel
       sdf = squeeze(SDF(e,:,:));
       sua = squeeze(SUA(e,:,:));
       
       % pull out conditions
       DE = STIM.units(e).Eye(1);
       NDE = STIM.units(e).Eye(2);
       PS = STIM.units(e).Tilt(1);
       NS = STIM.units(e).Tilt(2);
       
        conditionarray = makeConditionArray(DE,NDE,PS,NS);
        
        % Sort by eyes      
        clear SORTED
        SORTED.eyes      = STIM.eyes;
        SORTED.contrasts = STIM.contrast;
        SORTED.tilts     = STIM.tilt;
        SORTED.flippedSOA = zeros(size(STIM.tilt));

        if DE == 2
            [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'ascend');
        else
            [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'descend');
        end
        clear w
        for w = 1:length(SORTED.eyes)
            SORTED.contrasts(w,:) = SORTED.contrasts(w,sortidx(w,:));
            SORTED.tilts(w,:)     = SORTED.tilts(w,sortidx(w,:));
        end; clear w
        
        count = 0;
        clear CondTrials CondTrialNum
        for cond = [5 6 9 10]
            if cond == 5 || cond == 6 % get simultaneous trials
                trls = I &...
                    SORTED.tilts(:,1) == conditionarray(cond,2) & ...
                    STIM.tiltmatch == conditionarray(cond,3) & ...
                    STIM.suppressor   == conditionarray(cond,4) & ...
                    STIM.soa       == conditionarray(cond,5) & ...
                    STIM.monocular == conditionarray(cond,6) & ...
                    ((SORTED.contrasts(:,1)  >= .8) & (SORTED.contrasts(:,1)  <= 1 )) &...
                    ((SORTED.contrasts(:,2)  >= .8) & (SORTED.contrasts(:,2)  <= 1 ));
            else    
                % get suppressor trials
                trls = I &... %everything is in second column bc BRFS format is [adapter STIM.suppressor]
                    STIM.suppressor &...
                    STIM.eyes(:,2) == conditionarray(cond,1) &...
                    STIM.tilt(:,2) ==  conditionarray(cond,2) & ...
                    STIM.tiltmatch == conditionarray(cond,3) & ...
                    STIM.suppressor   == conditionarray(cond,4) & ...  
                    STIM.soa       == conditionarray(cond,5) & ...
                    STIM.monocular == conditionarray(cond,6) & ...
                    ((SORTED.contrasts(:,1)  >= .8) & (SORTED.contrasts(:,1)  <= 1 )) &...
                    ((SORTED.contrasts(:,2)  >= .8) & (SORTED.contrasts(:,2)  <= 1 ));
            end
            count = count+1;
            CondTrials{count} = find(trls);
            CondTrialNum(count) = sum(trls);
        end
   
       
       
       % Store each trial's data for 2x2 matrix
       sdfwin  = [-0.05  .4];
       clear cond IndvTrlOut_SDF IndvTrlOut_SUA MeanSDFOut
       for output = 1:4
           SDF_fulltm = nan(size(CondTrials{output},1),size(sdf,1));
           SUA_fulltm = nan(size(CondTrials{output},1),size(sua,1));
           for trial = 1:CondTrialNum(output)
               SDF_fulltm(trial,:) = sdf(:,CondTrials{output}(trial));
               SUA_fulltm(trial,:) = sua(:,CondTrials{output}(trial));
           end
           [croppedSDF] = cropDATA(SDF_fulltm,sdftm,sdfwin); 
           [croppedSUA] = cropDATA(SUA_fulltm,sdftm,sdfwin);
           IndvTrlOut_SDF{output} = croppedSDF;
           IndvTrlOut_SUA{output} = croppedSUA;
           MeanSDFOut(output,:) = nanmean(croppedSDF,1);
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
        
%         close all
        figure
        
        % raster
        rasterPos = [3,4,7,8];
        clear output
        for output = 1:4
            subplot(4,2,rasterPos(output))
            spikesIn = IndvTrlOut_SUA{output} == 1;
            MarkerFormat.MarkerSize = 5;
            MarkerFormat.Marker = '.';
            plotSpikeRaster(spikesIn,'PlotType','scatter','MarkerFormat',MarkerFormat);
            xticks(0:50:450);
            xticklabels(newNewTM);
            vline(50) % This unfortunatly is an index and not a label.
            if output == 3
                ylabel('Trial Number')
                xlabel('Time(sec)')
            end
        end

        % Subplot of mean SDF ---
        sdfPos = [1,2,5,6];
        maxFr  = max(max(MeanSDFOut));
        subTitleText = {'C_Simult','IC_simul','C_800','IC_800'};
        clear output
        for output = 1:4      
            subplot(4,2,sdfPos(output))
            SDFTrlsMean   = MeanSDFOut(output,:);    % Use trls to pull out continuous data   
            plot(TM,SDFTrlsMean)  
            % ylim([0 spkMax])
            xlim([TM(1) TM(end)])
            ylim([0 maxFr])
            vline(0)
            title(subTitleText{output}, 'interpreter', 'none')
            if output == 3
                ylabel('spks/sec')
            end
        end
        set(gcf, 'Position', [89.8000 77.8000 958.4000 684]);
        textForTitle = {strcat('Unit ID =',string(STIM.units(e).fileclust(2))),...
            strcat('Unit depth =',string(STIM.units(e).depth(2))),...
            strcat('Firing Rate =',string(STIM.units(e).rate))};
        sgtitle(textForTitle)
       
        if flag_saveFigs
            global OUTDIR
            cd(OUTDIR)
            textForSave = strcat(STIM.header,'_depth-',string(STIM.units(e).depth(2)));
            export_fig(textForSave,'-pdf','-nocrop')
        end
   end
    
    
end