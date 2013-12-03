function [phaseScript, pertDes] = genRandScript(phase, nBlocks, trialsPerBlock, ...
                                     trialTypes, minDistBetwShifts, ...
                                     onsetDelays_ms, numShifts, ...
                                     interShiftDelays_ms, pitchShifts_cent, ...
                                     intShifts_dB, ...
                                     F1Shifts_ratio, F2Shifts_ratio, ...
                                     shiftDurs_ms, stimUtters, fullSchedFN)
%%
sustPhaseNames = {'start', 'ramp', 'stay', ...
                  'stay1', 'stay2', 'stay3', 'stay4', ...
                  'end'};

%%
if ~isempty(fullSchedFN)
    check_file(fullSchedFN);
    sched = textread(fullSchedFN, '%s', 'delimiter', '\n');
    
    if size(sched, 1) > size(sched, 2)
        sched = sched';
    end
    
    fprintf(1, 'INFO: Using full schedule file for rand phase: %s\n', ...
            fullSchedFN);
end

check_pos_int(nBlocks, 'N_BLOCKS_PER_RAND_RUN must be a positive integer');
check_pos_int(trialsPerBlock, 'TRIALS_PER_BLOCK must be a positive integer');


%% trialTypes
if ~isempty(fsic(sustPhaseNames, phase))
    assert(isempty(trialTypes));
    trialTypes = sprintf('{%d-sust}', trialsPerBlock);
    minDistBetwShifts = 0;
    
    bSust = 1;
else
    bSust = 0;
end

a_trialTypes = {};
a_trialTypeIsPert = [];
a_nTrialsPerBlock = [];

if ~isempty(fullSchedFN)
    a_trialTypes = unique(sched);
    for i1 = 1 : numel(a_trialTypes)
        a_trialTypeIsPert(i1) = ~(isequal(a_trialTypes{i1}, 'ctrl') || ...
                                  isequal(a_trialTypes{i1}, 'baseline'));
        a_nTrialsPerBlock(i1) = length(fsic(sched, a_trialTypes{i1}));
    end
    
else
    trialTypes = strip_brackets(trialTypes, 'Wrong format in field TRIAL_TYPES_IN_BLOCK');
    t_items = splitstring(trialTypes, ',');

    for i1 = 1 : numel(t_items)
        if length(strfind(t_items{i1}, '-')) ~= 1
            error('Wrong format in item #%d of TRIAL_TYPES_IN_BLOCK: %s', ...
                  i1, t_items{i1});
        end

        t_strs = splitstring(t_items{i1}, '-');
        a_trialTypes{end + 1} = t_strs{2};
        a_trialTypeIsPert(end + 1) = ~(isequal(lower(a_trialTypes{end}), 'ctrl') || ...
                                       isequal(lower(a_trialTypes{end}), 'baseline'));
        a_nTrialsPerBlock(end + 1) = str2double(t_strs{1});

        check_pos_int(a_nTrialsPerBlock(end), ...
                      'Number of trials in TRIAL_TYPES_IN_BLOCK must be positive integers', 1); % Allow zero
    end

    if length(unique(a_trialTypes)) ~= length(a_trialTypes)
        error('Duplicate items in TRIAL_TYPES_IN_BLOCK');
    end

end



if ~bSust
    %--- Make sure that ctrl is first in list ---%
    idxCtrl = union(fsic(a_trialTypes, 'ctrl'), fsic(a_trialTypes, 'baseline'));
    if length(idxCtrl) == 0
        error('It is mandatory that ctrl or baseline is in TRIAL_TYPES_IN_BLOCK, although the numbers may be set to zero if necessary.');
    end
    
    idxOrd = [idxCtrl, setxor(1 : length(a_trialTypes), idxCtrl)];
    a_trialTypes = a_trialTypes(idxOrd);
    a_trialTypeIsPert = a_trialTypeIsPert(idxOrd);
    a_nTrialsPerBlock = a_nTrialsPerBlock(idxOrd);  
    
else
    %--- Make sure that sust is the only type of trial ---%
    assert(length(a_trialTypes) == 1);
    assert(isequal(a_trialTypes{1}, 'sust'));
end

a_trialTypesPert = a_trialTypes(find(a_trialTypeIsPert));

