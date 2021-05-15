function X = diUnitTuning_BRFS(RESP,STIM,brfsfiles)

X = [];

if ~isequal(size(STIM.eye),size(RESP))
    error('pass resp for 1 channel and 1 window only')
end
if all(isnan(RESP))
    return
end



% Determin Neuron's Orientation Tuning
clear I varnames
I = (STIM.monocular | STIM.dioptic) ...
    & STIM.adapted == 0 ...
    & STIM.blank == 0 ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,brfsfiles);
varnames = {'eye';'tilt';'contrast';'sf';'phase';'xpos';'ypos';'diameter';'gabor'};
clear doesvary values temp
doesvary = true(size(varnames));
values = cell(size(varnames));
temp = nan(length(I),length(varnames));
for v = 1:length(varnames)
    x = STIM.(varnames{v})(I,1);
    if all(isnan(x)) || length(nanunique(x))==1
        doesvary(v) = false;
    else
        temp(:,v) = STIM.(varnames{v})(:,1);
        values{v} = (nanunique(x))';
    end
end
X.oriana = false;
X.ori(1,1:14) = NaN;
if any(strcmp(varnames(doesvary),'tilt'))
    values   = values(doesvary & ~strcmp(varnames,'tilt'));
    temp     = temp(:,doesvary & ~strcmp(varnames,'tilt'));
    clear combinations TRLS
    combinations = combvec(values{:})';
    TRLS = cell(size(combinations,1),3);
    for c = 1:size(combinations,1)
        trls = find(ismember(temp,combinations(c,:),'rows')');
        TRLS{c,1} = trls;
        TRLS{c,2} = length(unique(STIM.tilt( trls,1)));
        TRLS{c,3} = nanvar(RESP(trls));
    end
    TRLS = TRLS(cellfun(@(x) x>=5,TRLS(:,2)),:);
    if ~isempty(TRLS)
        if size(TRLS,1) > 1
            [~,mI]=max([TRLS{:,3}]);
            TRLS = TRLS(mI,:);
        end
        % test for a significant main effect of tilt, also find theta
        tilt_p = anovan(RESP(TRLS{1}),STIM.tilt(TRLS{1})','display','off');
        [u,theta] = grpstats(RESP(TRLS{1}),STIM.tilt(TRLS{1}),{'mean','gname'});
        theta = str2double(theta);
        % find peak theta,
        clear mi peak
        [~,mi]=max(u);
        peak = theta(mi);
        % reshape data so that peak is in middle
        clear x y grange
        x = wrapTo180([theta-peak theta-peak+180]);
        y = [u u];
        grange = find(x >= -90  & x <= 90) ;
        x = x(grange); y = y(grange);
        [x,idx] = sort(x); y = y(idx);
        
        % remove nan (helps with fitting)
        x(isnan(y)) = []; y(isnan(y)) = [];
        if ~isempty(y)
            if length(y) > 5
                % fit x and y with gauss, save gauss params
                clear gparam
                [gparam,gerror] = gaussianFit(x,y,false); % gparam = mu sigma A
                X.ori(1,1:8) = [tilt_p peak real(gparam') real(gerror')];
                % fit x and y with gauss2:
                %   f(x) =  a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-b2)/c2)^2)
                if length(y) > 6
                    f = fit(x,y,'gauss2');
                    X.ori(1,9:end) = [f.b1 f.c1 f.a1 f.b2 f.c2 f.a2]; %  mu sigma A
                end
            else
                % cannot fig gaus, but save peak
                X.ori(1,1:2) = [tilt_p peak];
            end
            
            % signal that oriana happened
            X.oriana = true;
        end
    end
end

% get occularity (2v3), looking across all files but
% balance all non-relevant conditions
clear I varnames
I = STIM.monocular ...
    & STIM.adapted == 0 ...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,brfsfiles);
varnames = {'tilt';'contrast';'sf';'phase';'xpos';'ypos';'diameter';'gabor'};
clear doesvary values temp
doesvary = true(size(varnames));
values = cell(size(varnames));
temp = nan(length(I),length(varnames));
for v = 1:length(varnames)
    x = STIM.(varnames{v})(I,1);
    if all(isnan(x)) || length(nanunique(x))==1
        doesvary(v) = false;
    else
        temp(:,v) = STIM.(varnames{v})(:,1);
        values{v} = (nanunique(x))';
    end
end
values   = values(doesvary);
temp     = temp(:,doesvary);
clear combinations TRLS
combinations = combvec(values{:})';
TRLS = cell(3,size(combinations,1));
for c = 1:size(combinations,1)
    for eye = 2:3
        TRLS{eye,c} = find(...
            I & STIM.eye == eye ...
            & ismember(temp,combinations(c,:),'rows'))';
    end
