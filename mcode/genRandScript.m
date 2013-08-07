function [phaseScript, pertDes] = genRandScript(nBlocks, trialsPerBlock, ...
                                     trialTypes, minDistBetwShifts, ...
                                     onsetDelays_ms, numShifts, ...
                                     interShiftDelays_ms, pitchShifts_cent, ...
                                     pitchShifts_ms, stimUtters)
%% 
check_pos_int(nBlocks, 'N_BLOCKS must be a positive integer');
check_pos_int(trialsPerBlock, 'TRIALS_PER_BLOCK must be a positive integer');


%% trialTypes
a_trialTypes = {};
a_trialTypeIsPert = [];
a_nTrialsPerBlock = [];

trialTypes = strip_brackets(trialTypes, 'Wrong format in field TRIAL_TYPES_IN_BLOCK');
t_items = splitstring(trialTypes, ',');

for i1 = 1 : numel(t_items)
    if length(strfind(t_items{i1}, '-')) ~= 1
        error('Wrong format in item #%d of TRIAL_TYPES_IN_BLOCK: %s', ...
              i1, t_items{i1});
    end
    
    t_strs = splitstring(t_items{i1}, '-');
    a_trialTypes{end + 1} = t_strs{2};
    a_trialTypeIsPert(end + 1) = ~isequal(lower(a_trialTypes{end}), 'ctrl');
    a_nTrialsPerBlock(end + 1) = str2double(t_strs{1});
    
    check_pos_int(a_nTrialsPerBlock(end), ...
                  'Number of trials in TRIAL_TYPES_IN_BLOCK must be positive integers', 1); % Allow zero
end

if length(unique(a_trialTypes)) ~= length(a_trialTypes)
    error('Duplicate items in TRIAL_TYPES_IN_BLOCK');
end

idxCtrl = fsic(a_trialTypes, 'ctrl');
if length(idxCtrl) == 0
    error('It is mandatory that ctrl is in TRIAL_TYPES_IN_BLOCK, although the number may be set to zero if necessary.');
end

%--- Make sure that ctrl is first in list ---%
idxOrd = [idxCtrl, setxor(1 : length(a_trialTypes), idxCtrl)];
a_trialTypes = a_trialTypes(idxOrd);
a_trialTypeIsPert = a_trialTypeIsPert(idxOrd);
a_nTrialsPerBlock = a_nTrialsPerBlock(idxOrd);

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
a_pitchShifts_cent = struct;

pitchShifts_cent = strip_brackets(pitchShifts_cent, 'Wrong format in field ONSET_DELAYS_MS');

for i1 = 1 : numel(a_trialTypesPert)
    tt = a_trialTypesPert{i1};
    idx1 = strfind(pitchShifts_cent, tt);
    if isempty(idx1)
        error('Cannot find trial type %s in PITCH_SHIFTS_CENT', tt);
    end
    
    %-- Prune the strfind results --%
    idx1 = prune_strfind(idx1, pitchShifts_cent, tt, '-');
    if length(idx1) ~= 1
        error('Duplicate items found in PITCH_SHIFTS_CENT');
    end
    
    %-- Search for the end --%
    if length(pitchShifts_cent) < idx1 + length(tt) + 1 || ~isequal(pitchShifts_cent(idx1 + length(tt)), '-')
        error('Unrecognized format in PITCH_SHIFTS_CENT');
    end
    
    if isequal(pitchShifts_cent(idx1 + length(tt) + 1), '[')
        idx_rb = strfind(pitchShifts_cent(idx1 + length(tt) + 2 : end), ']');
        
        if isempty(idx_rb)
            error('Unrecognized format in PITCH_SHIFTS_CENT');
        end
        idx_rb = idx_rb(1);
        
        t_val = pitchShifts_cent(idx1 + length(tt) + 2 : idx1 + length(tt) + idx_rb); 
    else
        if ~isequal(pitchShifts_cent(end), ',')
            pitchShifts_cent = [pitchShifts_cent, ','];
        end
        
        idx_cm = strfind(pitchShifts_cent(idx1 + length(tt) + 1 : end), ',');
        idx_cm = idx_cm(1);
        t_val = pitchShifts_cent(idx1 + length(tt) + 1 : idx1 + length(tt) + idx_cm - 1);        
    end
    
