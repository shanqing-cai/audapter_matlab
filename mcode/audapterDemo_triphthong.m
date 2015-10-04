function audapterDemo_triphthong(varargin)
%% Config
gender = 'female';

toPlay = ~isempty(fsic(varargin, '--play')) || ~isempty(fsic(varargin, '-p'));

downFact = 3; % Downsampling factor
fsNoDS = 48000; % Sampling rate, before downsampling
frameLenNoDS = 96;  % Frame length before downsampling (# of samples)
nLPC = 17;  % Order of linar prediction (LP)

%% Set default parameters
p=getAudapterDefaultParams(gender);
AudapterIO('init', p);    % Initialize

%% Load the utterance data
utterFileName=fullfile('../example_data', ['diao1_',gender,'.mat']);
check_file(utterFileName);

load(utterFileName);  % gives data

data.params.LBk = 0;
data.params.LBb = 0;
fs = data.params.sr;
sigIn = data.signalIn;

sigIn = resample(sigIn, fsNoDS, data.params.sr);     
sigInCell = makecell(sigIn, frameLenNoDS);

AudapterIO('reset');   % Reset;

%%
data.params.downFact = downFact;
data.params.sr = fsNoDS / downFact;
data.params.frameLen = frameLenNoDS / downFact;
data.params.nLPC = nLPC;

data.params.bRatioShift = 0;
data.params.bMelShift = 0;

% Nullify OST and PCF, so that they won't override the perturbation field
Audapter('ost', '', 0);
Audapter('pcf', '', 0);

AudapterIO('init', data.params); % Set speaker-specific parameters

%% Run TransShiftMex over the input signal
for n = 1 : length(sigInCell)
    Audapter('runFrame', sigInCell{n});
end

data1 = AudapterIO('getData');

%% Spectrogram with estimated formants overlaid
frameDur = data1.params.frameLen / data1.params.sr;
taxis2 = 0 : frameDur : frameDur * (size(data1.fmts ,1) - 1);
% get the formant plot bounds
[i1, i2, ~, ~, iv1, iv2] = getFmtPlotBounds(data1.fmts(:, 1), data1.fmts(:, 2));

figure('Position',[200,200,800,400]);
[s, f, t]=spectrogram(data1.signalIn, 64, 48, 1024, data1.params.sr);
colormap jet;
[s2, f2, t2]=spectrogram(data1.signalOut, 64, 48, 1024, data1.params.sr);
colormap jet;
subplot(121);
imagesc(t, f, 10 * log10(abs(s)));  hold on;
axis xy;
plot(taxis2, data1.fmts(:, 1 : 2), 'w', 'LineWidth', 2);
set(gca, 'XLim', [taxis2(i1), taxis2(i2)]);
set(gca, 'YLim', [0, 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Original');

subplot(122);
imagesc(t2, f2, 10 * log10(abs(s2))); hold on;
axis xy;
plot(taxis2, data1.fmts(:, 1 : 2), 'w', 'LineWidth', 2);
plot(taxis2, data1.sfmts(:,1 : 2), 'g--', 'LineWidth', 2);
set(gca, 'XLim', [taxis2(i1), taxis2(i2)]);
set(gca, 'YLim', [0, 4000]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Shifted');

%%
if (toPlay)
    drawnow;
    play_audio(data1.signalIn, data1.params.sr);    
    play_audio(data1.signalOut, data1.params.sr);
end

return