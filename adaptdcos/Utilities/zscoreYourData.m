%% Normalize SDF
    % out --> z-score, 
    % inputs --> baseline population mean, baselin population stdev,
    % SDF from binoc PS congruent simultaneous.

    %get inputs
        % Pull out baseline period
        % nota bene -- Exclude basline of suppressor trials later!! - cannot
        % do it on the squeeze line because index must be numeric.
        if isequal(win_ms(4,:),[-50 0])
            blDimension = 4;
        else
            error('RESP dimension issue. fix by programatically finding where the window is.')
        end    
        baselineAll = squeeze(matobj_RESP.RESP(e,blDimension,:));

        %bl pop average
        % Get min response (avg of baseline period for all non-suppressor trials)
        blAvg = nanmean(baselineAll(~STIM.suppressor,1));
 
        %bl pop stdev
        % Get min response (avg of baseline period for all non-suppressor trials)
        blStd = nanstd(baselineAll(~STIM.suppressor,1));
    
    % Z-score
    % ZscoreDat = (ContinuousData - popAvgOfBL)./popSTDOfBL
    SDF.zs = (SDF.raw - blAvg)./blStd;
    



    %% baseline correct SDF
clear cond
for cond = 1:size(conditions,1)
    sdfholder = SDF_crop{cond};
    respholder = RESP_alltrls{cond};
    SDF_blCor{cond} = sdfholder - respholder(4,:);
end