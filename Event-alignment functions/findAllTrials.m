function STIM = findAllTrials(Date,e)


%% TuneList setup
%load everything in from TuneList
TuneList = importTuneList(2);
    % % case {1,'all di tasks','dionly','ditasks'}
    % % ditasks = {'cosinteroc','mcosinteroc','dmcosinteroc','brfs','dbrfs', 'rsvp'};
    % % 
    % % case {2,'brfs','Brock'} % Brock
    % % ditasks = {'brfs'};
    % % 
    % % case {3, 'brock_blake'} % Brock Blake
    % % ditasks = {'cosinteroc','mcosinteroc','brfs'};
    
dateIndex = find(strcmp(TuneList.Datestr,Date));

    WORKING HERE
    
    
% cut down TuneList to only analyze files from a given RIGDIR if needed for testing.    
global RIGDIR
list = dir([RIGDIR]);
dirlist = cellfun(@(x,y) sprintf('%s_%s',x,y),TuneList.Datestr,TuneList.Monkey,'UniformOutput',false);

I = ismember(dirlist,{list.name}); % logical output
 fields = fieldnames(TuneList);
    for f = 1:length(fields)
        TuneList.(fields{f})(~I) = [];
    end

errct = 0;
%%


% setup save path
global OUTDIR
varsavepath  = OUTDIR;


    
    clear header el penetration
    penetration = TuneList.Penetration{e};
    if strcmp(penetration,'151222_E_eD')
        warning('no bhv found for 151222. Check on Drobo after restart')
        continue
    end
    header = TuneList.Penetration{s}(1:end-3);
    el     = TuneList.Penetration{s}(end-1:end);
%     if flag_checkforexisting && (~strcmp(analysis,'diSTIM') && ~strcmp(analysis,'offlineBRAutoSort') &&  ~strcmp(analysis,'V1Limits') && ~strcmp(analysis,'ss') )%&& exist([varsavepath header '_' el '.mat'],'file')
%         error('flag_checkforexisting working?')
%         continue
%     end
    
    disp(s);
    disp(TuneList.Penetration{s});
    
    clear sortdirection
    sortdirection = TuneList.SortDirection{s};
    
    clear drobo
    switch TuneList.Drobo(s)
        case 1
            drobo = 'Drobo';
        otherwise
            drobo = sprintf('Drobo%u',TuneList.Drobo(s));
    end
    
    % build session filelist
    ct = 0; filelist = {};
    for p = 1:length(paradigm)
        
        if strcmp(paradigm{p},'rsvp')
            tf =     strcmp('ori', getRSVPTaskType(TuneList.Datestr{s}));
            if tf
                continue
            end
        end
        
        clear exp
        exp = TuneList.(paradigm{p}){s};
        for d = 1:length(exp)
            ct = ct + 1;
            global RIGDIR
            if ~isempty(RIGDIR)
                filelist{ct,1} = strcat(...
                    RIGDIR,...
                    TuneList.Datestr{s},'_',TuneList.Monkey{s},filesep,...
                    TuneList.Datestr{s},'_',TuneList.Monkey{s},'_',paradigm{p},sprintf('%03u',exp(d)));                
            else
                filelist{ct,1} = sprintf('/Volumes/%s/Data/NEUROPHYS/rig%03u/%s_%s/%s_%s_%s%03u',...
                    drobo,TuneList.Rig(s),TuneList.Datestr{s},TuneList.Monkey{s},TuneList.Datestr{s},TuneList.Monkey{s},paradigm{p},exp(d));
            end
        end
    end
    

        
        
            
%           
  
            
            % get info from TuneList
            clear idx pn
            idx = find(strcmp(TuneList.Datestr,header(1:6)));
            pn  = find(strcmp(TuneList.Penetration(idx),penetration));
            
           % get TPs
            clear STIM V1 STIM0
            V1 = TuneList.Structure{s};
            STIM = diTP(filelist,V1);
            STIM.V1   = V1;
            STIM.penetration = penetration;
            
            % diCheck
            [pass, message] = diCheck(STIM);
            STIM.message = message;
            if ~pass 
                errct = errct +1;
                ERR{errct,1} = header;
                ERR{errct,2} = el;
                ERR{errct,3} = message;
                save([varsavepath 'ERR'],'ERR','s','TuneList')
            end
            
            % photodiode trigger
            [STIM,fails] = diPT(STIM); 
            if any(fails)
                errct = errct +1;
                ERR{errct,1} = header;
                ERR{errct,2} = el;
                ERR{errct,3} = 'fail photodiode trigger';
                save([varsavepath 'ERR'],'ERR','s','TuneList')
                continue
            end
            
            % V1 lim
            STIM.rmch = TuneList.BadBtmCh(idx(pn));
            STIM = diV1Lim(STIM,pn);
            if ~strcmp(STIM.penetration,penetration)
                error('penetrations are messed up')
            end
            STIM.rank = TuneList.Rank(idx(pn));
            














end