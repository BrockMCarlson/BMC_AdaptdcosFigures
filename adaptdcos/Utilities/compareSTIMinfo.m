function [stmForAdap,stmForSupp] = compareSTIMinfo(STIM)
% compare stim inputs
clear count stmForAdap stmForSupp rowName

supTrls = [1554;1593;1660;1765;1767;1890;1926;2335;2378;2408;2785;2799;2861;3111;3145;3208;3329;3335;3391;3592;3652;3782;3857;3965;4023;4057];
adapTrls = supTrls - 1;

holder = STIM;
count = 0;
f = fieldnames(holder);
% stmForAdap = nan(35,2);
% stmForSupp = nan(35,2);
for i = 1:size(f,1)
    if size(holder.(f{i}),1) == 4203 && (isa(holder.(f{i}),'double') || isa(holder.(f{i}),'logical') )
        count = count+1;
        rowName{count,:} = f{i};
        stmForAdap{count,:} = holder.(f{i})(1553,:);
        stmForSupp{count,:} = holder.(f{i})(1554,:);
    end
end

end