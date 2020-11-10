function [CROPPED,TM] = cropDATA(DATA_fulltm,sdftm,sdfwin)
if size(DATA_fulltm,3) > 1
    error('cropping only works on one dimensional stimulus. In the past we had "padrows"')
    disp('archived')
    disp('    padrows = repmat(pad,size(condition,1),1); % pads with NANs if you are not in that condition any more. ')
    disp('    SDF = cat(2,SDF_fulltm(:, st : en,:), padrows);')
end
%% crop/pad SDF
% crop / pad SDF    

if sdftm(end) < sdfwin(2)  
    pad = [sdftm(end):diff(sdftm(1:2)):sdfwin(2)];
    pad(1) = [];
    en = length(sdftm);
    st = find(sdftm> sdfwin(1),1);
    sdftm = [sdftm pad];
    sdftm = sdftm(st : end);
    pad(:) = NaN;
    error('BMC - I have not padded anything before - double check that this is right')
else
    pad = [];
    en = find(sdftm > sdfwin(2),1)-1;
    st = find(sdftm > sdfwin(1),1);
    sdftm_cropped = sdftm(st : en);
end

    CROPPED = DATA_fulltm(:, st : en); 
    TM      = sdftm(1,st:en);
    if size(CROPPED,2) ~= length(sdftm_cropped)
        error('check tm')
    end









end