if sum(a_nTrialsPerBlock) ~= trialsPerBlock
    error('Numbers in TRIAL_TYPES_IN_BLOCK do not sum to TRIALS_PER_BLOCK');
end

if a_nTrialsPerBlock(1) == 0 && minDistBetwShifts ~= 0
    error('minDistBetwShifts value is invalid because there is no ctrl trial');
end

%% onsetDelay
a_onsetDelays = struct;

onsetDelays_ms = strip_brackets(onsetDelays_ms, 'Wrong format in field ONSET_DELAYS_MS');

for i1 = 1 : numel(a_trialTypesPert)
    tt = a_trialTypesPert{i1};
    idx1 = strfind(onsetDelays_ms, tt);
    if isempty(idx1)
        error('Cannot find trial type %s in ONSET_DELAYS_MS', tt);
    end

    %-- Prune the strfind results --%
    idx1 = prune_strfind(idx1, onsetDelays_ms, tt, '-');
    if length(idx1) ~= 1
        error('Duplicate items found in ONSET_DELAY_MS');
    end

    %-- Search for the end --%
    if length(onsetDelays_ms) < idx1 + length(tt) + 1 || ~isequal(onsetDelays_ms(idx1 + length(tt)), '-')
        error('Unrecognized format in ONSET_DELAY_MS');
    end

    if isequal(onsetDelays_ms(idx1 + length(tt) + 1), '[')
        idx_rb = strfind(onsetDelays_ms(idx1 + length(tt) + 2 : end), ']');

        if isempty(idx_rb)
            error('Unrecognized format in ONSET_DELAY_MS');
        end
        idx_rb = idx_rb(1);

        t_val = onsetDelays_ms(idx1 + length(tt) + 2 : idx1 + length(tt) + idx_rb);
        a_onsetDelays.(tt) = string2intervals(t_val, 1);
    else
        if ~isequal(onsetDelays_ms(end), ',')
            onsetDelays_ms = [onsetDelays_ms, ','];
        end

        idx_cm = strfind(onsetDelays_ms(idx1 + length(tt) + 1 : end), ',');
        idx_cm = idx_cm(1);
        t_val = onsetDelays_ms(idx1 + length(tt) + 1 : idx1 + length(tt) + idx_cm - 1);
        a_onsetDelays.(tt) = string2intervals(t_val, 1);
    end
end

%% numShifts
a_numShifts = struct;

numShifts = strip_brackets(numShifts, 'Wrong format in field ONSET_DELAYS_MS');

for i1 = 1 : numel(a_trialTypesPert)
    tt = a_trialTypesPert{i1};
    idx1 = strfind(numShifts, tt);
    if isempty(idx1)
        error('Cannot find trial type %s in NUM_SHIFTS', tt);
    end

    %-- Prune the strfind results --%
    idx1 = prune_strfind(idx1, numShifts, tt, '-');
    if length(idx1) ~= 1
        error('Duplicate items found in NUM_SHIFTS');
    end

    %-- Search for the end --%
    if length(numShifts) < idx1 + length(tt) + 1 || ~isequal(numShifts(idx1 + length(tt)), '-')
        error('Unrecognized format in NUM_SHIFTS');
    end

    if isequal(numShifts(idx1 + length(tt) + 1), '[')
        idx_rb = strfind(numShifts(idx1 + length(tt) + 2 : end), ']');

        if isempty(idx_rb)
            error('Unrecognized format in NUM_SHIFTS');
        end
        idx_rb = idx_rb(1);

        t_val = numShifts(idx1 + length(tt) + 2 : idx1 + length(tt) + idx_rb); 
    else
        if ~isequal(numShifts(end), ',')
            numShifts = [numShifts, ','];
        end

        idx_cm = strfind(numShifts(idx1 + length(tt) + 1 : end), ',');
        idx_cm = idx_cm(1);
        t_val = numShifts(idx1 + length(tt) + 1 : idx1 + length(tt) + idx_cm - 1);        
    end

    a_numShifts.(tt) = str2double(t_val);    
    check_pos_int(a_numShifts.(tt), 'Number of shifts must be a positive integer');    
end

%% interShiftDelays
a_interShiftDelays = struct;

interShiftDelays_ms = strip_brackets(interShiftDelays_ms, 'Wrong format in field ONSET_DELAYS_MS');

