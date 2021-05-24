function summary = RELIABILITY_SELECTION(dat_in, varargin)

summary.counts          = 'min'; %either vector (e.g., 1:250) or 'min'
summary.percent         = 80;
summary.boots           = 1000;
summary.resample        = false;
summary.subsample       = false;
summary.method          = 'counts'; % Alternatives: 'count', 'percent'

varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-c','counts'}
            summary.counts = varargin{varStrInd(iv)+1};
        case {'-p','percent'}
            summary.percent = varargin{varStrInd(iv)+1};
        case {'-b','boots'}
            summary.boots = varargin{varStrInd(iv)+1};
        case {'-r','resample'}
            summary.resample = varargin{varStrInd(iv)+1};
        case {'-s','subsample'}
            summary.subsample = varargin{varStrInd(iv)+1};
        case {'-m','method'}
            summary.method = varargin{varStrInd(iv)+1};
    end
end

if summary.subsample
     min_trl_ct = min(cellfun(@numel, dat_in));
     for i = 1 : size(data_in,2)
        data_in{i} = datasample(data_in{i}, min_trl_ct, 'Replace', false);
     end
end

if strcmp(summary.method, 'percent')
    min_trl_ct = min(cellfun(@numel, dat_in));
    temp_counts = round(summary.percent/100*min_trl_ct);
    summary = rmfield(summary, 'counts');
elseif strcmp(summary.method, 'counts')
    if isstr(summary.counts)
        if strcmp(summary.counts, 'min'); temp_counts = 1 : min(cellfun(@numel, dat_in)); end
    else
        temp_counts = summary.counts;
    end
    summary = rmfield(summary, 'percent');
end

summary.choice                  = zeros(numel(temp_counts), size(dat_in,2));
summary.choice_percentage       = nan(numel(temp_counts), size(dat_in,2));

for counts = 1 : numel(temp_counts)
    for boots = 1 : summary.boots
        
        stim_sum = nan(1,size(dat_in,2));
        for stim_row = 1 : size(dat_in,2)
            rsamps = randsample(numel(dat_in{stim_row}), temp_counts(counts), summary.resample);
            stim_sum(stim_row) = sum(dat_in{stim_row}(rsamps));
        end
        
        [~,mind] = max(stim_sum);
        summary.choice(counts, mind) = summary.choice(counts, mind) + 1;

    end   
end

summary.choice_percentage = summary.choice ./ summary.boots .* 100;

end