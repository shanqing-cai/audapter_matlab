function play_prompt(msg, audioDir, gain)
if ~isdir(audioDir)
    error('Audio directory not found: %s', audioDir)
end
d = dir(fullfile(audioDir, '*.wav'));

if ~isempty(strfind(msg, 'louder'))
    keyword = 'louder';
elseif ~isempty(strfind(msg, 'softer'))
    keyword = 'softer';
elseif ~isempty(strfind(msg, 'longer'))
    keyword = 'longer';
elseif ~isempty(strfind(msg, 'shorter'))
    keyword = 'shorter';
else
    fprintf('play_prompt: WARNING: unrecognized msg\n');
    return
end

if (~isempty(strfind(msg, 'louder')) || ~isempty(strfind(msg, 'softer')) || ...
   ~isempty(strfind(msg, 'longer')) || ~isempty(strfind(msg, 'shorter')))
    if ~isempty(strfind(msg, 'little'))
        bLittle = 1;
    else
        bLittle = 0;
    end
end

fns = {};
for i1 = 1 : numel(d)
    if ~isempty(strfind(d(i1).name, keyword))
        if bLittle == 0
            if isempty(strfind(d(i1).name, 'little'))
                fns{end + 1} = d(i1).name;
            end
        else
            if ~isempty(strfind(d(i1).name, 'little'))
                fns{end + 1} = d(i1).name;
            end
        end
    end
end

if isempty(fns)
    error('Cannot find wav files coresponding to the message %s in directory %s', ...
          msg, audioDir)
end

if numel(fns) > 1
    idx = randperm(numel(fns));
    idx = idx(1);
    wavfn = fns{idx};
else
    wavfn = fns{1};
end

if ~exist('gain')
    gain = 1;
end
play_wav(fullfile(audioDir, wavfn), gain);
return