for i1 = 1 : numel(a_trialTypesPert)
    tt = a_trialTypesPert{i1};
    idx1 = strfind(interShiftDelays_ms, tt);
    if isempty(idx1)
        error('Cannot find trial type %s in INTER_SHIFT_DELAYS_MS', tt);
    end

    %-- Prune the strfind results --%
    idx1 = prune_strfind(idx1, interShiftDelays_ms, tt, '-');
    if length(idx1) ~= 1
        error('Duplicate items found in INTER_SHIFT_DELAYS_MS');
    end

    %-- Search for the end --%
    if length(interShiftDelays_ms) < idx1 + length(tt) + 1 || ~isequal(interShiftDelays_ms(idx1 + length(tt)), '-')
        error('Unrecognized format in INTER_SHIFT_DELAYS_MS');
    end

    if isequal(interShiftDelays_ms(idx1 + length(tt) + 1), '[')
        idx_rb = strfind(interShiftDelays_ms(idx1 + length(tt) + 2 : end), ']');

        if isempty(idx_rb)
            error('Unrecognized format in INTER_SHIFT_DELAYS_MS');
        end
        idx_rb = idx_rb(1);

        t_val = interShiftDelays_ms(idx1 + length(tt) + 2 : idx1 + length(tt) + idx_rb); 
    else
        if ~isequal(interShiftDelays_ms(end), ',')
            interShiftDelays_ms = [interShiftDelays_ms, ','];
        end

        idx_cm = strfind(interShiftDelays_ms(idx1 + length(tt) + 1 : end), ',');
        idx_cm = idx_cm(1);
        t_val = interShiftDelays_ms(idx1 + length(tt) + 1 : idx1 + length(tt) + idx_cm - 1);        
    end

    a_interShiftDelays.(tt) = string2intervals(t_val, 1);
end

%% pitchShifts_cent
a_pitchShifts_cent = get_shift_values(pitchShifts_cent, a_trialTypesPert, a_numShifts, 'PITCH_SHIFTS_CENT');

%% intShift_dB
a_intShifts_dB = get_shift_values(intShifts_dB, a_trialTypesPert, a_numShifts, 'INT_SHIFTS_DB');

%% F1Shift_dB
a_F1Shifts_ratio = get_shift_values(F1Shifts_ratio, a_trialTypesPert, a_numShifts, 'F1_SHIFTS_RATIO');

%% F2Shift_dB
a_F2Shifts_ratio = get_shift_values(F2Shifts_ratio, a_trialTypesPert, a_numShifts, 'F2_SHIFTS_RATIO');

%% shiftDurs_ms
a_shiftDurs_ms = struct;

shiftDurs_ms = strip_brackets(shiftDurs_ms, 'Wrong format in field ONSET_DELAYS_MS');

for i1 = 1 : numel(a_trialTypesPert)
    tt = a_trialTypesPert{i1};
    idx1 = strfind(shiftDurs_ms, tt);
    if isempty(idx1)
        error('Cannot find trial type %s in PITCH_SHIFT_DURS_MS', tt);
    end

    %-- Prune the strfind results --%
    idx1 = prune_strfind(idx1, shiftDurs_ms, tt, '-');
    if length(idx1) ~= 1
        error('Duplicate items found in PITCH_SHIFT_DURS_MS');
    end

    %-- Search for the end --%
    if length(shiftDurs_ms) < idx1 + length(tt) + 1 || ~isequal(shiftDurs_ms(idx1 + length(tt)), '-')
        error('Unrecognized format in PITCH_SHIFT_DURS_MS');
    end

    if isequal(shiftDurs_ms(idx1 + length(tt) + 1), '[')
        idx_rb = strfind(shiftDurs_ms(idx1 + length(tt) + 2 : end), ']');

        if isempty(idx_rb)
            error('Unrecognized format in PITCH_SHIFT_DURS_MS');
        end
        idx_rb = idx_rb(1);

        t_val = shiftDurs_ms(idx1 + length(tt) + 2 : idx1 + length(tt) + idx_rb); 
    else
        if ~isequal(shiftDurs_ms(end), ',')
            shiftDurs_ms = [shiftDurs_ms, ','];
        end

        idx_cm = strfind(shiftDurs_ms(idx1 + length(tt) + 1 : end), ',');
        idx_cm = idx_cm(1);
        t_val = shiftDurs_ms(idx1 + length(tt) + 1 : idx1 + length(tt) + idx_cm - 1);        
    end

    if ~isempty(strfind(t_val, '-'))
        error('Unrecognized format in PITCH_SHIFT_DURS_MS')
    end
    t_vals = splitstring(t_val, ',');

    if length(t_vals) == 1
        a_shiftDurs_ms.(tt) = repmat(str2double(t_vals{1}), 1, a_numShifts.(tt));
    elseif length(t_vals) == a_numShifts.(tt)
        a_shiftDurs_ms.(tt) = [];
        for i2 = 1 : a_numShifts.(tt)
            a_shiftDurs_ms.(tt)(end + 1) = str2double(t_vals{i2});
        end
    else
        error('Erroneous number of pitch shift duration for shift type %s', tt);
    end
    
    %--- Check that the number of Inf is not > 1 ---%
    if ~isempty(find(isinf(a_shiftDurs_ms.(tt)), 1)) && length(a_shiftDurs_ms.(tt)) > 1
        error('More than one Inf (duration of whole vowel) exist in shift duration of shift type %s', tt);
    end
