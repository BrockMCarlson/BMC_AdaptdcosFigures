global IDXDIR
cd(IDXDIR)
clear
close all
load('IDXforIOTana.mat')

for i = 1:30
    RESPmonoc(i,:) = IDX.allV1(i).RESP_avg{1};
    RESPIOT(i,:) = IDX.allV1(i).RESP_avg{2};
end
win_ms = [50,100;150,250;50,250;-50,0];

percentChange = (RESPmonoc(:,:) - RESPIOT(:,:))./RESPmonoc(:,:) * 100;

plot(percentChange(:,1))

    