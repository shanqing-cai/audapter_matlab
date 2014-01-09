function audapterDemo_online(mode, varargin)
%% Configurations
sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3;
frameLen = 96;  % Before downsampling

audioInterfaceName = 'MOTU MicroBook';

persistent p;

%% 
Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0);
Audapter('setParam', 'sRate', sRate / downFact, 0);
Audapter('setParam', 'frameLen', frameLen / downFact, 0);

if isequal(mode, 'persistentFormantShift')
    Audapter('ost', '', 0);
    Audapter('pcf', '', 0);
    
    p = getAudapterDefaultParams('male');
    
    p.f1Min = 0;
    
    AudapterIO('init', p);
    
    Audapter('setParam', 'f1Min', 0, 0);
    Audapter('setParam', 'f1Max', 5000, 0);
    Audapter('setParam', 'f2Min', 0, 0);
    Audapter('setParam', 'f2Max', 5000, 0);
    Audapter('setParam', 'pertF2', linspace(0, 5000, 257), 0);
    Audapter('setParam', 'pertAmp', 0.4 * ones(1, 257), 0);
    Audapter('setParam', 'pertPhi', pi * 0.75 * ones(1, 257), 0);
    
    Audapter('setParam', 'bTrack', 1, 0);
    Audapter('setParam', 'bShift', 1, 0);
    Audapter('setParam', 'bRatioShift', 1, 0);
    Audapter('setParam', 'bMelShift', 0, 0);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please say something...');
    pause(2);
    fprintf(1, '\n');
    Audapter('stop');
    
    data = AudapterIO('getData');
    
    % -- Visualization -- %
    frameDur = data.params.frameLen / data.params.sr;
    tAxis = 0 : frameDur : frameDur * (size(data.fmts, 1) - 1);
    
    figure;
    subplot('Position', [0.1, 0.5, 0.8, 0.375]);
    hold on;
    show_spectrogram(data.signalIn, data.params.sr, 'noFig');
    plot(tAxis, data.fmts(:, 1 : 2), 'w');
    
    subplot('Position', [0.1, 0.125, 0.8, 0.375]);
    hold on;
    show_spectrogram(data.signalOut, data.params.sr, 'noFig');
    plot(tAxis, data.fmts(:, 1 : 2), 'w');
    tAxis = 0 : frameDur : frameDur * (size(data.fmts, 1) - 1);
    plot(tAxis, data.sfmts(:, 1 : 2), 'g');
    
elseif isequal(mode, 'playTone')
    noteRatio = 2 ^ (1 / 12);
    notes = [0, 2, 4, 0];
    
    Audapter('reset');
    
    for i1 = 1 : 4
        Audapter('setParam', 'wgFreq', 440 * (noteRatio ^ notes(i1)), 0);
        Audapter('setParam', 'wgAmp', 0.05, 0);
        Audapter('setParam', 'wgTime', 0.0, 0);
    
        Audapter('playTone');
        pause(0.25);
        
        if i1 ~= 4
            Audapter('stop');
        end
        
        pause(0.25);
    end
    
    input('Hit Enter to stop...');
    Audapter('stop');
 
elseif isequal(mode, 'playWave')
    inputMatFN = '../example_data/trial-1-2.mat';
    
    check_file(inputMatFN);    
    load(inputMatFN);
    assert(exist('data', 'var') == 1);
    
    maxPBSize = Audapter('getMaxPBLen');
    
    sigInRS = resample(data.signalIn, sRate, data.params.sr);
	if length(sigInRS) > maxPBSize
        sigInRS = sigInRS(1 : maxPBSize);
    end
    Audapter('setParam', 'datapb', sigInRS);
    clear('data');
    
    Audapter('reset');
    Audapter('playWave');
    pause(length(sigInRS) / sRate);
    Audapter('stop');
else
    
end

return