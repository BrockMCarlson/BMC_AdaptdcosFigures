function gramm_2x2_RESP(IDX)
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
    for condLabel = [5 7 10 18]
       for uct = 1:uctLength
           count = count + 1;       
           % Categoricals - IVs
           if tmBlock == 1
               DataForVis.tmBlock{count} = 'Transient';
           elseif tmBlock == 2
               DataForVis.tmBlock{count} = 'Sustained';
           end
           
           if condLabel == 5
               DataForVis.condLabel{count} = 'Binocular';
           elseif condLabel == 7
               DataForVis.condLabel{count} = 'Dichoptic';
           elseif condLabel == 10
               DataForVis.condLabel{count} = 'Binoc Adapted';
           elseif condLabel == 18
               DataForVis.condLabel{count} = 'Dichop Adapted';
           end


           % DV - RESP
           DataForVis.RESP{count} = IDX.allV1(uct).RESP_avg{condLabel}(tmBlock);
           
           if isnan(DataForVis.RESP{count})
               count = count - 1;  %write over NaNs
           end

       end
    end
end



%% Gramm plots for vis repeated trajectories
close all

% Supra
clear g

g(1,1)=gramm('x',DataForVis.tmBlock,'y', DataForVis.RESP,'color',DataForVis.condLabel)
g(1,2)=copy(g(1));
g(1,3)=copy(g(1));
g(2,1)=copy(g(1));
g(2,2)=copy(g(1));


%Raw data as scatter plot
g(1,1).geom_point();
g(1,1).set_title('geom_point()');
g(1,1).set_order_options('x',{'Transient','Sustained'});


%Jittered scatter plot
g(1,2).geom_jitter('width',0.4,'height',0);
g(1,2).set_title('geom_jitter()');
g(1,2).set_order_options('x',{'Transient','Sustained'});

%Averages with confidence interval
% g(1,3).stat_summary('geom',{'bar','black_errorbar'});
g(1,3).set_title('stat_summary()');
% g(1,3).set_order_options('x',{'Transient','Sustained'});

%Boxplots
% g(2,1).stat_boxplot();
g(2,1).set_title('stat_boxplot()');
% g(2,1).set_order_options('x',{'Transient','Sustained'});

%Violin plots
g(2,2).stat_violin('fill','transparent');
g(2,2).set_title('stat_violin()');
g(2,2).set_order_options('x',{'Transient','Sustained'});

%These functions can be called on arrays of gramm objects
% g.set_names('x','Resp Win','y','dII','color','SOA');
g.set_title('dCOS RESP');


g.draw();




end