%     if ~isempty(strfind(t_val, '-'))
%         error('Unrecognized format in PITCH_SHIFTS_CENT')
%     end
    t_vals = splitstring(t_val, ',');
    
    if length(t_vals) == 1
        a_pitchShifts_cent.(tt) = repmat(str2double(t_vals{i1}), 1, a_numShifts.(tt));
    elseif length(t_vals) == a_numShifts.(tt)
        a_pitchShifts_cent.(tt) = [];
        for i2 = 1 : a_numShifts.(tt)
            a_pitchShifts_cent.(tt)(end + 1) = str2double(t_vals{i2});
        end
    else
        error('Erroneous number of pitch shift amounts for shift type %s', tt);
    end
end

%% pitchShifts_cent
a_pitchShifts_ms = struct;

pitchShifts_ms = strip_brackets(pitchShifts_ms, 'Wrong format in field ONSET_DELAYS_MS');

for i1 = 1 : numel(a_trialTypesPert)
    tt = a_trialTypesPert{i1};
    idx1 = strfind(pitchShifts_ms, tt);
    if isempty(idx1)
        error('Cannot find trial type %s in PITCH_SHIFT_DURS_MS', tt);
    end
    
    %-- Prune the strfind results --%
    idx1 = prune_strfind(idx1, pitchShifts_ms, tt, '-');
    if length(idx1) ~= 1
        error('Duplicate items found in PITCH_SHIFT_DURS_MS');
    end
    
    %-- Search for the end --%
    if length(pitchShifts_ms) < idx1 + length(tt) + 1 || ~isequal(pitchShifts_ms(idx1 + length(tt)), '-')
        error('Unrecognized format in PITCH_SHIFT_DURS_MS');
    end
    
    if isequal(pitchShifts_ms(idx1 + length(tt) + 1), '[')
        idx_rb = strfind(pitchShifts_ms(idx1 + length(tt) + 2 : end), ']');
        
        if isempty(idx_rb)
            error('Unrecognized format in PITCH_SHIFT_DURS_MS');
        end
        idx_rb = idx_rb(1);
        
        t_val = pitchShifts_ms(idx1 + length(tt) + 2 : idx1 + length(tt) + idx_rb); 
    else
        if ~isequal(pitchShifts_ms(end), ',')
            pitchShifts_ms = [pitchShifts_ms, ','];
        end
        
        idx_cm = strfind(pitchShifts_ms(idx1 + length(tt) + 1 : end), ',');
        idx_cm = idx_cm(1);
        t_val = pitchShifts_ms(idx1 + length(tt) + 1 : idx1 + length(tt) + idx_cm - 1);        
    end
    
    if ~isempty(strfind(t_val, '-'))
        error('Unrecognized format in PITCH_SHIFT_DURS_MS')
    end
    t_vals = splitstring(t_val, ',');
    
    if length(t_vals) == 1
        a_pitchShifts_ms.(tt) = repmat(str2double(t_vals{i1}), 1, a_numShifts.(tt));
    elseif length(t_vals) == a_numShifts.(tt)
        a_pitchShifts_ms.(tt) = [];
        for i2 = 1 : a_numShifts.(tt)
            a_pitchShifts_ms.(tt)(end + 1) = str2double(t_vals{i2});
        end
    else
        error('Erroneous number of pitch shift duration for shift type %s', tt);
    end
end

%% Structure: perturbation design (pertDes)
pertDes = struct;
pertDes.nBlocks = nBlocks;
pertDes.trialsPerBlock = trialsPerBlock;
pertDes.nTrialTypes = numel(a_trialTypes);
pertDes.trialTypes = a_trialTypes;
pertDes.trialTypesPert = a_trialTypesPert;
pertDes.nTrialsPerBlock = a_nTrialsPerBlock;
pertDes.onsetDelays = a_onsetDelays;
pertDes.numShifts = a_numShifts;
pertDes.interShiftDelays = a_interShiftDelays;
pertDes.pitchShifts_cent = a_pitchShifts_cent;
pertDes.pitchShifts_ms = a_pitchShifts_ms;

