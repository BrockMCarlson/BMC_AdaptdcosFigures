% visIDX_summaryPlot
clear
close all

flag_savefigs = 1;

IDXdir = 'G:\LaCie\Adaptdcos figs\adaptdcosCompareConditions';

IDXtextStr = 'IDX_FULLUnitAna.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = 'G:\LaCie\Adaptdcos figs';
figName = strcat('Summary_binary_bugFix.pdf'); 

   cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end


SupraCount = 0;
GranuCount = 0;
InfraCount = 0;
for uct = 1:uctLength
    if IDX(uct).depth(2) >5
        SupraCount = SupraCount+1;
        supraIDX_Subtraction(SupraCount,:,:)     = IDX(uct).Subtraction(:,:,1);
    elseif IDX(uct).depth(2) >= 0 && IDX(uct).depth(2) <= 5
        GranuCount = GranuCount + 1;
        granuIDX_Subtraction(GranuCount,:,:)     = IDX(uct).Subtraction(:,:,1);    
    elseif IDX(uct).depth(2) <= 0
        InfraCount = InfraCount + 1;
     	infraIDX_Subtraction(InfraCount,:,:)     = IDX(uct).Subtraction(:,:,1); 
    end

end
clear IDX

 % (cond x win x upOrDown) --- errorbars here?
S(:,:,1) = squeeze(sum(supraIDX_Subtraction > 0 ...
    & ~isnan(supraIDX_Subtraction)));
S(:,:,2) = squeeze(sum(supraIDX_Subtraction < 0 ...
    & ~isnan(supraIDX_Subtraction)));
G(:,:,1) = squeeze(sum(granuIDX_Subtraction > 0 ...
    & ~isnan(granuIDX_Subtraction)));
G(:,:,2) = squeeze(sum(granuIDX_Subtraction < 0 ...
    & ~isnan(granuIDX_Subtraction)));
I(:,:,1) = squeeze(sum(infraIDX_Subtraction > 0 ...
    & ~isnan(infraIDX_Subtraction)));
I(:,:,2) = squeeze(sum(infraIDX_Subtraction < 0 ...
    & ~isnan(infraIDX_Subtraction)));



for win = 1:3
    for condition = 1:8
        for updown = 1:2
            getThis.S = S(condition,win,updown);
            getThis.G = G(condition,win,updown);
            getThis.I = I(condition,win,updown);


                 PlotThis(win,condition,1,updown) = getThis.S;
                 PlotThis(win,condition,2,updown) = getThis.G;
                 PlotThis(win,condition,3,updown) = getThis.I;                             
          
        end
    end
end
        %%%%%% (win x condition x layer x updown)
  maxYval = max(max(max(max(PlotThis))));    
      
  conditionVec = {'9-5','10-5','11-6','12-6','13-7','14-7','15-8','16-8'};
  
 figure
 count = 0;
 clear condition win
for layer = 1:3
 for condition = 1:8
           count = count+1;
            s(count) = subplot(3,8,count);
            
            barGroup = squeeze(PlotThis(:,condition,layer,:));
            bar(barGroup)
            ylim([0 maxYval])
            
            if layer == 3
                xticklabels({'tr','su','FT'})
                xlabel(s(count),conditionVec{condition})
            else
                xticklabels('')
            end
 end
end
 
       ylabel(s(1),'Supra') 
       ylabel(s(9),'Gran') 
       ylabel(s(17),'Infra') 

       sgtitle({'Counts of units in each laminar compartment.',...
           'Half contrast. Subtraction.',...
           'Blue = # of units with stronger simult response.',...
           'Orange = # of units with stronger adapted resp.'},...
           'Interpreter','none')
       

