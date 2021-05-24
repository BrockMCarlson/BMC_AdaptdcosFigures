function data = D_BAND_BASIC_NODECI( data_in, data_fs, band, band_name, varargin )
% clear
% cd('C:\Users\Brock Carlson\Desktop\V1featSelectSandbox')
% load('151206_E_eD_LFP')
% croppedSDF = cropNaNsFromSDF(SDF);
% data = D_BAND_BASIC_NODECI(croppedSDF, 1000, [70 150], 'highGamma')


band_name_fs = [band_name '_fs'];

data.(band_name).hpc = band(2);
data.(band_name).lpc1 = band(1);
data.(band_name).lpc2 = band(1)/2;

filt_order = 4; %default

do_power = true;
do_oscil = true;

varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p','power'}
            do_power = varargin{varStrInd(iv)+1};
        case {'-o','oscil'}
            do_oscil = varargin{varStrInd(iv)+1};
        case {'-f', 'filter_order'}
            filt_order = varargin{varStrInd(iv)+1};
    end
end

data.(band_name).filt_order = filt_order;

if do_oscil; data.data = nan(size(data_in,1), size(data_in,2), size(data_in, 3)); end

for i = 1 : size(data_in, 3)
    hWn = data.(band_name).hpc / (data_fs/2);
    [ bwb, bwa ] = butter( filt_order, hWn, 'high' );
    
    hphga = filtfilt( bwb, bwa, data_in(:,:,i)' );
    
    lWn = data.(band_name).lpc1 / (data_fs/2);
    [ bwb, bwa ] = butter( filt_order, lWn, 'low' );
    hphga = filtfilt( bwb, bwa, hphga );
    
    if do_oscil
        
        hphga_d = hphga;
        new_fs = data_fs;
        
        data.data(1:size(hphga_d,2),:,i) = single(hphga_d');
        if i == 1
            data.(band_name_fs) = new_fs;
        end
        
    end
    
    if do_power
        
        band_name_power_fs = [band_name '_pwr_fs'];
        band_name_power = [band_name '_pwr'];
        
        if i == 1
            data.(band_name_power) = nan(size(data_in,1), size(data_in,2), size(data_in, 3));
        end
        
        hphga = abs( hphga );
        
        lWn = data.(band_name).lpc2 / (data_fs/2);
        [ bwb, bwa ] = butter( filt_order, lWn, 'low' );
        hphga = filtfilt( bwb, bwa, hphga );
        
        hphga_p = hphga;
        new_fs = data_fs;
        
        data.(band_name_power)(1:size(hphga_d,2),:,i) = single(hphga_p');
        if i == 1
            data.(band_name_power_fs) = new_fs;
        end
    end
end
end