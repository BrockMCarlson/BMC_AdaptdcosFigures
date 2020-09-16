%diIDX_2x2
%Simply find preferred eye and orientation for each unit

% Desired output ---> 
%   SDF of 4x350 (PSxDE,NSxDE,PSxNDE,NSxNDE)
%   Pref Ori
%   Null Ori
%   Dom Eye
%   Non-Dom Eye

clear

didir = 'G:\LaCie\diSTIM_Sep23\';
list    = dir([didir  '*_AUTO.mat']);
flag_saveIDX = 1;
saveName = '2x2IDX';


sdfwin  = [-0.05 0.3]; %s
statwin = [0.15 0.25; .05 .10]; %s
Fs = 1000;

clear IDX
uct = 0;

%% For loop
for i = 1:length(list)

    % load session data
    clear penetration
    penetration = list(i).name(1:11); 
    
    clear STIM nel difiles
    load([didir penetration '.mat'],'STIM')
    nel = length(STIM.el_labels);
    difiles = unique(STIM.filen(STIM.ditask));
    
    
    % % % % % % % %     for kls = 0:1 %%%%KLS Loop removed for now.
    kls = 0;
    clear matobj win_ms
    if kls == 1
        matobj = matfile([didir penetration '_KLS.mat']);
    else
        matobj = matfile([didir penetration '_AUTO.mat']);
    end
    win_ms = matobj.win_ms;
    if isequal(win_ms(3,:),[50 250])
        respDimension = 3;
    elseif isequal(win_ms(4,:),[50 250])
        respDimension = 4;
    else
        error('RESP dimension issue')
    end

    for e = 1:nel
