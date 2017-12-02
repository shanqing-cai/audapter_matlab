function time_domain_shift_demo(pitchGender, isOnline, varargin)
%% Offline and online demo for time-domain pitch shifting.
% Usage examples:
% - For offline demo:
%   time_domain_shift_demo('female', 0, '--wav', 'C:\speechres\samples\dante\Pilot22SF2Trial5_micIn.wav', '--play');
%   time_domain_shift_demo('male', 0, '--wav', 'C:\speechres\samples\dante\Pilot26SF3Trial4_micIn.wav', '--play');
%  
% - For online demo:
%   time_domain_shift_demo('male', 1);
%   time_domain_shift_demo('female', 1);

%% Input parameter sanity check and processing.
if isempty(fsic({'female', 'male'}, pitchGender))
    error('Invalid value in pitchGender: %s', pitchGender);
end

if ~isOnline
    if ~isempty(fsic(varargin, '--wav'))
        inputWav = varargin{fsic(varargin, '--wav') + 1};
    else
        error('--wav <WAV_FILE_PATH> not provided for online demo.');
    end
end

toPlay = ~isempty(fsic(varargin, '--play'));

%% Get parameters for time-domain shifting.
params = getAudapterDefaultParams(pitchGender);

% Activate time-domain pitch shifting.
params.bTimeDomainShift = 1;

% Set the a priori pitch ranges.
% Adjust if necessary. You may even consider adjust this on a per-subject
% basis! The more accurate the a prior estimate, the lower the likelihood
% of incorrect real-time pitch tracking leading to occasional artifacts in
% the pitch shifted feedback.
if isequal(lower(pitchGender), 'female')
    params.pitchLowerBoundHz = 150;
    params.pitchUpperBoundHz = 300;
elseif isequal(lower(pitchGender), 'male')
    params.pitchLowerBoundHz = 80;
    params.pitchUpperBoundHz = 200;
end

% Use a long-enough frame length (and hence spectral/cepstral) window to
% ensure accurate real-time pitch tracking.
params.frameLen = 64;
params.nDelay = 7;
% Time-domain shift requires bCepsLift = 1.
params.bCepsLift = 1;

params.timeDomainPitchShiftSchedule = [0, 1.0; 1, 1.0; 2, 1.0595];

AudapterIO('init', params);
AudapterIO('reset');   % Reset;

if ~isOnline
    %% Offline demo: load and process input sound from wav file.
    fsNoDownsample = params.sr * params.downFact;
    frameLenNoDownsample = params.frameLen * params.downFact;

    [w, wfs] = audioread(inputWav);
    sigIn = resample(w, fsNoDownsample, wfs);
    sigIn = sigIn - mean(sigIn);
    sigInCell = makecell(sigIn, frameLenNoDownsample);

    tic;
    for n = 1 : length(sigInCell)
        Audapter('runFrame', sigInCell{n});
    end
    elapsed = toc;
    fprintf( ...
        'Offline demo: Processing %.3f s of input audio took %.3f s.\n', ...
        length(w) / wfs, elapsed);
else
    %% Online demo.
    Audapter('start');
    pause(4);
    Audapter('stop');
    
end

%% Visualize data.
data = AudapterIO('getData');

frameDur = data.params.frameLen / data.params.sr;
tAxis = 0 : frameDur : frameDur * (size(data.fmts ,1) - 1);
% get the formant plot bounds
[i1, i2, ~, ~, ~, ~] = getFmtPlotBounds( ...
    data.fmts(:, 1), data.fmts(:, 2));

figure('Position', [200, 200, 800, 400]);
[s, f, t] = spectrogram(data.signalIn, 64, 48, 1024, data.params.sr);
colormap jet;
[s2, f2, t2] = spectrogram(data.signalOut, 64, 48, 1024, data.params.sr);
colormap jet;

subplot(211);
imagesc(t, f, 10 * log10(abs(s))); 
hold on;
axis xy;
plot(tAxis, data.fmts(:, 1 : 2), 'w', 'LineWidth', 2);
set(gca, 'YLim', [0, 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Original');

subplot(212);
imagesc(t2, f2, 10 * log10(abs(s2)));
hold on;
axis xy;
plot(tAxis, data.fmts(:, 1 : 2), 'w', 'LineWidth', 2);
plot(tAxis, data.sfmts(:, 1 : 2), 'g--', 'LineWidth', 2);
set(gca, 'XLim', [tAxis(i1), tAxis(i2)]);
set(gca, 'YLim', [0, 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Shifted');

figure;
hold on;
sigTAxis1 = 0 : 1 / data.params.sr : ...
    1 / data.params.sr * (length(data.signalIn) - 1);
plot(sigTAxis1, data.signalIn, 'b-');
ylabel('Input waveform');
xlabel('Time (s)');

sigTAxis2 = 0 : 1 / data.params.sr : ...
    1 / data.params.sr * (length(data.signalOut) - 1);
plot(sigTAxis2, data.signalOut, 'r-');
legend({'Input', 'Output'});
ylabel('Output waveform');
xlabel('Time (s)');

figure;
plot(tAxis, data.pitchHz, 'b-');
hold on;
plot(tAxis, data.shiftedPitchHz, 'r-');
legend({'Input', 'Output'});
xlabel('Time (s)');
ylabel('Pitch (Hz)');

%% Play input and output sound.
if toPlay
    drawnow;
    play_audio(data.signalIn, data.params.sr);
    play_audio(data.signalOut, data.params.sr);
end

end


