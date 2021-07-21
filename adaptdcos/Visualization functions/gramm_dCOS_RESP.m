function gramm_dCOS_RESP(IDX)
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
    for condLabel = [1 5 8]
       for uct = 1:uctLength
           count = count + 1;       
           % Categoricals - IVs
           if tmBlock == 1
               DataForVis.tmBlock{count,1} = 'Transient';
           elseif tmBlock == 2
               DataForVis.tmBlock{count,1} = 'Sustained';
           end
           
           if condLabel == 1
               DataForVis.condLabel{count,1} = 'Monocular';
           elseif condLabel == 5
               DataForVis.condLabel{count,1} = 'Binocular';
           elseif condLabel == 7
               DataForVis.condLabel{count,1} = 'Dichoptic';
           elseif condLabel == 8
               DataForVis.condLabel{count,1} = 'Dichoptic';       
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



g(1,1)=gramm('x',x_resp,'y',y_resp,'color',c_resp);
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));

%Averages with confidence interval
g(1,1).stat_summary('geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
g(1,1).set_title('stat_summary()');
g(1,1).set_order_options('x',0,'color',0);



%Boxplots
g(1,2).stat_boxplot();
g(1,2).set_title('stat_boxplot()');
g(1,2).set_order_options('x',0,'color',0);



%Violin plots
g(1,3).stat_violin('fill','transparent');
g(1,3).set_title('stat_violin()');
g(1,3).set_order_options('x',0,'color',0);


%These functions can be called on arrays of gramm objects
g.set_names('x','Time Window','y','Impulses/sec','color','Visual Stimulus');
g.set_title('Dichoptic Suppression');


figure('Position',[107 403 1580 492]);
g.draw();






end

