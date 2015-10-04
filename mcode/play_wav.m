function play_wav(wavFN, gain)
MAX_PB_SIZE = 120000;
fs1 = 48000;
rampDur = 0.1;

[w, fs0] = read_audio(wavFN);
w = resample(w, fs1, fs0);

if length(w) > MAX_PB_SIZE
    fprintf('play_wav: WARNING: waveform truncated by %d samples (%f s)\n', ...
            length(w) - MAX_PB_SIZE, (length(w) - MAX_PB_SIZE) / fs1);
    w = w(1 : MAX_PB_SIZE);
    
else
    w = [w; zeros(MAX_PB_SIZE - length(w), 1)];
end
dur = length(w) / fs1;

if ~exist('gain')
    gain = 1;
end
w = gain * w;

%% Apply linear ramps
rampN = rampDur * fs1;
for i1 = 1 : rampN
    w(i1) = w(i1) * (i1 - 1) / rampN;
    w(end - i1) = w(end - i1) * (i1 - 1) / rampN;
end
% ~Apply linear ramps

Audapter(3, 'datapb', w, 0);
Audapter(12);
pause(dur);
Audapter(2);
return