% Track progress
disp(uct)
tic
        
        
        
        clear *RESP* *SDF* sdf sdftm X M TRLS SUB 
        RESP = squeeze(matobj.RESP(e,respDimension,:));

        % get "goodfiles" for each cluster
        % i.e., the files over which the cluster is present
        % pref for ditasks if there are more than 1 set of clusters at depth
        % DEV:  should be able to scrape more from
        %       STIM.rclusters, and non-used STIM.clusters
        clear goodfiles allfiles
        allfiles = 1:length(STIM.filelist);
        if ~kls
            goodfiles = allfiles;
        else
            goodfiles = find(~isnan(STIM.clusters(e,:)));
            if isempty(goodfiles)
                continue
            elseif ~isequal(goodfiles,allfiles)...
                    && length(goodfiles)>1 ...
                    && any(diff(goodfiles) > 1)
                goodfiles = unique(STIM.filen(ismember(STIM.filen, goodfiles) & STIM.ditask));
            end
        end
        if any(diff(goodfiles) > 1)
            %error('check goodfiles')
            continue %DEV: need to figure out a way to slavage
        end

        % Determin Neuron's Orientation Tuning
        clear I varnames
        I = (STIM.monocular | STIM.dioptic) ...
            & STIM.adapted == 0 ...
            & STIM.blank == 0 ...
            & STIM.rns == 0 ...
            & STIM.cued == 0 ...
            & STIM.motion == 0 ...
            & ismember(STIM.filen,goodfiles);
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
        X.ori(1,1:14) = NaN;
        X.oriana = false;
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

                if ~isempty(y) && size(y,1)>2
                    % fit x and y with gauss, save gauss params
                    clear gparam                   
                    [gparam,gerror] = gaussianFit(x,y,false); % gparam = mu sigma A
                    X.ori(1,1:8) = [tilt_p peak real(gparam') real(gerror')];
                    % fit x and y with gauss2:
                    %   f(x) =  a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-b2)/c2)^2)
                    try
                        f = fit(x,y,'gauss2');
                        X.ori(1,9:end) = [f.b1 f.c1 f.a1 f.b2 f.c2 f.a2]; %  mu sigma A
                    end
                end

                % signal that oriana happened
                X.oriana = true;

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
            & ismember(STIM.filen,goodfiles);
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
            X.occ(1,1:9) = NaN;
            X.occana = 0;
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
            X.occ = occ;
            X.occana = 1;

            % Note, eye = 2 signifies IPSI , 3 signifies CONTRA
            % so contrasts are IPSI - contra; (contra dom = negative nubmer)
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
            & ismember(STIM.filen,goodfiles);
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


        % DRFT tuning
        clear I gname group remove
        X.f0 = nan(1,1); X.fnot = nan(1,1);
        I = STIM.motion ~= 0;
        if any(I)
            I = find(I);

            clear PSTH psthtm ;
            PSTH = squeeze(matobj.PSTH(e,:,I));
            psthtm = matobj.psthtm;

            clear drftwin Fs
            Fs=30000;
            drftwin = [0.2 min(diff(STIM.tp_sp(I,:),[],2))/Fs];

            clear tf tI
            tf = unique(STIM.tf(I));
            if length(tf)>1
                tf = max(tf);
                tI = STIM.tf(I) == tf;
            else
                tI = true(size(I));
            end

            tmidx = psthtm >= drftwin(1) &  psthtm < drftwin(2);

            clear dat p *sig_* u theta g psth
            dat  = squeeze(nanmean(PSTH(tmidx,tI),2));
            if ~all(dat == 0) && ~all(isnan(dat))
                psth = (PSTH(tmidx,tI));
                q80  = quantile(dat,[.8]);
                psth = psth(:,dat>=q80);
                psth(isnan(psth)) = 0;
                [X.f0(1,:)  ,~, ~] = ratio_ftf_f0(psth,1/diff(psthtm(1:2)),tf);
                [X.fnot(1,:),~, ~] = ratio_ftf_fnot(psth,1/diff(psthtm(1:2)),tf);
            end
        end

        %%
        % DI TASK ANALYSIS
        clear nSDF nTM prefeye prefori anp CRF stimcontrast
        nSDF    = nan(12,diff(sdfwin)*1000);
        nSDF_adapt = nan(12,diff(sdfwin)*1000);
        nTM     = nan(1,diff(sdfwin)*1000);
        nTM_adapt     = nan(1,diff(sdfwin)*1000);
        prefeye = NaN;
        prefori = NaN;
        anp     = nan(3,1);
        distats = nan(24,1);
        diana   = 0;
        CRF     = [];
        stimcontrast = [NaN NaN];

        % static DITASK analysis
        clear I
        I =  STIM.ditask...
            & STIM.adapted == 0 ...
            & ~STIM.blank ...
            & STIM.rns == 0 ...
            & STIM.cued == 0 ...
            & STIM.motion == 0 ...
            & ismember(STIM.filen,goodfiles);

        if any(I)
            % determin main contrasts levels
            clear uContrast contrast_*
            uContrast = unique(STIM.contrast(I,:));
            uContrast(uContrast==0) = [];
            contrast_max = max(uContrast);
            [~,idx] = min(abs(uContrast - contrast_max/2));
            contrast_half   = uContrast(idx);
            % determin dioptic contrasts
            clear diori
            diori = nanunique(STIM.tilt(I,:));

            % Monocular CRF
            clear M
            M = nan(2,2,length(uContrast));
            clear I gname group
            I = STIM.monocular...
                & STIM.ditask...
                & STIM.adapted == 0 ...
                & ~STIM.blank ...
                & STIM.rns == 0 ...
                & STIM.cued == 0 ...
                & STIM.motion == 0 ...
                & ismember(STIM.filen,goodfiles);
            if any(I)
                % look for monocular conditions in task
                for eye = 2:3
                    for ori = 1:2
                        for cnt = 1:length(uContrast)
                            M(eye-1,ori,cnt) = nanmean(RESP(I & STIM.eye == eye & STIM.tilt(:,1) == diori(ori) & STIM.contrast(:,1) == uContrast(cnt)));
                        end
                    end
                end
                M(:,:,any(squeeze(any(isnan(M),2)) | squeeze(any(isnan(M),1)))) = [];
            end
            M = nanmean(M,3);

            clear prefeye nulleye prefori prefori
            if isempty(M) || any(any(isnan(M)))
                % monocular data from ditask is *INcomplete*
                if X.oriana && X.occana > 0
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
                    if length(a)>1 && diff(a) ~= 0
                        prefeye = NaN;
                        prefori = NaN;
                    else
                        prefori = diori(a(1));
                        nullori = diori(diori~=prefori);
                    end
                else
                    prefeye = NaN;
                    prefori = NaN;
                end

            else
                % monocular data from ditask is complete
                % so, check for significant main effects of EYE and ORI
                gname = {'eye','tilt','contrast'};
                group = cell(1,length(gname));
                for g = 1:length(gname)
                    group{g} = STIM.(gname{g})(I,1);
                end
                clear anp
                anp = anovan(RESP(I),group,'varnames',gname,'display','off');

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
            end

            if ~isnan(prefeye)

                % sort data so that they are [prefeye nulleye]
                clear eyes sortidx contrasts tilts
                eyes      = STIM.eyes;
                contrasts = STIM.contrast;
                tilts     = STIM.tilt;
                if prefeye == 2
                    [eyes,sortidx] = sort(eyes,2,'ascend');
                else
                    [eyes,sortidx] = sort(eyes,2,'descend');
                end
                for w = 1:length(eyes)
                    contrasts(w,:) = contrasts(w,sortidx(w,:)); % sort contrasts in dominant eye and non-dominant eye
                    tilts(w,:)     = tilts(w,sortidx(w,:));
                end; clear w

    %%%%%%%%%%%%%%%%%%%%%%
      % MAC origional - pulling out simultaneous trials. line 483-6??


                    clear I
                    I = STIM.ditask...
                        & STIM.adapted == 0 ...
                        & ~STIM.blank ...
                        & STIM.rns == 0 ...
                        & STIM.cued == 0 ...
                        & STIM.motion == 0 ...
                        & ismember(STIM.filen,goodfiles); % things that should be included. We want to get STIM adapted too.

                % analyze by DI condition
                clear sdftm dicond SDF aSDF rSDF dSDF sdf
                sdf   = squeeze(matobj.SDF(e,:,:)); % load for just that channel from the matobj
                sdftm =  matobj.sdftm;
                dicond = {'Monocular','Binocular','dCOS'};
                stimcontrast = [contrast_max contrast_half];
                sdfct = 0; rSDF = nan(6,length(sdftm));
                for c = 1:2 % gets out contrast max and contrast half in the preferred eye.
                    for di = 1:3
                        sdfct = sdfct +1;
                        clear trls
                        switch dicond{di}           % Find the trials you want to look at
                            case 'Monocular'
                                trls = I &...
                                    STIM.eye == prefeye & ...
                                    STIM.tilt(:,1) == prefori & ...
                                    STIM.contrast(:,1) == stimcontrast(c) & ...
                                    STIM.monocular;  
                            case 'Binocular'
                                trls = I &...
                                    tilts(:,1) == prefori & ...
                                    tilts(:,2) == prefori & ...
                                    contrasts(:,1) == stimcontrast(c) & ...
                                    contrasts(:,2) == contrast_max;   % Contrast max is always in the non-dominant eye.
                            case 'dCOS'
                                trls = I &...
                                    tilts(:,1) == prefori & ...
                                    tilts(:,2) == nullori & ...
                                    contrasts(:,1) == stimcontrast(c) & ...
                                    contrasts(:,2) == contrast_max;
                        end
                        if sum(trls) >= 5                               % more than 5 traisl and not nans. Dont have it be empty everything is the same size
                            rSDF(sdfct,:)   = nanmean(sdf(:,trls),2);
                            diRESP{sdfct,1} = nanmean(sdf(sdftm >= statwin(1,1) & sdftm <= statwin(1,2),trls),1);
                            diRESP{sdfct,2} = nanmean(sdf(sdftm >= statwin(2,1) & sdftm <= statwin(2,2),trls),1);
                        else
                            rSDF(sdfct,:)   = nan(size(sdf,1),1);
                            diRESP{sdfct,1} = nan;
                            diRESP{sdfct,2} = nan; 
                        end


                    end   %%% SDFcount is at 6 after this loop
                end


                % Add ND monocular conditions
                clear nde_prefori
                    nde_prefori = I &...    
                        STIM.eye == nulleye & ...
                        STIM.tilt(:,1) == prefori & ...
                        STIM.contrast(:,1) == contrast_max & ...
                        STIM.monocular;
                if sum(nde_prefori) >= 5
                    rSDF(7,:) = nanmean(sdf(:,nde_prefori),2);
                else
                    rSDF(7,:) = nan(size(sdf,1),1);
                end

                clear nde_nullori
                    nde_nullori = I &...
                        STIM.eye == nulleye & ...
                        STIM.tilt(:,1) == nullori & ...
                        STIM.contrast(:,1) == contrast_max & ...
                        STIM.monocular;
                if sum(nde_nullori) >= 5
                    rSDF(8,:) = nanmean(sdf(:,nde_nullori),2);    %%%% Here we are adding things for the non-dominant eye.
                else
                    rSDF(8,:) = nan(size(sdf,1),1);
                end


                % tests

                    clear ttp stats distats
                    for w = 1:2                 %ttests done on two windows, 123 - first contrast -- 456 - second contrast in the DELTA
                        % 1 = M; 2 = B; 3 = D; 
                        [~,ttp(1,w),~,stats(1,w)]=ttest2(diRESP{2,w},diRESP{1,w});
                        [~,ttp(2,w),~,stats(2,w)]=ttest2(diRESP{3,w},diRESP{1,w});
                        [~,ttp(3,w),~,stats(3,w)]=ttest2(diRESP{2,w},diRESP{3,w});
                        % 4 = M; 5 = B; 6 = D; 
                        [~,ttp(4,w),~,stats(4,w)]=ttest2(diRESP{5,w},diRESP{4,w});
                        [~,ttp(5,w),~,stats(5,w)]=ttest2(diRESP{6,w},diRESP{4,w});
                        [~,ttp(6,w),~,stats(6,w)]=ttest2(diRESP{5,w},diRESP{6,w});
                    end
                    distats = [[stats(:,1).tstat] ttp(:,1)' [stats(:,2).tstat] ttp(:,2)' ]';




                % delta
                dSDF = nan(4,length(sdftm));
                dSDF(1,:) = rSDF(2,:) - rSDF(1,:);   % Subtracting the conditions
                dSDF(2,:) = rSDF(3,:) - rSDF(1,:);
                dSDF(3,:) = rSDF(5,:) - rSDF(4,:);
                dSDF(4,:) = rSDF(6,:) - rSDF(4,:);
                % combined
                clear SDF
                SDF = cat(1,rSDF,dSDF);

                % crop / pad SDF
                clear tm pad st en
                tm = sdftm;
                if tm(end) < sdfwin(2)   % Make sure the SDF is the same across all of the sessions. I may want to change this. change sdfwin to be -100 to 800 ??? 
                    pad = [tm(end):diff(tm(1:2)):sdfwin(2)];
                    pad(1) = [];
                    en = length(tm);
                    st = find(tm> sdfwin(1),1);
                    tm = [tm pad];
                    tm = tm(st : end);
                    pad(:) = NaN;
                else
                    pad = [];
                    en = find(tm > sdfwin(2),1)-1;
                    st = find(tm > sdfwin(1),1);
                    tm = tm(st : en);
                end
                pad = repmat(pad,size(SDF,1),1); % pads with NANs if you are not in that condition any more. 

                    clear nSDF nTM
                    nSDF = cat(2,SDF(:, st : en), pad); clear SDF
                    if size(nSDF,2) ~= length(tm)
                        error('check tm')
                    end
                    nTM = tm;


    %%%%%%%%%%%%%
    % END MAC origional code from line 482.
    % Out of this I need to pull nSDF and nTM. nTM and nSDF go
    % into the final IDX variable, but SDF will have to be edited so
    % that it works with aSDF down lower


        % CRF Analysis - added Oct 3                                    % Brock you can skip this.

                % monocular 
                CRF = nan(3+length(uContrast),length(uContrast));
                CRF(1,:) = uContrast;
                clear iI uu* nn gname
                iI = I & STIM.monocular & STIM.tilt(:,1)==prefori;
                [uu, nn, gname] = grpstats(RESP(iI),{STIM.eye(iI),STIM.contrast(iI,1)},{'mean','numel','gname'});
                uu(nn<5) = nan; 
                uueye = str2double(gname(:,1));
                uucon = str2double(gname(:,2));
                for eye = 2:3
                    for c = 1:length(uContrast)
                        idx = uueye == eye & ...
                            uucon == uContrast(c); 
                        if any(idx)
                            CRF(eye,c) = uu(idx); 
                        end
                    end
                end
                if prefeye == 2
                    CRF(2:3,:) = flipud(CRF(2:3,:));
                end
                %binocular
                for de = 1:length(uContrast)
                    for nde = 1:length(uContrast)
                        trls = I &...
                            tilts(:,1) == prefori & ...
                            tilts(:,2) == prefori & ...
                            contrasts(:,1) == uContrast(de) & ...
                            contrasts(:,2) == uContrast(nde);
                        if sum(trls) >= 5
                            CRF(3+nde,de) = nanmean(RESP(trls));
                        end
                    end
                end

                if any(any(nSDF))
                    diana = 1;
                end
            end
        end

        % attention task
        attnana = 0;
        redun   = NaN; 
        aSDF = nan(12,diff(sdfwin)*1000);
        attnp = nan(3,1);
        aa    = nan(4,1); 
        attnstats = nan(6,1);
        attncontrast = [NaN NaN]; 

        I = STIM.ditask...
            & STIM.adapted == 0 ...
            & ~STIM.blank ...
            & STIM.rns == 0 ...
            & STIM.cued ~= 0 ... !!!!!!!!!
            & STIM.motion == 0 ...
            & ismember(STIM.filen,goodfiles);

        if any(I)

            if any(strcmp(STIM.paradigm,'rsvp_redun'))
                redun = 1; 
            else
                redun = 0; 
            end

            % quick monocualt test for main effects of each
            % eye, tilt, contrast, attn
            aI = STIM.monocular & ...
                STIM.cued ~= 0 & ...
                ismember(STIM.filen,goodfiles);
            grp =  {...
                STIM.eye(aI,1),...
                STIM.tilt(aI,1),...
                STIM.contrast(aI,1),...
                STIM.cued(aI)};
            gname  = grpstats(RESP(aI),grp,{'gname'});
            gname = str2double(gname); 
            gcheck = any(diff(gname) ~= 0);

            % check stim
            if redun
                % check that contrasts are all the same
                % but that everything else differs
                % making an assumption here!
                if ~isequal(gcheck,[1 1 0 1])
                    continue
                end
            else
                % again, checking asumptions
                % there should be 2 contrasts only, 
                % and they should be fixed by eye
                if ~isequal(gcheck,[1 1 1 1]) ...
                        || sum(diff(gname(:,3)) ~= 0) ~= 1
                    ahahahaha
                end
            end

            % moncoular anova 
            clear aa
            aa = anovan(RESP(aI),grp,'display','off');

            % determin prefeye and prefori
            if redun
                % never collected another ditask w/ redun, see DataLog
                % must do monocular analysis w/in attention task
                % to determin prefeye and prefori

                % group mean acors eye and ori to determim pref
                clear uu eyeori mm
                [uu, eyeori]=grpstats(RESP(aI),grp(1:2),{'mean','gname'});
                eyeori = str2double(eyeori); 
                [~,mm]= max(uu);

                prefeye = eyeori(mm,1);
                if prefeye == 2
                    nulleye = 3;
                else
                    nulleye = 2;
                end
                prefori = eyeori(mm,2);
                nullori = unique(eyeori(eyeori(:,2) ~= prefori,2)); 

            else

                % get pref eye and ori for analysis
                % DO NOT LOOK AT ATTENTION TASK DATA FOR 
                % non-redun "COLOR" task 
                if isnan(prefeye)
                    if X.oriana > 1 && X.occana > 0
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
                        prefori = diori(a);
                        nullori = diori(diori~=prefori);
                    end
                end
            end

            if ~isnan(prefeye)
                % sort data so that they are [prefeye nulleye]
                clear contrasts tilts eyes
                if prefeye == 2
                    [eyes,sortidx] = sort(STIM.eyes,2,'ascend');
                else
                    [eyes,sortidx] = sort(STIM.eyes,2,'descend');
                end
                for w = 1:length(eyes)
                    contrasts(w,:) = STIM.contrast(w,sortidx(w,:));
                    tilts(w,:)     = STIM.tilt(w,sortidx(w,:));
                end; clear w

                % load sdf if not already
                if ~exist('sdf','var')
                    sdf   = squeeze(matobj.SDF(e,:,:));
                    sdftm =  matobj.sdftm;
                end

                clear mI mctr
                mI = STIM.eye == prefeye & ...
                    STIM.tilt(:,1) == prefori & ...
                    STIM.monocular & ...
                    STIM.cued ~= 0 & ...
                    ismember(STIM.filen,goodfiles);
                mctr = [nanunique(contrasts(mI,1)) nanunique(contrasts(mI,2))];

                clear bI bctr
                bI = all(tilts == prefori,2) & ...
                    ~any(contrasts == 0,2) & ...
                    STIM.cued ~= 0 & ...
                    ismember(STIM.filen,goodfiles);
                bctr = [nanunique(contrasts(bI,1)) nanunique(contrasts(bI,2))];

                clear dI dctr
                dI = STIM.tiltmatch == 0 & ...
                    ~any(contrasts == 0,2) & ...
                    STIM.cued ~= 0 & ...
                    tilts(:,1) == prefori & ...
                    ismember(STIM.filen,goodfiles);
                dctr = [nanunique(contrasts(dI,1)) nanunique(contrasts(dI,2))];

                if ~isequal(bctr,dctr) || ...
                        diff(dctr) < 0  || ...
                        mctr(1) ~= bctr(1)
                    continue
                else
                    attncontrast = dctr; 
                end


                %ANOVA
                clear dat cued stim attnp n
                dat = [...
                    RESP(STIM.cued ==  1 & mI);...
                    RESP(STIM.cued == -1 & mI);...
                    RESP(STIM.cued ==  1 & bI);...
                    RESP(STIM.cued == -1 & bI);...
                    RESP(STIM.cued ==  1 & dI);...
                    RESP(STIM.cued == -1 & dI)];
                n = [...
                    sum(STIM.cued ==  1 & mI);...
                    sum(STIM.cued == -1 & mI);...
                    sum(STIM.cued ==  1 & bI);...
                    sum(STIM.cued == -1 & bI);...
                    sum(STIM.cued ==  1 & dI);...
                    sum(STIM.cued == -1 & dI)];
                cued = ones(size(dat));
                cued(sum(n(1:1))+1:sum(n(1:1))+n(2)) = -1;
                cued(sum(n(1:3))+1:sum(n(1:3))+n(4)) = -1;
                cued(sum(n(1:5))+1:sum(n(1:5))+n(6)) = -1;
                stim = ones(size(dat));
                stim(sum(n(1:2))+1:sum(n(1:2))+n(3)) = 2;
                stim(sum(n(1:3))+1:sum(n(1:3))+n(4)) = 2;
                stim(sum(n(1:4))+1:sum(n(1:4))+n(5)) = 3;
                stim(sum(n(1:5))+1:sum(n(1:5))+n(6)) = 3;
                attnp = anovan(dat,{cued stim},'display','off','model','full');

                % matching attention neutral conditions
                clear mmI
                mmI = STIM.eye == prefeye & ...
                    STIM.tilt(:,1) == prefori & ...
                    STIM.contrast(:,1) == mctr(1) & ...
                    STIM.monocular & ...
                    STIM.cued == 0 & ... !!!!!
                    ~STIM.blank & ...
                    STIM.rns == 0 & ...
                    STIM.motion == 0 & ...
                    STIM.adapted == 0 & ...
                    ismember(STIM.filen,goodfiles);

                clear bbI
                bbI = all(tilts == prefori,2) & ...
                    contrasts(:,1) == bctr(1) & ...
                    contrasts(:,2) == bctr(2) & ...
                    STIM.cued == 0 & ... !!!!!
                    ~STIM.blank & ...
                    STIM.rns == 0 & ...
                    STIM.motion == 0 & ...
                    STIM.adapted == 0 & ...
                    ismember(STIM.filen,goodfiles);

                clear ddI
                ddI = STIM.tiltmatch == 0 & ...
                    tilts(:,1) == prefori & ...
                    contrasts(:,1) == dctr(1) & ...
                    contrasts(:,2) == dctr(2) & ...
                    STIM.cued == 0 & ... !!!!!
                    ~STIM.blank & ...
                    STIM.rns == 0 & ...
                    STIM.motion == 0 & ...
                    STIM.adapted == 0 & ...
                    ismember(STIM.filen,goodfiles);

                % trial data for ttest later
                atRESP = cell(3,2);
                atRESP(:,:) = {nan};

                % SDFs / RESP
                clear msdf
                msdf = nan(3,size(sdf,1));
                if sum(mI & STIM.cued ==  1) >= 5
                    msdf(1,:)   = nanmean(sdf(:,mI & STIM.cued ==  1),2);
                    atRESP{1,1} = nanmean(sdf(sdftm >= statwin(1,1) & sdftm <= statwin(1,2),mI & STIM.cued ==  1),1);
                end
                if sum(mI & STIM.cued == -1) >= 5
                    msdf(2,:) = nanmean(sdf(:,mI & STIM.cued == -1),2);
                    atRESP{1,2} = nanmean(sdf(sdftm >= statwin(1,1) & sdftm <= statwin(1,2),mI & STIM.cued == -1),1);
                end
                if sum(mmI) >= 5
                    msdf(3,:) = nanmean(sdf(:,mmI),2);
                end

                clear bsdf
                bsdf = nan(3,size(sdf,1));
                if sum(bI & STIM.cued ==  1) >= 5
                    bsdf(1,:) = nanmean(sdf(:,bI & STIM.cued ==  1),2);
                    atRESP{2,1} = nanmean(sdf(sdftm >= statwin(1,1) & sdftm <= statwin(1,2),bI & STIM.cued ==  1),1);
                end
                if sum(bI & STIM.cued == -1) >= 5
                    bsdf(2,:) = nanmean(sdf(:,bI & STIM.cued == -1),2);
                    atRESP{2,2} = nanmean(sdf(sdftm >= statwin(1,1) & sdftm <= statwin(1,2),bI & STIM.cued == -1),1);
                end
                if sum(bbI) >= 5
                    bsdf(3,:) = nanmean(sdf(:,bbI),2);
                end

                clear dsdf
                dsdf = nan(3,size(sdf,1));
                if sum(dI & STIM.cued ==  1) >= 5
                    dsdf(1,:) = nanmean(sdf(:,dI & STIM.cued ==  1),2);
                    atRESP{3,1} = nanmean(sdf(sdftm >= statwin(1,1) & sdftm <= statwin(1,2),dI & STIM.cued ==  1),1);
                end
                if sum(dI & STIM.cued == -1) >= 5
                    dsdf(2,:) = nanmean(sdf(:,dI & STIM.cued == -1),2);
                    atRESP{3,2} = nanmean(sdf(sdftm >= statwin(1,1) & sdftm <= statwin(1,2),dI & STIM.cued == -1),1);
                end
                if sum(ddI) >= 5
                    dsdf(3,:) = nanmean(sdf(:,ddI),2);
                end

                % ttest for attn
                clear ttp stats attnstats
                [~,ttp(1),~,stats(1)]=ttest2(atRESP{1,1},atRESP{1,2});
                [~,ttp(2),~,stats(2)]=ttest2(atRESP{2,1},atRESP{2,2});
                [~,ttp(3),~,stats(3)]=ttest2(atRESP{3,1},atRESP{3,2});
                attnstats = [[stats.tstat] ttp]';

                clear deltasdf
                deltasdf(1,:) = msdf(1,:) - msdf(2,:);
                deltasdf(2,:) = bsdf(1,:) - bsdf(2,:);
                deltasdf(3,:) = dsdf(1,:) - dsdf(2,:);

                % combine
                clear SDF
                SDF = cat(1,...
                    msdf,...
                    bsdf,...
                    dsdf,...
                    deltasdf);

                % crop / pad SDF
                clear tm pad st en
                tm = sdftm;
                if tm(end) < sdfwin(2)
                    pad = [tm(end):diff(tm(1:2)):sdfwin(2)];
                    pad(1) = [];
                    en = length(tm);
                    st = find(tm> sdfwin(1),1);
                    tm = [tm pad];
                    tm = tm(st : end);
                    pad(:) = NaN;
                else
                    pad = [];
                    en = find(tm > sdfwin(2),1)-1;
                    st = find(tm > sdfwin(1),1);
                    tm = tm( st : en );
                end
                pad = repmat(pad,10,1);
                clear aSDF
                aSDF = cat(2,SDF(:, st : en), pad); clear SDF
                if size(aSDF,2) ~= length(tm)
                    error('check tm')
                end
                if all(isnan(nTM))
                    nTM = tm; 
                end
                if any(any(aSDF))
                    attnana = 1;
                end

            end
        end



         %% Sweet - now you have prefeye and prefori.     
