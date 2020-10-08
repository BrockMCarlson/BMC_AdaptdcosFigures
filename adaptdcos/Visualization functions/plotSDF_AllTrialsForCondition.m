function plotSDF_AllTrialsForCondition(SDF,TM,textForSave)
global OUTDIR
cd(OUTDIR)


spkMax = max(SDF,[],'all');
count = 0;
clear trlLoop
for trlLoop = 1:size(SDF,1)
    close all
    count = count + 1;
    figure
    plot(TM,SDF(trlLoop,:))
    ylim([0 spkMax])
    vline(0)
    titleText = strcat('StimPresentation #',num2str(trlLoop));
    title(titleText)
    ylabel('spks/sec')
    xlabel('Time(sec)')

     if count == 1
        export_fig(textForSave,'-pdf','-nocrop') 
    else
        export_fig(textForSave,'-pdf','-nocrop','-append')
    end
end

close all
end