%%
phaseScript = struct();
phaseScript.nReps = nBlocks;
phaseScript.nTrials = 0;

prevPertPos = -Inf;
for n = 1 : nBlocks
    wordsUsed = {};
    while (length(wordsUsed) < trialsPerBlock)
        nToGo = trialsPerBlock - length(wordsUsed);
        if (nToGo >= length(stimUtters))
            wordsUsed = [wordsUsed, stimUtters(randperm(length(stimUtters)))];
        elseif (nToGo > 0)
            idx = randperm(length(words));
            wordsUsed = [wordsUsed, stimUtters(randperm(nToGo))];
        end
    end
    
%     wordsUsed = wordsUsed(randperm(length(wordsUsed)));
    bt = zeros(1, length(wordsUsed));
    
%     pseudoWordsUsed=pseudoWords(randperm(length(pseudoWords)));
%             testWordsUsed2=testWords(randperm(length(testWords)));            
    twCnt = 1;
    bt = bt(randperm(length(bt)));
    oneRep = struct;
    
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
        
        idxPert = find(oneRep.trialOrder);
        distPert = diff(idxPert) - 1;
        
        bOkay = isempty(find(distPert < minDistBetwShifts, 1));
    end
    
    oneRep.trialOrder = [trialOrder_pre, oneRep.trialOrder];
    
    prevPertPos = find(oneRep.trialOrder);
    prevPertPos = prevPertPos(end) - length(oneRep.trialOrder) - 1;
    
    oneRep.trialOrder = num2cell(oneRep.trialOrder);
    for i1 = 1 : length(oneRep.trialOrder)
        if oneRep.trialOrder{i1} == 0
            oneRep.trialOrder{i1} = 'ctrl';
        else
            oneRep.trialOrder{i1} = pertDes.trialTypesPert{oneRep.trialOrder{i1}};
        end
    end
    
    %-- Details of pitch shift --%
    nt = length(oneRep.trialOrder);
    oneRep.word = wordsUsed;
    oneRep.pitchShifts_cent = cell(1, nt);
    oneRep.pitchShifts_onset = cell(1, nt);
    oneRep.pitchShifts_dur = cell(1, nt);
%     oneRep.onsetTimes = cell(1, nt);

    for i1 = 1 : nt
        tt = oneRep.trialOrder{i1};
        if isequal(tt, 'ctrl')
            continue;
        end
        
        %- Amount (cents) of pitch shift -%
        ns = pertDes.numShifts.(tt);
        oneRep.pitchShifts_cent{i1} = nan(1, ns);
        for i2 = 1 : length(oneRep.pitchShifts_cent{i1})
            oneRep.pitchShifts_cent{i1}(i2) = pertDes.pitchShifts_cent.(tt)(i2);
        end
        
        %- Duration of pitch shift -%
        oneRep.pitchShifts_dur{i1} = nan(1, ns);
        for i2 = 1 : length(oneRep.pitchShifts_dur{i1})
            oneRep.pitchShifts_dur{i1}(i2) = pertDes.pitchShifts_ms.(tt)(i2);
        end
        
        oneRep.pitchShifts_onset{i1} = nan(1, ns);
        rng_onsetDelay = pertDes.onsetDelays.(tt){randi(length(pertDes.onsetDelays.(tt)))};
        
        oneRep.pitchShifts_onset{i1}(1) = rng_onsetDelay(1) + range(rng_onsetDelay) * rand;
        
        rng_isd = pertDes.interShiftDelays.(tt){randi(length(pertDes.interShiftDelays.(tt)))};
        for i2 = 2 : length(oneRep.pitchShifts_onset{i1})
            oneRep.pitchShifts_onset{i1}(i2) = ...
                oneRep.pitchShifts_onset{i1}(i2 - 1) + rng_isd(1) + range(rng_isd) * rand ...
                + oneRep.pitchShifts_dur{i1}(i2 - 1);
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