end
TRLS = TRLS(:,~all(cellfun(@isempty,TRLS)));
n = min(cellfun(@length,TRLS(2:3,:)));
if all(n==0)
    X.occana = 0;
    X.occ(1,1:9) = NaN;
else
    SUB = cell(size(TRLS));
    for c = 1:size(n,2)
        if n(c) > 0
            SUB{2,c} = randsample(TRLS{2,c},n(c));
            SUB{3,c} = randsample(TRLS{3,c},n(c));
        else
            SUB{2,c} = [];
            SUB{3,c} = [];
        end
    end
    clear occ
    % occ(1:3) sub selected AND balanced
    occ(3) =  (nanmean(RESP(cell2mat(SUB(2,:)))) - nanmean(RESP(cell2mat(SUB(3,:)))) )...
        ./ (nanmean(RESP(cell2mat(SUB(2,:)))) + nanmean(RESP(cell2mat(SUB(3,:)))) ) ;
    [~,p,~,stats]=ttest2(RESP(cell2mat(SUB(2,:))),RESP(cell2mat(SUB(3,:))));
    occ(2) = stats.tstat;
    occ(1) = p;
    % occ(4:6) sub selected, NOT balanced
    occ(6) =  (nanmean(RESP(cell2mat(TRLS(2,:)))) - nanmean(RESP(cell2mat(TRLS(3,:)))) )...
        ./ (nanmean(RESP(cell2mat(TRLS(2,:)))) + nanmean(RESP(cell2mat(TRLS(3,:)))) ) ;
    [~,p,~,stats]=ttest2(RESP(cell2mat(TRLS(2,:))),RESP(cell2mat(TRLS(3,:))));
    occ(5) = stats.tstat;
    occ(4) = p;
    % occ(7:9) NOT sub selected
    occ(9) =  (nanmean(RESP(I & STIM.eye == 2)) - nanmean(RESP(I & STIM.eye == 3)) )...
        ./ (nanmean(RESP(I & STIM.eye == 2)) + nanmean(RESP(I & STIM.eye == 3)) ) ;
    [~,p,~,stats]=ttest2(RESP(I & STIM.eye == 2),RESP(I & STIM.eye == 3));
    occ(8) = stats.tstat;
    occ(7) = p;
    X.occana = 1;
    X.occ = occ;

    % Note, eye = 2 signifies IPSI , 3 signifies CONTRA
    % so contrasts are IPSI - CONTRA; (contra dom = negative nubmer)
    
    
end


% get BINOCULARITY, looking across all files but
% balance all non-relevant conditions
clear I varnames
I = (STIM.monocular | STIM.dioptic) ...
    & STIM.adapted == 0 ...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,brfsfiles);
varnames = {'eye';'tilt';'contrast';'sf';'phase';'xpos';'ypos';'diameter';'gabor'};
clear doesvary values temp
doesvary = true(size(varnames));
values = cell(size(varnames));
temp = nan(length(I),length(varnames));
for v = 1:length(varnames)
    x = STIM.(varnames{v})(I,1);
    if all(isnan(x)) || length(nanunique(x))==1
        doesvary(v) = false;
    else
        temp(:,v) = STIM.(varnames{v})(:,1);
        values{v} = (nanunique(x))';
    end
end
if ~any(strcmp(varnames(doesvary),'eye')) ...
        || ~isequal(values{strcmp(varnames,'eye')},[1 2 3])
    X.bio(1,1:6) = NaN;
