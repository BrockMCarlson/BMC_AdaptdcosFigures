function violinPlots(IDX,flag_SaveFigs)


%% Goal
% lets try out all of the gramm plots under the gramm heading:
    % Methods for visualizing Y~X relationships with X as categorical variable
% Ultimately I think I really want the violin plots.


%% Build DataForVis structure
% esentially taking IDX and turning it into the 'cars' format from gramm
%resp dimension.  1 = transient, 2 = sustained, 3 = full time, 4 = baseline.
%    50   100       TRANSIENT
%    150   250      SUSTAINED
%     50   250      FULL TIME
%    -50     0      BASELINE

clear DataForVis
count = 0;
supraLength = length(IDX.Supra);
for tmBlock = 1:2
    for adaptation = 1:2
       for supraUct = 1:supraLength
           count = count + 1;
           % Categoricals - IVs
           if tmBlock == 1
               DataForVis.Supra.tmBlock(count,1) = {'Transient'};
           elseif tmBlock == 2
               DataForVis.Supra.tmBlock(count,1) = {'Sustained'};
           end
           if adaptation == 1
               DataForVis.Supra.adaptation(count,1) = {'Simultaneous'};
           elseif adaptation == 2
               DataForVis.Supra.adaptation(count,1) = {'Adapted'};
           end

           % DV
           DataForVis.Supra.dII(count,1) = IDX.Supra(supraUct).dII(adaptation,tmBlock);
       end
    end
end

count = 0;
granularLength = length(IDX.Granular);
for tmBlock = 1:2
    for adaptation = 1:2
       for granularUct = 1:granularLength
           count = count + 1;
           % Categoricals - IVs
           if tmBlock == 1
               DataForVis.Granular.tmBlock(count,1) = {'Transient'};
           elseif tmBlock == 2
               DataForVis.Granular.tmBlock(count,1) = {'Sustained'};
           end
           if adaptation == 1
               DataForVis.Granular.adaptation(count,1) = {'Simultaneous'};
           elseif adaptation == 2
               DataForVis.Granular.adaptation(count,1) = {'Adapted'};
           end

           % DV
           DataForVis.Granular.dII(count,1) = IDX.Granular(granularUct).dII(adaptation,tmBlock);
       end
    end
end

count = 0;
infraLength = length(IDX.Infra);
for tmBlock = 1:2
    for adaptation = 1:2
       for infraUct = 1:infraLength
           count = count + 1;
           % Categoricals - IVs
           if tmBlock == 1
               DataForVis.Infra.tmBlock(count,1) = {'Transient'};
           elseif tmBlock == 2
               DataForVis.Infra.tmBlock(count,1) = {'Sustained'};
           end
           if adaptation == 1
               DataForVis.Infra.adaptation(count,1) = {'Simultaneous'};
           elseif adaptation == 2
               DataForVis.Infra.adaptation(count,1) = {'Adapted'};
           end

           % DV
           DataForVis.Infra.dII(count,1) = IDX.Infra(infraUct).dII(adaptation,tmBlock);
       end
    end
end





%% Gramm plots
close all

% Supra
clear g

g(1,1)=gramm('x',DataForVis.Supra.tmBlock,'y', DataForVis.Supra.dII,'color',DataForVis.Supra.adaptation,'subset',strcmp(DataForVis.Supra.adaptation,'Simultaneous') |strcmp(DataForVis.Supra.adaptation,'Adapted'));
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
g(1,3).stat_summary('geom',{'bar','black_errorbar'});
g(1,3).set_title('stat_summary()');
g(1,3).set_order_options('x',{'Transient','Sustained'});

%Boxplots
g(2,1).stat_boxplot();
g(2,1).set_title('stat_boxplot()');
g(2,1).set_order_options('x',{'Transient','Sustained'});

%Violin plots
g(2,2).stat_violin('fill','transparent');
g(2,2).set_title('stat_violin()');
g(2,2).set_order_options('x',{'Transient','Sustained'});

%These functions can be called on arrays of gramm objects
g.set_names('x','Resp Win','y','dII','color','SOA');
g.set_title({'Supragranular','Visualization of Y~X relationships with X as categorical variable'});


figure('Position',[421 175 1000 632]);
g.draw();
% Save Figs?
if flag_SaveFigs
    cd('E:\6 Plot Dir\1.4 LaminarAnalysis\1.4.1 laminar dII')
    saveas(gcf,'laminar_dII_Supra.png')
end




% Granular
clear g

g(1,1)=gramm('x',DataForVis.Granular.tmBlock,'y', DataForVis.Granular.dII,'color',DataForVis.Granular.adaptation,'subset',strcmp(DataForVis.Granular.adaptation,'Simultaneous') |strcmp(DataForVis.Granular.adaptation,'Adapted'));
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
g(1,3).stat_summary('geom',{'bar','black_errorbar'});
g(1,3).set_title('stat_summary()');
g(1,3).set_order_options('x',{'Transient','Sustained'});

%Boxplots
g(2,1).stat_boxplot();
g(2,1).set_title('stat_boxplot()');
g(2,1).set_order_options('x',{'Transient','Sustained'});

%Violin plots
g(2,2).stat_violin('fill','transparent');
g(2,2).set_title('stat_violin()');
g(2,2).set_order_options('x',{'Transient','Sustained'});

%These functions can be called on arrays of gramm objects
g.set_names('x','Resp Win','y','dII','color','SOA');
g.set_title({'Granular','Visualization of Y~X relationships with X as categorical variable'});


figure('Position',[421 175 1000 632]);
g.draw();
% Save Figs?
if flag_SaveFigs
    cd('E:\6 Plot Dir\1.4 LaminarAnalysis\1.4.1 laminar dII')
    saveas(gcf,'laminar_dII_Granular.png')
end



% Infra
clear g

g(1,1)=gramm('x',DataForVis.Infra.tmBlock,'y', DataForVis.Infra.dII,'color',DataForVis.Infra.adaptation,'subset',strcmp(DataForVis.Infra.adaptation,'Simultaneous') |strcmp(DataForVis.Infra.adaptation,'Adapted'));
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
g(1,3).stat_summary('geom',{'bar','black_errorbar'});
g(1,3).set_title('stat_summary()');
g(1,3).set_order_options('x',{'Transient','Sustained'});

%Boxplots
g(2,1).stat_boxplot();
g(2,1).set_title('stat_boxplot()');
g(2,1).set_order_options('x',{'Transient','Sustained'});

%Violin plots
g(2,2).stat_violin('fill','transparent');
g(2,2).set_title('stat_violin()');
g(2,2).set_order_options('x',{'Transient','Sustained'});

%These functions can be called on arrays of gramm objects
g.set_names('x','Resp Win','y','dII','color','SOA');
g.set_title({'Infragranular','Visualization of Y~X relationships with X as categorical variable'});


figure('Position',[421 175 1000 632]);
g.draw();


% Save Figs?
if flag_SaveFigs
    cd('E:\6 Plot Dir\1.4 LaminarAnalysis\1.4.1 laminar dII')
    saveas(gcf,'laminar_dII_Infra.png')
end

end


