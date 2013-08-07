function gen_multi_pert_pcf(ost_fn, pcf_fn, rmsThresh, pShift_cent, pShift_onset, pShift_dur)
%% Constants
rmsHold = 0.05; % Unit: s

%% Sanity check
% assert(length(pShift_cent) >= 1);
assert(length(pShift_cent) == length(pShift_onset));
assert(length(pShift_cent) == length(pShift_dur));

%% ost file
ns = length(pShift_cent);
% n_ost = 

ost = fopen(ost_fn, 'wt');
fprintf(ost, 'rmsSlopeWin = 0.030000\n\n');

pertStates = [];
lines = {};
lines{end + 1} = sprintf('0 5 %f %f {}', rmsThresh, rmsHold);
lines{end + 1} = sprintf('2 1 %f 0 {}', pShift_onset(1) / 1e3 - rmsHold);
lines{end + 1} = sprintf('3 1 %f 0 {}', pShift_dur(1) / 1e3);
pertStates(end + 1) = 3;
state = 3;

for i1 = 2 : length(pShift_cent)
    lines{end + 1} = sprintf('%d 1 %f 0 {}', state + 1, ...
                             pShift_onset(i1) / 1e3 - pShift_onset(i1 - 1) / 1e3 - pShift_dur(i1 - 1) / 1e3);
	state = state + 1;
    
    lines{end + 1} = sprintf('%d 1 %f 0 {}', state + 1, pShift_dur(i1) / 1e3);
    state = state + 1;
    
    pertStates(end + 1) = state;
end

lines{end + 1} = sprintf('%d 0 NaN NaN {}', state + 1);
state = state + 1;

fprintf(ost, 'n = %d\n', length(lines));
for i1 = 1 : numel(lines)
    fprintf(ost, '%s\n', lines{i1});
end

fclose(ost);

%% pcf file
nStates = state;

pcf = fopen(pcf_fn, 'wt');

fprintf(pcf, '# Section 1 (Time warping): tBegin, rate1, dur1, durHold, rate2 \n');
fprintf(pcf, '0\n');
fprintf(pcf, '\n');

fprintf(pcf, '# Section 2: stat pitchShift(st) gainShift(dB) fmtPertAmp fmtPertPhi(rad)\n');
fprintf(pcf, '%d\n', nStates + 1);

idxPert = 1;
for i1 = 0 : nStates
    if ~isempty(find(pertStates == i1, 1))
        fprintf(pcf, '%d, %f, 0, 0, 0\n', i1, pShift_cent(idxPert) / 100);
        idxPert = idxPert + 1;
    else
        fprintf(pcf, '%d, 0, 0, 0, 0\n', i1);
    end
end

fclose(pcf);
return