else
    values   = values(doesvary);
    temp     = temp(:,doesvary);
    varnames = varnames(doesvary);
    clear combinations TRLS TILTS
    combinations = combvec(values{:})';
    TRLS  = cell(3,size(combinations,1));
    TILTS = cell(1,size(combinations,1));
    for c = 1:3:size(combinations,1)
        % only want BI if there are coresponding monocular conditions
        clear n
        n = [...
            sum(ismember(temp,combinations(c+0,:),'rows'))
            sum(ismember(temp,combinations(c+1,:),'rows'))
            sum(ismember(temp,combinations(c+2,:),'rows'))];
        if ~any(n==0)
            for eye = 1:3
                TRLS{eye,c} = find(ismember(temp,combinations(c+eye-1,:),'rows'))';
            end
            TILTS{1,c} = combinations(c+eye-1,strcmp(varnames,'tilt'));
        end
    end
    TRLS  = TRLS(:,~all(cellfun(@isempty,TRLS)));
    TILTS = TILTS(:,~all(cellfun(@isempty,TRLS)));
    if isempty(TRLS)
        X.bio(1,1:6) = NaN;
    else
        n = min(cellfun(@length,TRLS(1:3,:)));
        SUB = cell(size(TRLS));
        for c = 1:size(n,2)
            SUB{1,c} = randsample(TRLS{1,c},n(c));
            SUB{2,c} = randsample(TRLS{2,c},n(c));
            SUB{3,c} = randsample(TRLS{3,c},n(c));
        end
        % determin preffered eye
        clear d PE
        d = diff([nanmean(RESP(cell2mat(SUB(2,:))))  nanmean(RESP(cell2mat(SUB(3,:))))]);
        if d > 0
            PE = 3;
        else
            PE = 2;
        end
        clear bio
        % bio(1:3) sub selected AND balanced
        bio(3) =  (nanmean(RESP(cell2mat(SUB(1,:)))) - nanmean(RESP(cell2mat(SUB(PE,:)))) )...
            ./ (nanmean(RESP(cell2mat(SUB(1,:)))) + nanmean(RESP(cell2mat(SUB(PE,:)))) ) ;
        [~,p,~,stats]=ttest2(RESP(cell2mat(SUB(1,:))),RESP(cell2mat(SUB(PE,:))));
        bio(2) = stats.tstat;
        bio(1) = p;
        % bio(4:6) sub selected, NOT balanced
        bio(6) =  (nanmean(RESP(cell2mat(TRLS(1,:)))) - nanmean(RESP(cell2mat(TRLS(PE,:)))) )...
            ./ (nanmean(RESP(cell2mat(TRLS(1,:)))) + nanmean(RESP(cell2mat(TRLS(PE,:)))) ) ;
        [~,p,~,stats]=ttest2(RESP(cell2mat(TRLS(1,:))),RESP(cell2mat(TRLS(PE,:))));
        bio(5) = stats.tstat;
        bio(4) = p;
        X.bio = bio;
        % quick check if a "full" bonocularity analysis can be done
        if length(unique(cell2mat(TILTS))) > 5
            X.occana = 2;
        end
    end
end
    
% Monocular conditions from di task
X.diana   = false;
X.diang   = {'eye','tilt','contrast'};
X.dianp   = nan(1,3);
X.dipref  = [NaN NaN];
X.dinull  = [NaN NaN];
X.dicontrasts = [];
X.diori       = [];

% get ori and contrasts, regardless of monocular status
clear uContrast
uContrast = unique(STIM.contrast(STIM.ditask & ~STIM.motion & ~STIM.cued,:));
uContrast(uContrast==0) = [];
X.dicontrasts = uContrast';
clear diori
diori = nanunique(STIM.tilt(STIM.ditask & ~STIM.motion & ~STIM.cued,:));
X.diori = diori';

% Monocular CRF
clear I
I = STIM.monocular...
    & STIM.ditask...
    & STIM.adapted == 0 ...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,brfsfiles);
if any(I)
    
    clear M gname group
    M = nan(2,2,length(uContrast));
    
    % look for monocular conditions in task
     %everything is in second column bc BRFS format is [adapter STIM.suppressor]
    for eye = 2:3
        for ori = 1:2
            for cnt = 1:length(uContrast)
                M(eye-1,ori,cnt) = nanmean(RESP(I & STIM.eye == eye & STIM.tilt(:,1) == diori(ori) & STIM.contrast(:,1) == uContrast(cnt)));
            end
        end
    end
    M(:,:,any(squeeze(any(isnan(M),2)) | squeeze(any(isnan(M),1)))) = [];
    
    M = nanmean(M,3);
    
    TheMonocularProblemExistsHere
    
    clear prefeye nulleye prefori prefori
    if ~(isempty(M) || any(any(isnan(M))))
        X.diana = 1;
        % monocular data from ditask is complete
        % so, check for significant main effects of EYE and ORI
        gname = X.diang;
        group = cell(1,length(gname));
        for g = 1:length(gname)
            group{g} = STIM.(gname{g})(I,1);
        end
        clear anp
        anp = anovan(RESP(I),group,'varnames',gname,'display','off');
        X.dianp(1:3) = anp(1:3); 
        
        % find pref eye and ori
        clear eidx oidx prefeye nulleye prefori nullori
        [eidx, oidx] = find(M(:,:,end) == max(max((M))));
        prefeye = eidx(1)+1;
        if prefeye == 2
            nulleye = 3;
        else
            nulleye = 2;
        end
        prefori = diori(oidx(1));
        nullori = diori(diori~=prefori);
        
        X.dipref  = [prefeye prefori];
        X.dinull  = [nulleye   nullori];
    end
end

if all(isnan(X.dipref)) && X.oriana && X.occana > 0
    % can recover pref from tuning data
    if X.occ(2) > 0
        prefeye = 2;
        nulleye = 3;
    else
        prefeye = 3;
        nulleye = 2;
    end
    deltaori = abs([diori,diori+180] - X.ori(2));
    [a,~]=find(deltaori == min(min(deltaori)));
    if ~(length(a)>1 && diff(a) ~= 0)
        
        prefori = diori(a(1));
        nullori = diori(diori~=prefori);
        
        X.dipref  = [prefeye prefori];
        X.dinull  = [nulleye   nullori];
        
    end
end
    


    

