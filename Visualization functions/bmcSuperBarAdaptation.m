function bmcSuperBarAdaptation(IDX)


%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;


uctLength = length(IDX.allV1);

% B. pull out all laminar matrices 3x(6,450,el#)
%preallocate

% RESPout = nan(size(IDX.allV1(1).RESPout,1),size(IDX.allV1(1).RESPout,2),uctLength);
% dII = nan(size(IDX.allV1(1).dII,1),size(IDX.allV1(1).dII,2),uctLength);
% occ = nan(3,uctLength);
count = 0;
% loop uctLength
clear RESPout dII occ Xval Yval_simult Yval_adapted
for uct = 1:uctLength
     if IDX.allV1(uct).X.dianp(2) < 0.05 && IDX.allV1(uct).X.dianp(1) < 0.05 
         count = count + 1;
        RESPout(:,:,count) = IDX.allV1(uct).RESPout;
        dII(:,:,count) = IDX.allV1(uct).dII;
        occ(:,count)      = IDX.allV1(uct).occ(1:3);
        Xval(count)     = IDX.allV1(uct).occ(1);
        Yval_simult(count)     = IDX.allV1(uct).dII(1,3);
        Yval_adapted(count)     = IDX.allV1(uct).dII(2,3);
     end
     %resp dimension
%    50   100
%    150   250
%     50   250
%    -50     0
%            
end
clear IDX

% I need trans and sus error bars for the following:
% Fig 2. dCOS - monoc PS, binoc PS, dichop aerage between two (how do I do this?)
% Fig 3. IC DEPS, Binoc Simult cong, adapted flash, DE PS cong, adapted
% flash DE PS IC.
% 1. Monoc PS - 1
% 2. Binoc PS simult - 5
% 3. Average of two dichop simult - 7&8 (mean across the condition dimension...)
% 4. IC DE PS simult
% 5. adapted flash of PS to DE (PS, NDE adapted), congruent flash
% 6. adapted flash of PS to DE (NS, NDE adapted), IC flash

RESP_1(1,:,:) = squeeze(RESPout(1,:,:)); % 1. Monoc PS - 1
RESP_1(2,:,:) = squeeze(RESPout(5,:,:)); % 2. Binoc PS simult - 5
    allICRESP(1,:,:) = squeeze(RESPout(7,:,:));
    allICRESP(2,:,:) = squeeze(RESPout(8,:,:));
RESP_1(3,:,:) = squeeze(nanmean(allICRESP,1)); % 3. Average of two dichop simult - 7&8 (mean across the condition dimension...)
RESP_1(4,:,:) = squeeze(RESPout(7,:,:));% 4. IC DE PS simult
RESP_1(5,:,:) = squeeze(RESPout(10,:,:)); % 5. adapted flash of PS to DE (PS, NDE adapted), congruent flash
RESP_1(6,:,:) = squeeze(RESPout(18,:,:));

RESPall.transient = squeeze(RESP_1(:,1,:));
RESPall.sustained = squeeze(RESP_1(:,2,:));

% Preallocate
RESPavg.transient = nan(6,1);
RESPavg.sustained = nan(6,1);
hVal.transient = nan(5,1);
hVal.sustained = nan(5,1);
pVal.transient = nan(5,1);
pVal.transient = nan(5,1);

for i = 1:6
   RESPavg.transient(i,1) = nanmean(RESPall.transient(i,:),2); 
   RESPsdf.transient(i,1) = (nanstd(RESPall.transient(i,:),[],2)./sqrt(size(RESPall.transient,2)));
   RESPavg.sustained(i,1) = nanmean(RESPall.sustained(i,:),2);  
   RESPsdf.sustained(i,1) = (nanstd(RESPall.sustained(i,:),[],2)./sqrt(size(RESPall.sustained,2)));
end

dv = {[1 2],[2 3],[1 3],[2 4],[5 6]};
for j = 1:5
    [hVal.transient(j,1),pVal.transient(j,1)] = ttest(RESPall.transient(dv{j}(1),:),RESPall.transient(dv{j}(2),:));
    [hVal.sustained(j,1),pVal.sustained(j,1)] = ttest(RESPall.sustained(dv{j}(1),:),RESPall.sustained(dv{j}(2),:));  
end

% paired t-test. alpha .05, two tailed. 


%% dCOS - fig 2
figure

Y = [RESPavg.transient(1), RESPavg.transient(2), RESPavg.transient(3);
     RESPavg.sustained(1), RESPavg.sustained(2), RESPavg.sustained(3)];
E = [RESPsdf.transient(1), RESPsdf.transient(2), RESPsdf.transient(3);
     RESPsdf.sustained(1), RESPsdf.sustained(2), RESPsdf.sustained(3)];
C = [.8 .2 .2;
     .2 .2 .8];

a = pVal.transient(1);
b = pVal.transient(2); 
c = pVal.transient(3);
d = pVal.sustained(1);
e = pVal.sustained(2);
f = pVal.sustained(3);

 
P = [NaN    NaN    a      NaN     c      NaN ;
     NaN    NaN    NaN    d       NaN    f;
     a      NaN    NaN    NaN     b      NaN;
     NaN    d      NaN    NaN     NaN    e;
     c      NaN    b      NaN     NaN    NaN ;
     NaN    f      NaN    e       NaN    NaN];    

[hb, he, hpt, hpl, hpb] = superbar(Y, 'E', E, 'P', P, 'BarFaceColor', C);
xlim([0.5 2.5]);



%% 2x2 adapted vs simult fig 3

figure

Y = [RESPavg.transient(2), RESPavg.transient(4), RESPavg.transient(5), RESPavg.transient(6);
     RESPavg.sustained(2), RESPavg.sustained(4), RESPavg.sustained(5), RESPavg.sustained(6)];
E = [RESPsdf.transient(2), RESPsdf.transient(4), RESPsdf.transient(5), RESPsdf.transient(6);
     RESPsdf.sustained(2), RESPsdf.sustained(4), RESPsdf.sustained(5), RESPsdf.sustained(6)];
C = [.8 .2 .2;
     .2 .2 .8];
 
clear a b c d
a = pVal.transient(3);
b = pVal.transient(4); 
c = pVal.sustained(3);
d = pVal.sustained(4);

 
P = [NaN    NaN    a    NaN     NaN    NaN     NaN  NaN;
     NaN    NaN    NaN     b     NaN    NaN     NaN  NaN;
     a     NaN    NaN    NaN     NaN    NaN     NaN  NaN;
     NaN     b    NaN    NaN     NaN    NaN     NaN  NaN;
     NaN    NaN    NaN    NaN     NaN    NaN     c   NaN;
     NaN    NaN    NaN    NaN     NaN    NaN     NaN   d;
     NaN    NaN    NaN    NaN     c     NaN     NaN  NaN;
     NaN    NaN    NaN    NaN     NaN     d     NaN  NaN];

[hb, he, hpt, hpl, hpb] = superbar(Y, 'E', E, 'P', P, 'BarFaceColor', C);
xlim([0.5 2.5]);


end