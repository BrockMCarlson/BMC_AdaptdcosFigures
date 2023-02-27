function output = testTest(datfile,recordingtype,allheads)
% modeled from make_eMouseChannelMap.m on Dec 8 2016
% (see far below for a copy of script)
% this will only work on Uprobe/NN recordings with the 'eX##" label format

if nargin < 2
    recordingtype = 'multi'; 
end

if strcmp(recordingtype,'single')
    
    NS_Header = openNSx(datfile,'noread');
    elabels = cellfun(@(x) x(1:4),NS_Header.ElectrodeLabel,'UniformOutput',0)';
    enum    = cellfun(@(x) str2double(x(3:4)),elabels);
    ebanks  = cellfun(@(x) (x(2)),elabels);
    eempty  = ~cellfun('isempty',strfind(elabels,'ainp')); % bank E in the analogn inputs
    elabels(eempty) = {'xxxx'};
    
    % determin if NN or Uprobe
    probemax  = max(enum);
    probetype = 'FHC';
    
    % chanMap(1) is the row in the raw binary file for the first channel.
    % the first thing Kilosort does is reorder the data with data = data(:,chanMap).
    [sortedelabels,chanMap] = sort(elabels);
    chanMap0ind = chanMap - 1;
    
    % group channels on the same probe (bank)
    kcoords = grp2idx(ebanks(chanMap));
    
    % define vertical cordnates in um
    % elabel 01 is deepest, 32 is shallowest
    ycoords = 100 * (cellfun(@(x) str2double(x(3:4)),sortedelabels)-1) ;
    
    % define horzontal coordnates in um (units don't really matter)
    %xcoords = kcoords * 1000; % put probes 1 MM apart as needed
    xcoords = repmat((kcoords-1) * 1000,length(ycoords),1); % put probes 1 MM apart as needed
    
    % declare which channels are "connected" meaning not dead or used for non-ephys data
    connected = ~strcmp(sortedelabels,'xxxx');
    
    % helpful to include fs
    fs = double(NS_Header.MetaTags.SamplingFreq);
    
    clear output
    % for KiloSort
    output.chanMap = chanMap;
    output.chanMap0ind = chanMap0ind;
    output.ycoords = ycoords;
    output.xcoords = xcoords;
    output.kcoords = kcoords;
    output.connected = connected;
    output.fs = fs;
    % for Me
    output.chanMapLabels = sortedelabels;
    output.nprobes = 1;
    output.probetype = 'FHC';
    output.NS_Header = NS_Header;
    output.allheads = allheads; 
    output.ns6file   = datfile;
    
else
    
    NS_Header = openNSx(datfile,'noread');
    
    elabels = cellfun(@(x) x(1:4),{NS_Header.ElectrodesInfo.Label},'UniformOutput',0)';
    enum = cellfun(@(x) str2double(x(3:4)),elabels);
    ebanks  = {NS_Header.ElectrodesInfo.ConnectorBank}';
    eempty  = strcmp(ebanks,'E') ; % bank E in the analogn inputs
    elabels(eempty) = {'xxxx'};
    
%     % determine if NN or Uprobe
%     probemax = max(enum);
%     if probemax == 32
%         % assume NN probe
%         probetype = 'NN';
%     else
%         probetype = 'Uprobe';
%         % remove channels 23 and 24  b/c they often suck and will mess up the whitening step
%         % elabels(enum>22) = {'xxxx'};
%     end

    % determine if NN or Uprobe
    eid = {NS_Header.ElectrodesInfo.ElectrodeID};
    elb = {NS_Header.ElectrodesInfo.Label};
    
    probemax = max(enum);
    if str2double(elb{1}(3:4)) >= 30
        % assume NN probe
        probetype = 'NN';
    else
        probetype = 'Uprobe';
        % remove channels 23 and 24  b/c they often suck and will mess up the whitening step
        % elabels(enum>22) = {'xxxx'};
    end
    
    % chanMap(1) is the row in the raw binary file for the first channel.
    % the first thing Kilosort does is reorder the data with data = data(:,chanMap).
    [sortedelabels,chanMap] = sort(elabels);
    chanMap0ind = chanMap - 1;
    
    % group channels on the same probe (bank)
    kcoords = grp2idx(ebanks(chanMap));
    
    % define vertical cordnates in um
    switch probetype
        case 'NN'
            % elabel 01 is deepest, 32 is shallowest
            ycoords = 100 * (cellfun(@(x) str2double(x(3:4)),sortedelabels)-1) ;
            
        case 'Uprobe'
            % elabel 01 is shallowest, 24 is deepest
            ycoords = cellfun(@(x) str2double(x(3:4)),sortedelabels);
            ycoords  = 100 * abs(ycoords-24);
    end
    
    % define horzontal coordnates in um (units don't really matter)
    xcoords = kcoords * 1000; % put probes 1 MM apart as needed
    
    % declare which channels are "connected" meaning not dead or used for non-ephys data
    connected = ~strcmp(sortedelabels,'xxxx');
    
    % helpful to include fs
    fs = double(NS_Header.MetaTags.SamplingFreq);
    
    clear output
    % for KiloSort
    output.chanMap = chanMap;
    output.chanMap0ind = chanMap0ind;
    output.ycoords = ycoords;
    output.xcoords = xcoords;
    output.kcoords = kcoords;
    output.connected = connected;
    output.fs = fs;
    % for Me
    output.chanMapLabels = sortedelabels;
    output.nprobes = length(unique(ebanks(~strcmp(ebanks,'E'))));
    output.probetype = probetype;
    output.NS_Header = NS_Header;
    output.ns6file   = datfile;
end
%%


% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 0.2; 

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group. 

%%
% 
% function make_eMouseChannelMap(fpath)
% % create a channel Map file for simulated data (eMouse)
% 
% % here I know a priori what order my channels are in.  So I just manually 
% % make a list of channel indices (and give
% % an index to dead channels too). chanMap(1) is the row in the raw binary
% % file for the first channel. chanMap(1:2) = [33 34] in my case, which happen to
% % be dead channels. 
% 
% chanMap = [33 34 8 10 12 14 16 18 20 22 24 26 28 30 32 ...
%     7 9 11 13 15 17 19 21 23 25 27 29 31 1 2 3 4 5 6];
% 
% % the first thing Kilosort does is reorder the data with data = data(chanMap, :).
% % Now we declare which channels are "connected" in this normal ordering, 
% % meaning not dead or used for non-ephys data
% 
% connected = true(34, 1); connected(1:2) = 0;
% 
% % now we define the horizontal (x) and vertical (y) coordinates of these
% % 34 channels. For dead or nonephys channels the values won't matter. Again
% % I will take this information from the specifications of the probe. These
% % are in um here, but the absolute scaling doesn't really matter in the
% % algorithm. 
% 
% xcoords = 20 * [NaN NaN  1 0 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
% ycoords = 20 * [NaN NaN  7 8 9 9 10 10 11 11 12 12 13 13 14 14 15 15 16 ...
%     17 17 18 18 19 19 20 20 21 21 22 22 23 23 24]; 
% 
% % Often, multi-shank probes or tetrodes will be organized into groups of
% % channels that cannot possibly share spikes with the rest of the probe. This helps
% % the algorithm discard noisy templates shared across groups. In
% % this case, we set kcoords to indicate which group the channel belongs to.
% % In our case all channels are on the same shank in a single group so we
% % assign them all to group 1. 
% 
% kcoords = [NaN NaN 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% 
% % at this point in Kilosort we do data = data(connected, :), ycoords =
% % ycoords(connected), xcoords = xcoords(connected) and kcoords =
% % kcoords(connected) and no more channel map information is needed (in particular
% % no "adjacency graphs" like in KlustaKwik). 
% % Now we can save our channel map for the eMouse. 
% 
% % would be good to also save the sampling frequency here
% fs = 25000; 
% 
% save(fullfile(fpath, 'chanMap.mat'), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords', 'fs')