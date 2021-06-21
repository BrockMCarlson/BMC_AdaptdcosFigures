clear
close all
PostSetup('BrockHome')
flag_SaveFigs = false;

global STIMDIR
cd(STIMDIR)
load('151221_E_eD_LFP')

brfsTrials = strcmp(STIM.task,'brfs');


% spectrogram conventions
nfft = 2^8;
rsampt = 0.0010; % 1 kHz
frange = [1 100]; % look at 1 to 100 Hz only
fs = floor(1/rsampt);
overlap = nfft-1;
poststim = 1:1200; % limit time window
brfsTrials = strcmp(STIM.task,'brfs');
SDF = SDF(:,:,brfsTrials);
SDF = SDF(:,[1:1500],:);
[totchan,tottm,tottr] = size(SDF);
    for tr = 1:tottr
      dcoffs = mean(SDF(:,poststim,tr),2); % mean of LFP data after stim onset
      mntrvlfp = repmat(dcoffs,1,tottm);
      cttrvlfp = SDF(:,:,tr)-mntrvlfp; %center
      for i=1;%totchan
          [tmp,F,T] = specgram(cttrvlfp(i,:),nfft,fs,[],overlap);
          fsel = find(F<frange(2) & F > frange(1));
          %spc = (abs(tmp(fsel,:)));
          spc(:,:) = 20*log10(abs(tmp(fsel,:)));
          % baseline correct
          basetm = find(T*1000 > 1 & T*1000 < 100);
          basespc = mean(spc(:,basetm),2);
          [bnds,tmn] = size(spc);
          basemat = repmat(basespc,1,tmn);
          spc = spc-basemat; % => baseline subtracted
          % collect spectra
          trv.spgm(:,:,i,tr) = spc; clear spc
        end
    end
    %compute trial average
    travg_spc_mn = squeeze(nanmean(trv.spgm,4));
    % plot
    travg_spc = imrotate(travg_spc_mn,0);
    figure(2), clf
    imagesc(T,F(fsel),travg_spc)