function gen_multi_pert_pcf(ost_fn, pcf_fn, rmsThresh, ...
                            pShift_cent, intShift_dB, F1Shift_ratio, F2Shift_ratio, ...
                            shift_onset, shift_dur)
%% Constants
rmsHold = 0.05; % Unit: s
autoCycleCnt = 10;   % Auto-cycling iteration count: for dealing with repeated words and supra-threshold noise

%% Sanity check
% assert(length(pShift_cent) >= 1);
assert(length(pShift_cent) == length(shift_onset));
assert(length(pShift_cent) == length(shift_dur));
assert(length(pShift_cent) == length(intShift_dB));
assert(length(pShift_cent) == length(F1Shift_ratio));
assert(length(pShift_cent) == length(F2Shift_ratio));

if length(shift_dur) > 1
    assert(isempty(find(isinf(shift_dur), 1)));
end

%% ost file
ns = length(pShift_cent);
% n_ost = 

ost = fopen(ost_fn, 'wt');
fprintf(ost, 'rmsSlopeWin = 0.030000\n\n');

pertStates = [];
lines = {};

if length(shift_dur) == 1 && isinf(shift_dur)
    t_state = 0;
    
    for i1 = 1 : autoCycleCnt
        lines{end + 1} = sprintf('%d 5 %f %f {}', t_state, rmsThresh, rmsHold);
        pertStates(end + 1) = t_state + 1;
        pertStates(end + 1) = t_state + 2;

        lines{end + 1} = sprintf('%d 20 %f %f {}', t_state + 2, rmsThresh, rmsHold);
        
        t_state = t_state + 3;
    end
    
    lines{end + 1} = sprintf('%d 0 NaN NaN {}', t_state);
    
    state = t_state;
else
    lines{end + 1} = sprintf('0 5 %f %f {}', rmsThresh, rmsHold);
    lines{end + 1} = sprintf('2 1 %f 0 {}', shift_onset(1) / 1e3 - rmsHold);
    lines{end + 1} = sprintf('3 1 %f 0 {}', shift_dur(1) / 1e3);
    pertStates(end + 1) = 3;
    state = 3;

    for i1 = 2 : length(pShift_cent)
        lines{end + 1} = sprintf('%d 1 %f 0 {}', state + 1, ...
                                 shift_onset(i1) / 1e3 - shift_onset(i1 - 1) / 1e3 - shift_dur(i1 - 1) / 1e3);
        state = state + 1;

        lines{end + 1} = sprintf('%d 1 %f 0 {}', state + 1, shift_dur(i1) / 1e3);
        state = state + 1;

        pertStates(end + 1) = state;
    end

    lines{end + 1} = sprintf('%d 0 NaN NaN {}', state + 1);
    state = state + 1;

    
end


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
        pertAmp = abs(F1Shift_ratio(idxPert) + i * F2Shift_ratio(idxPert));
        pertPhi = angle(F1Shift_ratio(idxPert) + i * F2Shift_ratio(idxPert));
        
        fprintf(pcf, '%d, %f, %f, %f, %f\n', i1, ...
                pShift_cent(idxPert) / 100, ...
                intShift_dB(idxPert), ...
                pertAmp, pertPhi);
            
        if ~(length(shift_dur) == 1 && isinf(shift_dur))
            idxPert = idxPert + 1;
        end
    else
        fprintf(pcf, '%d, 0, 0, 0, 0\n', i1);
    end
end

fclose(pcf);
return