function ICsoa = visIDX_ICsoa_fromAUTO(sdf,info)

SDFmax = max(sdf,[],'all');
TM = info.TM;
ICsoa = figure;
    condNum = [13,14,15,16];
    for i = 1:4
        subplot(4,1,i)
        plot(TM,sdf(condNum(i),:),'-k','LineWidth',2);hold on;
        title({info.conditNameForCC{condNum(i)},strcat('TrlNum=',string(info.CondTrialNum_SDF(condNum(i))))})
        xlim([-0.05 0.3])
        ylim([-.5 1.2*SDFmax])
        vline(0)
    end
      


sgtitle(strcat('IC-soa_Depth=',string(info.Depth)),'interpreter', 'none')
set(gcf,'Position',[1.2114e+03 79.4000 244.8000 689.6000])

ICsoa.Name = 'ICsoa';



end

