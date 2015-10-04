function test_fmt_shift_audapter
% load 'G:\DATA\RHYTHM-FMRI\MGH_TEST_20130708_1\run1\rep1\trial-1-2.mat';
% load 'E:\tmp\SDAP_PIL30_BEH240713\run2\trial-3-3.mat'
load 'G:\DATA\RHYTHM-FMRI\BERRY_COLLAB_DATA_1\run1\rep1\trial-1-2.mat';
p = data.params;

%% Setting ost and pcf
ost_fn = '../pert/ost';
pcf_fn = '../pert/fmt_pert.pcf';
% ost_fn = '../pert/ost';
% pcf_fn = 'E:\tmp\sdap2\pert\pitch_up.pcf';

% p.nLPC = 17;
p.bDetect = 1;
p.rmsThresh = 0.01;
p.bShift = 1;
p.bRatioShift = 1;
p.bBypassFmt = 0;           % === Important === %
p.bPitchShift = 0;          % === Important === %

check_file(ost_fn);
check_file(pcf_fn);

Audapter(8, ost_fn, 1);
Audapter(9, pcf_fn, 1);

% Audapter(3, 'bbypassfmt', 0, 1); 
% Audapter(3, 'bpitchshift', 0, 1);

%% Load the multi-talker babble noise
[mbw, fs_mtb]=read_audio('mtbabble48k.wav');

% Normalize the amplitude of the mtb noise
mbw = mbw - mean(mbw);
mb_rms = rms(mbw);
mbw = mbw / mb_rms;

Audapter(3, 'datapb', mbw, 0);

%% 
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

Audapter(6);   % Reset;\

p.rmsClipThresh=0.01;
p.bRMSClip=1;

% p.bPitchShift = 1;
% p.pitchShiftRatio = 2 ^ (1 / 12);

AudapterIO('init', p);
Audapter(3, 'rmsthr', 5e-3);

Audapter('reset');

for n = 1 : length(sigInCell)
    Audapter(5, sigInCell{n});
end

data1 = AudapterIO('getData');

figure('Position', [100, 100, 1400, 600]);
% subplot('Position', [0.05, 0.1, 0.45, 0.8]);
show_spectrogram(data1.signalIn, fs, 'noFig');
frameDur = data1.params.frameLen / data1.params.sr;
tAxis = 0 : frameDur : frameDur * (size(data1.fmts, 1) - 1);
plot(tAxis, data1.fmts, 'b');
% plot(tAxis, data1.ost_stat * 500, 'm');

frameDur = data.params.frameLen / data.params.sr;
tAxis = 0 : frameDur : frameDur * (size(data.rms, 1) - 1);
plot(tAxis, data1.ost_stat * 500, 'w-');

figure('Position', [100, 100, 1400, 600]);
% subplot('Position', [0.5, 0.1, 0.45, 0.8]);
show_spectrogram(data1.signalOut, fs, 'noFig');
plot(tAxis, data1.fmts, 'b');
plot(tAxis, data1.sfmts, 'g');

% play_audio(data1.signalIn, fs)
% play_audio(data1.signalOut, fs);
return