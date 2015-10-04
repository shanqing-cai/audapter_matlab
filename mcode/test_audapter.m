function test_audapter(varargin)
%% CONFIG
exampleDataFN = '../example_data/trial-1-2.mat';

OST_MULT = 500;

%% Process input arguments
pertMode = 'formant';
if nargin >= 1
    pertMode = varargin{1};
end

bPlay = 0;
if ~isempty(fsic(varargin, '--play'))
    bPlay = 1;
end

%%
load(exampleDataFN);
assert(exist('data', 'var') == 1);

p = data.params;

%% Setting ost and pcf
ost_fn = '../example_data/ost'; % Online sentence tracking (OST) configuration file

% Perturbation configuration (PCF) file
if isequal(pertMode, 'formant')
    pcf_fn = '../example_data/fmt_pert.pcf';
elseif isequal(pertMode, 'pitch')
    pcf_fn = '../example_data/pitch_pert.pcf';
elseif isequal(pertMode, 'timeWarp')
    pcf_fn = '../example_data/timeWarp_pert.pcf';
elseif isequal(pertMode, 'debug')    % DEBUG
    pcf_fn = '../example_data/time_warp_demo.pcf';
else
    error('Unrecognized perturbation mode: %s', pertMode);
end

%%
p.bDetect = 1;
p.rmsThresh = 0.01;
p.bShift = 1;
p.bRatioShift = 1;
p.bBypassFmt = 0;           % === Important === %

if isequal(pertMode, 'pitch') || isequal(pertMode, 'timeWarp') ...
        || isequal(pertMode, 'debug')
    p.bPitchShift = 1;          % === Important === %
else
    p.bPitchShift = 0;          % === Important === %
end

check_file(ost_fn);
check_file(pcf_fn);

Audapter('ost', ost_fn, 0);
Audapter('pcf', pcf_fn, 0);

% Audapter('setParam', 'bbypassfmt', 0, 1); 

%% Load the multi-talker babble noise
[mbw, fs_mtb] = read_audio('mtbabble48k.wav');

% Normalize the amplitude of the mtb noise
mbw = mbw - mean(mbw);
mb_rms = rms(mbw);
mbw = mbw / mb_rms;

if length(mbw) > Audapter('getMaxPBLen')
    mbw = mbw(1 : Audapter('getMaxPBLen'));
end

Audapter('setParam', 'datapb', mbw, 0);

rmsNoise = dBSPL2WaveAmp(-Inf);
p.fb3Gain = rmsNoise;
p.fb = 1;

%%
fs = data.params.sr;

sigIn = data.signalIn;

% sigIn = resample(sigIn, data.params.sr * data.params.downFact, fs);
sigIn = resample(sigIn, data.params.sr * data.params.downfact, fs);
% sigInCell = makecell(sigIn, data.params.frameLen * data.params.downFact);
sigInCell = makecell(sigIn, data.params.frameLen * data.params.downfact);

p.rmsClipThresh=0.01;
p.bRMSClip=1;

if ~isempty(fsic(varargin, '--nLPC'))
    p.nLPC = varargin{fsic(varargin, '--nLPC') + 1};
end

AudapterIO('init', p);

Audapter('setParam', 'rmsthr', 5e-3, 0);

Audapter('reset');

for n = 1 : length(sigInCell)
    Audapter('runFrame', sigInCell{n});
end

data1 = AudapterIO('getData');


%% Visualization: input sound
figure('Position', [100, 100, 1400, 600], 'Name', 'Input spectrogram');
% subplot('Position', [0.05, 0.1, 0.45, 0.8]);
show_spectrogram(data1.signalIn, fs, 'noFig');
frameDur = data1.params.frameLen / data1.params.sr;
tAxis = 0 : frameDur : frameDur * (size(data1.fmts, 1) - 1);

if isequal(pertMode, 'formant');
    plot(tAxis, data1.fmts(:, 1 : 2), 'b');
end

frameDur = data.params.frameLen / data.params.sr;
tAxis = 0 : frameDur : frameDur * (size(data.rms, 1) - 1);
plot(tAxis, data1.ost_stat * OST_MULT, 'k-');

if isequal(pertMode, 'formant')
    legend({'F1 (original)', 'F2 (oringina)', sprintf('OST status * %d', OST_MULT)});
else
    legend({sprintf('OST status * %d', OST_MULT)});
end

xlabel('Time (s)');
ylabel('Frequency (Hz)');

%% Visualization: output sound
figure('Position', [100, 100, 1400, 600], 'Name', 'Output spectrogram');
% subplot('Position', [0.5, 0.1, 0.45, 0.8]);
show_spectrogram(data1.signalOut, fs, 'noFig');

if isequal(pertMode, 'formant')
    plot(tAxis, data1.fmts(:, 1 : 2), 'b');
    plot(tAxis, data1.sfmts(:, 1 : 2), 'g');
end

plot(tAxis, data1.ost_stat * 500, 'k-');
if isequal(pertMode, 'formant')
    legend({'F1 (original)', 'F2 (oringina)', 'F1 (shifted)', 'F2 (shifted)', sprintf('OST status * %d', OST_MULT)});
else
    legend({sprintf('OST status * %d', OST_MULT)});
end
xlabel('Time (s)');
ylabel('Frequency (Hz)');

drawnow;

%%
if bPlay
    play_audio(data1.signalIn, fs);
    play_audio(data1.signalOut, fs);
end


return