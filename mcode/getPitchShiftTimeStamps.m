function psSummary = getPitchShiftTimeStamps(data)
psCents = log2(data.pitchShiftRatio) * 12 * 100;
[stret_on, stret_off] = get_cont_stretches(psCents ~= 0);

assert(length(stret_on) == length(stret_off));
psSummary = cell(1, length(stret_on));

frameDur = data.params.frameLen / data.params.sr * 1e3; % Unit ms
for i1 = 1 : numel(stret_on)
    %-- Format: [onset time (ms), offset time (ms), pitch shift (cent)]
    psSummary{i1} = [(stret_on(i1) - 1) * frameDur, ...
                     (stret_off(i1) - 1) * frameDur, ...
                     psCents(stret_on(i1))];
end

return