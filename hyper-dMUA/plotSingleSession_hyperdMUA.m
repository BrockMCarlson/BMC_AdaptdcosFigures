% plotSingleSession_hyperdMUA
close all
clear

cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\HdMUA_test')
load('HdMUA.mat')

binTM = -50:5:295;
for i = size(STIM.depths,2):-1:1
    corticaldepths(i) = STIM.depths(i,2);
    
end

figure
imagesc(binTM,corticaldepths,HdMUA_DE);
colormap(gray)
vline(0)
set(gca,'YDir','normal')
title({'Dominant Eye Response','hyper-dMUA 5s bins','Threshold 15spks/s above baseline'})

figure
imagesc(binTM,corticaldepths,HdMUA_NDE);
colormap(gray)
vline(0)
set(gca,'YDir','normal')
title({'Non-Dominant Eye Response','hyper-dMUA 5s bins','Threshold 15spks/s above baseline'})