end

%% Structure: perturbation design (pertDes)
pertDes = struct;

if isempty(fullSchedFN)
    pertDes.nBlocks = nBlocks;
    pertDes.trialsPerBlock = trialsPerBlock;
else
    pertDes.nBlocks = 1;
    pertDes.trialsPerBlock = length(sched);
end
pertDes.nTrialTypes = numel(a_trialTypes);
pertDes.trialTypes = a_trialTypes;
pertDes.trialTypesPert = a_trialTypesPert;
pertDes.nTrialsPerBlock = a_nTrialsPerBlock;
pertDes.onsetDelays = a_onsetDelays;
pertDes.numShifts = a_numShifts;
pertDes.interShiftDelays = a_interShiftDelays;
pertDes.pitchShifts_cent = a_pitchShifts_cent;
pertDes.intShifts_dB = a_intShifts_dB;
pertDes.F1Shifts_ratio = a_F1Shifts_ratio;
pertDes.F2Shifts_ratio = a_F2Shifts_ratio;
pertDes.shiftDurs_ms = a_shiftDurs_ms;

%     pertDes = struct;
%     pertDes.nBlocks = 1;
%     pertDes.trialsPerBlock = length(sched);
%     pertDes.nTrialTypes = length(unique(sched));
%     pertDes.trialTypes = unique(sched);
% end

%% Generate the actual phase script
nNoPertTypes = length(fsic(a_trialTypes, 'ctrl')) + length(fsic(a_trialTypes, 'baseline'));

phaseScript = struct();

phaseScript.nReps = pertDes.nBlocks;
phaseScript.nTrials = 0;

prevPertPos = -Inf;
for n = 1 : pertDes.nBlocks
    if isempty(fullSchedFN)
        wordsUsed = {};
        while (length(wordsUsed) < trialsPerBlock)
            nToGo = trialsPerBlock - length(wordsUsed);
            if (nToGo >= length(stimUtters))
                wordsUsed = [wordsUsed, stimUtters(randperm(length(stimUtters)))];
            elseif (nToGo > 0)
                idx = randperm(length(stimUtters));
                wordsUsed = [wordsUsed, stimUtters(randperm(nToGo))];
            end
        end
    else
        wordsUsed = repmat(stimUtters, 1, pertDes.trialsPerBlock);
    end
    
%     wordsUsed = wordsUsed(randperm(length(wordsUsed)));
%     bt = zeros(1, length(wordsUsed));
    
