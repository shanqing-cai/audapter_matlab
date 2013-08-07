function continuous_pitch_shift
bOffline = 1;
bUltraLite = 0;

if bUltraLite
    sRate = 12000;
    downFact = 4;
    frameLen = 64;
    scaleFactor = 5.0;
else
    sRate = 16000;
    downFact = 3;
    frameLen = 32;
    scaleFactor = 0.05;
end

%%
% Audapter('ost', '../pert/ost_states1-2');
% Audapter('pcf', '../pert/pert_zero.pcf');
% Audapter('ost', '../pert/ost_states1-4');
% Audapter('pcf', '../pert/pert_zero_states13.pcf');

Audapter('ost', 'E:\DATA\APE\NWU_TS_20130806_3\rand\rep2\trial-4-down.ost');
Audapter('pcf', 'E:\DATA\APE\NWU_TS_20130806_3\rand\rep2\trial-4-down.pcf');

Audapter(3, 'bshift', 1);
Audapter(3, 'bpitchshift', 1);

AudapterIO('reset');

%%
load 'E:\DATA\APE\TS_20130802_10\rand\rep2\trial-9-1.mat' %%% GO %%%

fs = data.params.sr;

sigIn = data.signalIn;

data.params.pvocFrameLen = 512;
data.params.pvocHop = 128;
AudapterIO('init', data.params);

Audapter(3, 'scale', scaleFactor);
Audapter(3, 'stereomode', 2);
Audapter(3, 'bpitchshift', 1);

%% For ultralite
if bUltraLite
    Audapter('deviceName', 'MOTU Audio');
    Audapter(3, 'srate', sRate);
    Audapter(3, 'downfact', downFact);
    Audapter(3, 'framelen', frameLen);
else
    Audapter('deviceName', 'MOTU MicroBook');
    Audapter(3, 'srate', sRate);
    Audapter(3, 'downfact', downFact);
    Audapter(3, 'framelen', frameLen);
end

% Audapter playTone;

%% Replace sigIn with sine wave
tAxis = 0 : 1 / fs : 1 / fs * (length(sigIn) - 1);
amp = 0.1;
frq = 1e3;
sigIn = amp * sin(2 * pi * frq * tAxis);

%%
sigIn = resample(sigIn, sRate * downFact, fs);
sigInCell = makecell(sigIn, frameLen * downFact);

Audapter(6);
%%
if bOffline
    for n = 1 : length(sigInCell)
        Audapter(5, sigInCell{n});
    end
else
    Audapter(1);
    pause(4);
    Audapter(2);
end

%%
data1 = AudapterIO('getData');

getPitchShiftTimeStamps(data1);

show_spectrogram(data1.signalIn, data1.params.sr);
show_spectrogram(data1.signalOut, data1.params.sr);


return