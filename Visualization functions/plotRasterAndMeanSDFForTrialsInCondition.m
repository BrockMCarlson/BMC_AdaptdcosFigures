function plotRasterAndMeanSDFForTrialsInCondition(SUA,SDF,TM,textForSave,textForTitle)
global OUTDIR
cd(OUTDIR)


figure
subplot(2,1,1)
spikesIn = SUA == 1;
MarkerFormat.MarkerSize = 5;
MarkerFormat.Marker = '.';
plotSpikeRaster(spikesIn,'PlotType','scatter','MarkerFormat',MarkerFormat);
newTM = TM(50:50:end);
if newTM(9) ~= .4
    error('check the manual TM input')
end
newNewTM = nan(1,length(newTM)+1);
newNewTM(1) = -.050;
newNewTM(2:length(newTM)+1) = newTM;
xticks(0:50:450);
xticklabels(newNewTM);
vline(50) % This unfortunatly is an index and not a label.
ylabel('Trial Number')
        
% Subplot of mean SDF ---
subplot(2,1,2)
SDFTrlsMean   = nanmean(SDF,1);    % Use trls to pull out continuous data   
plot(TM,SDFTrlsMean)  
% ylim([0 spkMax])
vline(0)
ylabel('spks/sec')
xlabel('Time(sec)')

sgtitle(textForTitle)

export_fig(textForSave,'-pdf','-nocrop')