%     pseudoWordsUsed=pseudoWords(randperm(length(pseudoWords)));
%             testWordsUsed2=testWords(randperm(length(testWords)));            
%     twCnt = 1;
%     bt = bt(randperm(length(bt)));
    oneRep = struct;
    
    if isempty(fullSchedFN)
        oneRep.trialOrder = [];
        if minDistBetwShifts > 0
            nPad = max([0, prevPertPos + minDistBetwShifts + 1]);
            trialOrder_pre = repmat(0, 1, nPad);
        else
            nPad = 0;
            trialOrder_pre = [];
        end

        for i1 = 1 : pertDes.nTrialTypes
            if i1 == 1
                oneRep.trialOrder = [oneRep.trialOrder, repmat(i1 - 1, 1, pertDes.nTrialsPerBlock(i1) - nPad)];
            else
                oneRep.trialOrder = [oneRep.trialOrder, repmat(i1 - 1, 1, pertDes.nTrialsPerBlock(i1))];
            end
        end

        bOkay = 0;
        while ~bOkay
            oneRep.trialOrder = oneRep.trialOrder(randperm(length(oneRep.trialOrder)));
          
            idxPert = find(oneRep.trialOrder >= nNoPertTypes);
            distPert = diff(idxPert) - 1;

            bOkay = isempty(find(distPert < minDistBetwShifts, 1));
        end

        oneRep.trialOrder = [trialOrder_pre, oneRep.trialOrder];
        
        if minDistBetwShifts > 0
            prevPertPos = find(oneRep.trialOrder);
            prevPertPos = prevPertPos(end) - length(oneRep.trialOrder) - 1;
        end

        oneRep.trialOrder = num2cell(oneRep.trialOrder);
        for i1 = 1 : length(oneRep.trialOrder)
%             if oneRep.trialOrder{i1} == 0
            if ~bSust
                oneRep.trialOrder{i1} = a_trialTypes{oneRep.trialOrder{i1} + 1};
%                 oneRep.trialOrder{i1} = pertDes.trialTypesPert{oneRep.trialOrder{i1}};
%                     oneRep.trialOrder{i1} = 'ctrl';
            else
                oneRep.trialOrder{i1} = 'sust';
            end
%             else
                
%             end
        end
    
    else
        oneRep.trialOrder = sched;
    end
        
    
    %-- Details of pitch shift --%
    nt = length(oneRep.trialOrder);
    oneRep.word = wordsUsed;
    oneRep.pitchShifts_cent = cell(1, nt);
    oneRep.intShifts_dB = cell(1, nt);
    oneRep.F1Shifts_ratio = cell(1, nt);
    oneRep.F2Shifts_ratio = cell(1, nt);
    oneRep.shifts_onset = cell(1, nt);
    oneRep.shiftDurs_ms = cell(1, nt);
%     oneRep.onsetTimes = cell(1, nt);

    %-- Use random symbols to replace the characters in baseline trials --%
    idxBL = fsic(oneRep.trialOrder, 'baseline');
    for j1 = 1 : numel(idxBL)
        oneRep.word{idxBL(j1)} = char_symbol(oneRep.word{idxBL(j1)});
    end
    
    if bSust 
        if isequal(phase, 'start') || isequal(phase, 'end')
            pertScale = 0.0;
        elseif isequal(phase, 'ramp')
            pertScale = n / (pertDes.nBlocks + 1);
        elseif (length(phase) >= 4) && isequal(phase(1 : 4), 'stay')
            pertScale = 1.0;
        end
    else
        pertScale = 1.0;
    end

    for i1 = 1 : nt
        tt = oneRep.trialOrder{i1};
        if isequal(tt, 'ctrl') || isequal(tt, 'baseline')
            continue;
        end
        
        ns = pertDes.numShifts.(tt);
        oneRep.pitchShifts_cent{i1} = nan(1, ns);
        oneRep.intShifts_dB{i1} = nan(1, ns);
        oneRep.F1Shifts_ratio{i1} = nan(1, ns);
        oneRep.F2Shifts_ratio{i1} = nan(1, ns);
        for i2 = 1 : length(oneRep.pitchShifts_cent{i1})
            %- Amount (cents) of pitch shift -%
            oneRep.pitchShifts_cent{i1}(i2) = pertScale * pertDes.pitchShifts_cent.(tt)(i2);
            
            %- Amount (dB) of intensity shift -%
            oneRep.intShifts_dB{i1}(i2) = pertScale * pertDes.intShifts_dB.(tt)(i2);
            
            %- Amount (ratio) of F1 shift -%
            oneRep.F1Shifts_ratio{i1}(i2) = pertScale * pertDes.F1Shifts_ratio.(tt)(i2);
            
            %- Amount (ratio) of F2 shift -%
            oneRep.F2Shifts_ratio{i1}(i2) = pertScale * pertDes.F2Shifts_ratio.(tt)(i2);
        end
        
        
        %- Duration of pitch shift -%
        oneRep.shiftDurs_ms{i1} = nan(1, ns);
        for i2 = 1 : length(oneRep.shiftDurs_ms{i1})
            oneRep.shiftDurs_ms{i1}(i2) = pertDes.shiftDurs_ms.(tt)(i2);
        end
        
        oneRep.shifts_onset{i1} = nan(1, ns);
        rng_onsetDelay = pertDes.onsetDelays.(tt){randi(length(pertDes.onsetDelays.(tt)))};
        
        oneRep.shifts_onset{i1}(1) = rng_onsetDelay(1) + range(rng_onsetDelay) * rand;
        
        rng_isd = pertDes.interShiftDelays.(tt){randi(length(pertDes.interShiftDelays.(tt)))};
        for i2 = 2 : length(oneRep.shifts_onset{i1})
            oneRep.shifts_onset{i1}(i2) = ...
                oneRep.shifts_onset{i1}(i2 - 1) + rng_isd(1) + range(rng_isd) * rand ...
                + oneRep.shiftDurs_ms{i1}(i2 - 1);
        end
    end
       
    phaseScript.(['rep', num2str(n)]) = oneRep;
    phaseScript.nTrials = phaseScript.nTrials + length(oneRep.trialOrder);
