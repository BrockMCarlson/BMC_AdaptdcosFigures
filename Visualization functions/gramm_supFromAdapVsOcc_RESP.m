function gramm_supFromAdapVsOcc_RESP(IDX)
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
% % % for tmBlock = 1:2
% % %        for uct = 1:uctLength
% % %            count = count + 1;       
% % %            % Categoricals - IVs
% % %            if tmBlock == 1
% % %                DataForVis.tmBlock{count,1} = 'Transient';
% % %            elseif tmBlock == 2
% % %                DataForVis.tmBlock{count,1} = 'Sustained';
% % %            end
% % % 
% % %            % DV - monocMinusAdapt
% % %            DataForVis.monocMinusAdapt(count,1) = ...
% % %                IDX.allV1(uct).RESP_avg{1}(tmBlock) - IDX.allV1(uct).RESP_avg{10}(tmBlock); 
% % % 
% % %            % DV - OCC
% % %            DataForVis.occ(count,1) = abs(IDX.allV1(uct).occ);
% % %            
% % %            if isnan(DataForVis.monocMinusAdapt(count,1))
% % %                count = count - 1;  %write over NaNs
% % %            end
% % % 
% % % 
% % % 
% % %        end
% % % end


for uct = 1:uctLength
   count = count + 1;       
   % Categoricals - IVs

   % DV - monocMinusAdapt
   DataForVis.monocMinusAdapt(count,1) = ...
       IDX.allV1(uct).RESP_avg{1}(3) - IDX.allV1(uct).RESP_avg{10}(3); 

   % DV - OCC
   DataForVis.occ(count,1) = abs(IDX.allV1(uct).occ);
   
   if isnan(DataForVis.monocMinusAdapt(count,1))
       count = count - 1;  %write over NaNs
   end

end



%% Gramm plots for vis repeated trajectories

clear g
g=gramm('x',DataForVis.occ,'y',DataForVis.monocMinusAdapt);
g.geom_point();
g.stat_glm();
g.set_names('x','occularity','y','Change in Response: Monoc - Adapted');
% g.axe_property('YLim',[-1 3]);




g.draw();






end

