function gramm_2x2_RESP_NSNDEvariation(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM(1:560);

clear DataForVis
count = 0;
uctLength = length(IDX.allV1);
for tmBlock = 1:2
    for condLabel = [6 7 12 20]
       for uct = 1:uctLength
           count = count + 1;       
           % Categoricals - IVs
           if tmBlock == 1
               DataForVis.tmBlock{count,1} = 'Transient';
           elseif tmBlock == 2
               DataForVis.tmBlock{count,1} = 'Sustained';
           end
           
           if condLabel == 6
               DataForVis.condLabel{count} = 'Con NS Simult';
           elseif condLabel == 7
               DataForVis.condLabel{count} = 'Dichoptic';
           elseif condLabel == 12
               DataForVis.condLabel{count} = 'C Flash NS NDE';
           elseif condLabel == 20
               DataForVis.condLabel{count} = 'BRFS flash NS NDE';
           end

           
           % DV - RESP
           DataForVis.RESP(count,1) = IDX.allV1(uct).RESP_avg{condLabel}(tmBlock);
           
           if isnan(DataForVis.RESP(count,1))
               count = count - 1;  %write over NaNs
           end

       end
    end
end



%% Gramm plots for vis repeated trajectories


clear g

x_resp = DataForVis.tmBlock;
y_resp = DataForVis.RESP;% Y values must be in format "double"
c_resp = DataForVis.condLabel;


% Violin plot with stat_summary
g(1,1)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(DataForVis.tmBlock,'Transient'));
g(1,1).set_order_options('x',0,'color',0)
g(1,1).set_names('x','Stimulus Presented','y','Impulses/sec','color','Stimulus Presented');
% g(1,1).stat_violin('normalization','width','dodge',0,'fill','transparent');
% g(1,1).stat_boxplot('width',0.5,'dodge',0,'notch',true);
g(1,1).stat_summary('geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
g(1,1).set_title('Transient time period (50-100ms)');
g(1,1).set_color_options('map','brewer_dark');

g(1,2)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(DataForVis.tmBlock,'Sustained'));
g(1,2).set_order_options('x',0,'color',0)
g(1,2).set_names('x','Stimulus Presented','y','Impulses/sec','color','Stimulus Presented');
% g(1,2).stat_violin('normalization','width','dodge',0,'fill','transparent');
% g(1,2).stat_boxplot('width',0.5,'dodge',0,'notch',true);
g(1,2).stat_summary('geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
g(1,2).set_title('Sustained time period (150-250ms)');
g(1,2).set_color_options('map','brewer_dark');


figure('Position',[615.4000 253.8000 646.4000 205.6000]);
g.axe_property('YLim',[0 250]);
g.draw();









end