end

return

function str1 = strip_brackets(str0, errMsg)
str1 = strrep(deblank(str0), ' ', '');
if length(str1) <= 3 || ...
   ~isequal(str1(1), '{') || ~isequal(str1(end), '}')
    error(errMsg);
end
str1 = str1(2 : end - 1);
return

function idx1 = prune_strfind(idx, str, subStr, matchChar)
idx1 = [];
for i2 = 1 : numel(idx)
    if idx(i2) + length(subStr) <= length(str) && isequal(str(idx(i2) + length(subStr)), matchChar)
        idx1(end + 1) =idx(i2);
    end
end
return

function a_shifts = get_shift_values(inShifts, a_trialTypesPert, a_numShifts, fieldName)
a_shifts = struct;

inShifts = strip_brackets(inShifts, ...
                                  sprintf('Wrong format in field %s', fieldName));

for i1 = 1 : numel(a_trialTypesPert)
    tt = a_trialTypesPert{i1};
    idx1 = strfind(inShifts, tt);
    if isempty(idx1)
        error('Cannot find trial type %s in %s', tt, fieldName);
    end

    %-- Prune the strfind results --%
    idx1 = prune_strfind(idx1, inShifts, tt, '-');
    if length(idx1) ~= 1
        error('Duplicate items found in %s', fieldName);
    end

    %-- Search for the end --%
    if length(inShifts) < idx1 + length(tt) + 1 || ~isequal(inShifts(idx1 + length(tt)), '-')
        error('Unrecognized format in %s', fieldName);
    end

    if isequal(inShifts(idx1 + length(tt) + 1), '[')
        idx_rb = strfind(inShifts(idx1 + length(tt) + 2 : end), ']');

        if isempty(idx_rb)
            error('Unrecognized format in %s', fieldName);
        end
        idx_rb = idx_rb(1);

        t_val = inShifts(idx1 + length(tt) + 2 : idx1 + length(tt) + idx_rb); 
    else
        if ~isequal(inShifts(end), ',')
            inShifts = [inShifts, ','];
        end

        idx_cm = strfind(inShifts(idx1 + length(tt) + 1 : end), ',');
        idx_cm = idx_cm(1);
        t_val = inShifts(idx1 + length(tt) + 1 : idx1 + length(tt) + idx_cm - 1);        
    end

%     if ~isempty(strfind(t_val, '-'))
%         error('Unrecognized format in PITCH_SHIFTS_CENT')
%     end
    t_vals = splitstring(t_val, ',');

    if length(t_vals) == 1
        a_shifts.(tt) = repmat(str2double(t_vals{1}), 1, a_numShifts.(tt));
    elseif length(t_vals) == a_numShifts.(tt)
        a_shifts.(tt) = [];
        for i2 = 1 : a_numShifts.(tt)
            a_shifts.(tt)(end + 1) = str2double(t_vals{i2});
        end
    else
        error('Erroneous number of %s amounts for shift type %s', fieldName, tt);
    end
end

return