% Rather than relying on the above indexing for the monocular (which is
% also missing the monocular NSxDE, pull out your 4x350 SDF matrix on your
% own.

clear brfstilts TwoByTwoSDF TwoByTwoSEM monocTrlNum
if  ~isnan(prefeye)
    %% Find the two orientations shown during brfs, and which is closest to prefori
    clear I
    I = STIM.ditask...
    & STIM.adapted == 0 ...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,goodfiles);

    brfstilts = nanunique(tilts(I,:));
    if ~any(ismember(brfstilts,prefori))
        warning('prefori not shown during brfs session. Must be fixed.')
        disp(strcat('listNum=',num2str(i),'elNum=',num2str(e)))

    end

    %% Pull out 2x2 SDF matrix                                                                 
    % analyze by DI condition
        clear sdftm monocSDF sdf
        sdf   = squeeze(matobj.SDF(e,:,:)); % load only the channel of interest from matobj
        sdftm =  matobj.sdftm;
        monoccond       = {'PSxDE','NSxDE','PSxNDE','NSxNDE'};
        sdfct           = 0; 
        monocSDF        = nan(4,length(sdftm));
        monocSEM        = nan(4,length(sdftm));
        monocTrlNum     = nan(4,1);

        nullori = setdiff(brfstilts,prefori);
        nulleye = nanunique(setdiff(eyes,prefeye)); 

            for monoc = 1:size(monoccond,2)
                clear trls
                switch monoccond{monoc}           % Find the trials you want to look at
                    case 'PSxDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == prefori & ...  
                            STIM.eye == prefeye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
                            STIM.monocular;  
                    case 'NSxDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == nullori & ...  
                            STIM.eye == prefeye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
                            STIM.monocular; 
                    case 'PSxNDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == prefori & ...  
                            STIM.eye == nulleye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
                            STIM.monocular; 
                    case 'NSxNDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == nullori & ...  
                            STIM.eye == nulleye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
                            STIM.monocular; 
                end
                if sum(trls) >= 5  
                    monocSDF(monoc,:)   = nanmean(sdf(:,trls),2); 
                    monocSEM(monoc,:)   = (nanstd(sdf(:,trls),[],2))./sqrt(sum(trls));                
                else
                    monocSDF(monoc,:)   = nan(size(sdf,1),1);              
                    monocSEM(monoc,:)   = nan(size(sdf,1),1);
                end
                monocTrlNum(monoc,:) = sum(trls);
            end  


                            % crop / pad SDF
                    clear tm pad st en
                    tm = sdftm;
                    if tm(end) < sdfwin(2)   % Make sure the SDF is the same across all of the sessions. I may want to change this. change sdfwin to be -100 to 800 ??? 
                        pad = [tm(end):diff(tm(1:2)):sdfwin(2)];
                        pad(1) = [];
                        en = length(tm);
                        st = find(tm> sdfwin(1),1);
                        tm = [tm pad];
                        tm = tm(st : end);
                        pad(:) = NaN;
                    else
                        pad = [];
                        en = find(tm > sdfwin(2),1)-1;
                        st = find(tm > sdfwin(1),1);
                        tm = tm(st : en);
                    end
                    padSDF = repmat(pad,size(monocSDF,1),1); % pads with NANs if you are not in that condition any more. 
                    padSEM = repmat(pad,size(monocSEM,1),1);
                        clear TwoByTwo nTM
                        TwoByTwoSDF = cat(2,monocSDF(:, st : en), padSDF); clear monocSDF;
                        TwoByTwoSEM = cat(2,monocSEM(:, st : en), padSEM); clear monocSEM;
                        if size(TwoByTwoSDF,2) ~= length(tm)
                            error('check tm')
                        end
                        nTM = tm;

