function gramm_2x2laminar_subline(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM(1:560);


clear DataForVis uctLength
count = 0;
uctLength = length(IDX.allV1);
for condLabel = [1 2]
   for uct = 1:uctLength
       count = count + 1;       
       % Categoricals - IVs
       if condLabel == 1
           DataForVis.condLabel{count} = 'Simultaneous';
       elseif condLabel == 2
           DataForVis.condLabel{count} = 'Adapted';
       end
       if IDX.allV1(uct).depth(2) > 5
           DataForVis.depth{count} = 'Supra';
       elseif IDX.allV1(uct).depth(2) >= 0 && IDX.allV1(uct).depth(2) <= 5
           DataForVis.depth{count} = 'Granular';
       elseif IDX.allV1(uct).depth(2) < 0
           DataForVis.depth{count} = 'Infra';
       end

       % DV - SDF
       if condLabel == 1
           if isempty(IDX.allV1(uct).SDF_avg{5}) || ...
                   any(isnan(IDX.allV1(uct).SDF_avg{5}(1:560))) ||...
                   isempty(IDX.allV1(uct).SDF_avg{7})||...
                   any(isnan(IDX.allV1(uct).SDF_avg{7}(1:560)))
               count = count - 1;
           else
               congSDF = IDX.allV1(uct).SDF_avg{5}(1:560)';
               inCoSDF = IDX.allV1(uct).SDF_avg{7}(1:560)';
               subSDF = congSDF - inCoSDF;
               DataForVis.SDF{count,1} = subSDF;
           end
       elseif condLabel == 2
           if isempty(IDX.allV1(uct).SDF_avg{10}) || ...
                   any(isnan(IDX.allV1(uct).SDF_avg{10}(1:560))) ||...
                   isempty(IDX.allV1(uct).SDF_avg{18})||...
                   any(isnan(IDX.allV1(uct).SDF_avg{18}(1:560)))
               count = count - 1;
           else
               congSDF = IDX.allV1(uct).SDF_avg{10}(1:560)';
               inCoSDF = IDX.allV1(uct).SDF_avg{18}(1:560)';
               subSDF = congSDF - inCoSDF;
               DataForVis.SDF{count,1} = subSDF;
           end
       end
       
   end
end

% % clear DataForVis uctLength
% % count = 0;
% % uctLength = length(IDX.Supra);
% % for condLabel = [1 2]
% %    for uct = 1:uctLength
% %        count = count + 1;       
% %        % Categoricals - IVs
% %        if condLabel == 1
% %            DataForVis.Supra.condLabel{count} = 'Simultaneous';
% %        elseif condLabel == 2
% %            DataForVis.Supra.condLabel{count} = 'Adapted';
% %        end
% % 
% %        % DV - SDF
% %        if condLabel == 1
% %            if isempty(IDX.Supra(uct).SDF_avg{5}) || ...
% %                    any(isnan(IDX.Supra(uct).SDF_avg{5}(1:560))) ||...
% %                    isempty(IDX.Supra(uct).SDF_avg{7})||...
% %                    any(isnan(IDX.Supra(uct).SDF_avg{7}(1:560)))
% %                count = count - 1;
% %            else
% %                congSDF = IDX.Supra(uct).SDF_avg{5}(1:560)';
% %                inCoSDF = IDX.Supra(uct).SDF_avg{7}(1:560)';
% %                subSDF = congSDF - inCoSDF;
% %                DataForVis.Supra.SDF{count,1} = subSDF;
% %            end
% %        elseif condLabel == 2
% %            if isempty(IDX.Supra(uct).SDF_avg{10}) || ...
% %                    any(isnan(IDX.Supra(uct).SDF_avg{10}(1:560))) ||...
% %                    isempty(IDX.Supra(uct).SDF_avg{18})||...
% %                    any(isnan(IDX.Supra(uct).SDF_avg{18}(1:560)))
% %                count = count - 1;
% %            else
% %                congSDF = IDX.Supra(uct).SDF_avg{10}(1:560)';
% %                inCoSDF = IDX.Supra(uct).SDF_avg{18}(1:560)';
% %                subSDF = congSDF - inCoSDF;
% %                DataForVis.Supra.SDF{count,1} = subSDF;
% %            end
% %        end
% %        
% %    end
% % end
% % 
% % clear uctLength
% % count = 0;
% % uctLength = length(IDX.Granular);
% % for condLabel = [1 2]
% %    for uct = 1:uctLength
% %        count = count + 1;       
% %        % Categoricals - IVs
% %        if condLabel == 1
% %            DataForVis.Granular.condLabel{count} = 'Simultaneous';
% %        elseif condLabel == 2
% %            DataForVis.Granular.condLabel{count} = 'Adapted';
% %        end
% % 
% %        % DV - SDF
% %        if condLabel == 1
% %            if isempty(IDX.Granular(uct).SDF_avg{5}) || ...
% %                    any(isnan(IDX.Granular(uct).SDF_avg{5}(1:560))) ||...
% %                    isempty(IDX.Granular(uct).SDF_avg{7})||...
% %                    any(isnan(IDX.Granular(uct).SDF_avg{7}(1:560)))
% %                count = count - 1;
% %            else
% %                congSDF = IDX.Granular(uct).SDF_avg{5}(1:560)';
% %                inCoSDF = IDX.Granular(uct).SDF_avg{7}(1:560)';
% %                subSDF = congSDF - inCoSDF;
% %                DataForVis.Granular.SDF{count,1} = subSDF;
% %            end
% %        elseif condLabel == 2
% %            if isempty(IDX.Granular(uct).SDF_avg{10}) || ...
% %                    any(isnan(IDX.Granular(uct).SDF_avg{10}(1:560))) ||...
% %                    isempty(IDX.Granular(uct).SDF_avg{18})||...
% %                    any(isnan(IDX.Granular(uct).SDF_avg{18}(1:560)))
% %                count = count - 1;
% %            else
% %                congSDF = IDX.Granular(uct).SDF_avg{10}(1:560)';
% %                inCoSDF = IDX.Granular(uct).SDF_avg{18}(1:560)';
% %                subSDF = congSDF - inCoSDF;
% %                DataForVis.Granular.SDF{count,1} = subSDF;
% %            end
% %        end
% %        
% %    end
% % end
% % 
% % 
% % clear uctLength
% % count = 0;
% % uctLength = length(IDX.Infra);
% % for condLabel = [1 2]
% %    for uct = 1:uctLength
% %        count = count + 1;       
% %        % Categoricals - IVs
% %        if condLabel == 1
% %            DataForVis.Infra.condLabel{count} = 'Simultaneous';
% %        elseif condLabel == 2
% %            DataForVis.Infra.condLabel{count} = 'Adapted';
% %        end
% % 
% %        % DV - SDF
% %        if condLabel == 1
% %            if isempty(IDX.Infra(uct).SDF_avg{5}) || ...
% %                    any(isnan(IDX.Infra(uct).SDF_avg{5}(1:560))) ||...
% %                    isempty(IDX.Infra(uct).SDF_avg{7})||...
% %                    any(isnan(IDX.Infra(uct).SDF_avg{7}(1:560)))
% %                count = count - 1;
% %            else
% %                congSDF = IDX.Infra(uct).SDF_avg{5}(1:560)';
% %                inCoSDF = IDX.Infra(uct).SDF_avg{7}(1:560)';
% %                subSDF = congSDF - inCoSDF;
% %                DataForVis.Infra.SDF{count,1} = subSDF;
% %            end
% %        elseif condLabel == 2
% %            if isempty(IDX.Infra(uct).SDF_avg{10}) || ...
% %                    any(isnan(IDX.Infra(uct).SDF_avg{10}(1:560))) ||...
% %                    isempty(IDX.Infra(uct).SDF_avg{18})||...
% %                    any(isnan(IDX.Infra(uct).SDF_avg{18}(1:560)))
% %                count = count - 1;
% %            else
% %                congSDF = IDX.Infra(uct).SDF_avg{10}(1:560)';
% %                inCoSDF = IDX.Infra(uct).SDF_avg{18}(1:560)';
% %                subSDF = congSDF - inCoSDF;
% %                DataForVis.Infra.SDF{count,1} = subSDF;
% %            end
% %        end
% %        
% %    end
% % end




%% Gramm plots for vis repeated trajectories
clear g
% g(1,1)=gramm('x',x,'y',y,'color',c);

g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',strcmp(DataForVis.depth,'Supra'));
g(1,1).set_title('Supragranular');
g(2,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',strcmp(DataForVis.depth,'Granular'));
g(2,1).set_title('Granular');
g(3,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',strcmp(DataForVis.depth,'Infra'));
g(3,1).set_title('Infragranular');

for i = 1:3
    g(i,1).stat_summary();
    g(i,1).set_color_options('map','brewer2');
    g(i,1).set_order_options('color',0);
    g(i,1).geom_polygon('x',{[.05 .1 .1 .05] ; [.15 .25 .25 .15]} ,'y',{[-75 -75 40 40];  [-75 -75 40 40]},'color',[.5 .5 .5]);
    g(i,1).axe_property('XLim',[-.050 .5]);
    g(i,1).axe_property('YLim',[-80 50]);
    g(i,1).geom_vline('xintercept',0)
    g(i,1).geom_hline('yintercept',0)

end

g.set_names('x','Time (sec)','y','Impulses/sec','color','Visual Stimulus');
g.set_title('Simult vs Adapted');
figure('Position',[292 76 429 734]);
g.draw();

set([g(1,1).results.stat_summary.line_handle],'LineWidth',3);
set([g(2,1).results.stat_summary.line_handle],'LineWidth',3);
set([g(3,1).results.stat_summary.line_handle],'LineWidth',3);




% % g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel);
% % g.axe_property('XLim',[-.050 .35]);
% % g.axe_property('YLim',[-60 40]);
% % g.geom_vline('xintercept',0)
% % 
% % g(1,1).stat_summary();
% % g(1,1).set_title('stat_summary()');
% % g(1,1).set_color_options('map','brewer2');
% % g(1,1).set_order_options('color',0);
% % g(1,1).geom_polygon('x',{[.05 .1 .1 .05] ; [.15 .25 .25 .15]} ,'y',{[-50 -50 30 30];  [-50 -50 30 30]},'color',[.5 .5 .5]);
% % g.geom_hline('yintercept',0)
% % 
% % 
% % g.set_names('x','Time (sec)','y','Impulses/sec','color','Visual Stimulus');g.set_title('Simult vs Adapted');
% % figure('Position',[292 260 1042 550]);
% % g.draw();
% % 
% % set([g.results.stat_summary.line_handle],'LineWidth',3);





end

