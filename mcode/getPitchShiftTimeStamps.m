function [psSummary, voiceOnset] = getPitchShiftTimeStamps(data)
%% Find voice onset 
frameDur = data.params.frameLen / data.params.sr * 1e3; % Unit ms

idx_2_0 = find(data.ost_stat == 2, 1, 'first');
if ~isempty(idx_2_0)
    idx_1_0 = NaN;
    for i1 = idx_2_0 - 1 : -1 : 2
        if data.ost_stat(i1) == 1 && data.ost_stat(i1 - 1) == 0
            idx_1_0 = i1;
            break;
        end
    end
    
    voiceOnset = frameDur * (idx_1_0 - 1);
else
    voiceOnset = NaN;
end

%% Obtain pitch shift summary
psCents = log2(data.pitchShiftRatio) * 12 * 100;
[stret_on, stret_off] = get_cont_stretches(psCents ~= 0);

%%
assert(length(stret_on) == length(stret_off));
psSummary = cell(1, length(stret_on));

for i1 = 1 : numel(stret_on)
    %-- Format: [onset time (ms), offset time (ms), pitch shift (cent)]
    psSummary{i1} = [(stret_on(i1) - 1) * frameDur, ...
                     stret_off(i1) * frameDur, ...
                     psCents(stret_on(i1))];
end

return