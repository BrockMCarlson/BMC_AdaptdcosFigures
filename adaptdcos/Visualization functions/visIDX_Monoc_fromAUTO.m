function Monoc = visIDX_Monoc_fromAUTO(sdf,info)

SDFmax = max(sdf,[],'all');
TM = info.TM;
Monoc = figure;
    condNum = [1,2,3,4];
    for i = 1:4
        subplot(4,1,i)
        plot(TM,sdf(condNum(i),:),'-k','LineWidth',2);hold on;
        title({info.conditNameForCC{condNum(i)},strcat('TrlNum=',string(info.CondTrialNum_SDF(condNum(i))))})
        xlim([-0.05 0.3])
        ylim([-.5 1.2*SDFmax])
        vline(0)
    end
      


sgtitle(strcat('Monoc_Depth=',string(info.Depth)),'interpreter', 'none')
set(gcf,'Position',[488 72.2000 245 689.8000])

Monoc.Name = 'Monoc';



end