else
    brfstilts       = nan(1,2);
    TwoByTwoSDF     = nan(4,350);
    TwoByTwoSEM     = nan(4,350);
    monocTrlNum     = nan(1,4);
end

%% SAVE IDX
        % skip if no data
        if ~any([X.oriana X.occana diana attnana])
            continue
        end

        % SAVE UNIT INFO!
        uct = uct + 1;
        IDX(uct).penetration = penetration;
        IDX(uct).header = penetration(1:8);
        IDX(uct).monkey = penetration(8);
        IDX(uct).runtime = now;

        IDX(uct).depth = STIM.depths(e,:)';
        IDX(uct).kls   = kls;

        IDX(uct).occana       = X.occana;
        IDX(uct).oriana       = X.oriana;
        IDX(uct).diana        = diana;
        IDX(uct).atana        = attnana;
        IDX(uct).mask         = any(STIM.rsvpmask(STIM.cued ~=0));
        IDX(uct).redun        = redun;
        IDX(uct).dicontrast   = stimcontrast';
        IDX(uct).attncontrast = attncontrast';


        IDX(uct).ori   = X.ori';
        IDX(uct).occ   = X.occ';   % how much it prefers one eye over the other
        IDX(uct).bio   = X.bio';        % How much it prefers both eyes over one
        IDX(uct).dfft  = [X.f0 X.fnot]';

        IDX(uct).prefeye    = prefeye;
        IDX(uct).prefori    = prefori;
        IDX(uct).nulleye    = nulleye;
        IDX(uct).nullori    = nullori;        
        IDX(uct).dianov     = anp; % p for main effect of each 'eye' 'tilt' 'contrast'
        IDX(uct).distats    = distats; % t-test for each di contrast
        IDX(uct).atanova    = attnp; % p for 'cued','stim','cued*stim';
        IDX(uct).atastats   = attnstats; % t-test for each attention contrast
        IDX(uct).statwin    = statwin; 

        IDX(uct).SDF       = cat(1,nSDF,aSDF); %rows = Mpp,BI,dCOS,BI-Mpp,dCOS-Mpp; columns = time;
        IDX(uct).tm        = nTM;

        IDX(uct).CRF       = CRF; 
        
        IDX(uct).brfstilts = brfstilts;
        IDX(uct).monocSDF  = TwoByTwoSDF;
        IDX(uct).monocSEM  = TwoByTwoSEM;
        IDX(uct).monocTrlNum = monocTrlNum;



toc
    end
% % % %     end   %%%%% KLS loop removed for now
end





%% SAVE
if flag_saveIDX
    cd('G:\LaCie\Adaptdcos figs')
    if isfile(saveName)
        error('file already exists')        
    end
    save(saveName,'IDX')
end

load gong
sound(y,Fs)