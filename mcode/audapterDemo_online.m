function audapterDemo_online(mode, varargin)
%% Configurations
audioInterfaceName = 'MOTU MicroBook';

sRate = 48000;  % Hardware sampling rate (before downsampling)
downFact = 3;
frameLen = 96;  % Before downsampling

defaultGender = 'female';

%% Visualization configuration
gray = [0.5, 0.5, 0.5];
ostMult = 250;
legendFontSize = 8;

noiseWavFN = 'mtbabble48k.wav';

%% 
Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 0);
Audapter('setParam', 'sRate', sRate / downFact, 0);
Audapter('setParam', 'frameLen', frameLen / downFact, 0);

bVis = 0;
bVisFmts = 0;
bVisOST = 0;
visName = '';

if isequal(mode, 'persistentFormantShift')
    gender = varargin{1};
    
    Audapter('ost', '', 0);
    Audapter('pcf', '', 0);
    
    params = getAudapterDefaultParams(gender);
    
    params.f1Min = 0;
    params.f2Max = 5000;
    params.f2Min = 0;
    params.f2Max = 5000;
    params.pertF2 = linspace(0, 5000, 257);
    params.pertAmp = 0.4 * ones(1, 257);
    params.pertPhi = 0.75 * pi * ones(1, 257);
    params.bTrack = 1;
    params.bShift = 1;
    params.bRatioShift = 1;
    params.bMelShift = 0;
    
    % Selecte feedback mode
    if isempty(fsic(varargin, 'fb'))
       params.fb = 1; 
    else
        fbMode = varargin{fsic(varargin, 'fb') + 1};
        if ~(fbMode >= 0 && fbMode <=4 && floor(fbMode) == fbMode)
            error('Invalid fb mode: %d', fbMode);
        end
        
        if fbMode >= 2 && fbMode <= 4
            %--- Load noise ---%
            maxPBSize = Audapter('getMaxPBLen');
            
            check_file(noiseWavFN);
            [w, fs] = read_audio(noiseWavFN);
    
            if fs ~= params.sr * params.downFact
                w = resample(w, params.sr * params.downFact, fs);              
            end
            if length(w) > maxPBSize
                w = w(1 : maxPBSize);
            end
            Audapter('setParam', 'datapb', w, 1);  
        end
        
        if fbMode == 3
            params.fb3Gain = 0.1;
        end
        
        fprintf(1, 'Setting fb to %d\n', fbMode);
        params.fb = varargin{fsic(varargin, 'fb') + 1};
    end
    
%     params.trialLen = 1.5;
%     params.rampLen = 0.25;
    
    AudapterIO('init', params);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please say something...');
    pause(3);
    fprintf(1, '\n');
    Audapter('stop');
    
    bVis = 1;
    bVisFmts = 1;
    visName = 'Persistent formant shift';
    
elseif isequal(mode, 'focalFormantShift');
    gender = varargin{1};
     
    ostFN = '../example_data/focal_fmt_pert.ost';
    pcfFN = '../example_data/focal_fmt_pert.pcf';
    
    check_file(ostFN);
    check_file(pcfFN);
    Audapter('ost', ostFN, 0);
    Audapter('pcf', pcfFN, 0);
    
    params = getAudapterDefaultParams(gender);
    
    params.bShift = 1;
    params.bRatioShift = 1;
    params.bMelShift = 0;    
    
    AudapterIO('init', params);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please say "I said pap again"...');
    pause(2);
    fprintf(1, '\n');
    Audapter('stop'); 
    
    
    bVis = 1;
    bVisFmts = 1;
    bVisOST = 1;
    visName = 'Focal formant shift';
    
elseif isequal(mode, 'persistentPitchShift')
    ostFN = '../example_data/one_state_tracking.ost';
    pcfFN = '../example_data/persistent_pitch_pert.pcf';
    
    check_file(ostFN);
    check_file(pcfFN);
    Audapter('ost', ostFN, 0);
    Audapter('pcf', pcfFN, 0);
    
    params = getAudapterDefaultParams(defaultGender);
    params.bPitchShift = 1;
    
    AudapterIO('init', params);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please say something...');
    pause(2);
    fprintf(1, '\n');
    Audapter('stop');
    
    bVis = 1;
    visName = 'Persistent pitch shift (up 2 semitones)';
    
elseif isequal(mode, 'twoShortPitchShifts');
    ostFN = '../example_data/two_blips.ost';
    pcfFN = '../example_data/two_pitch_shifts.pcf';
    
    check_file(ostFN);
    check_file(pcfFN);
    Audapter('ost', ostFN, 0);
    Audapter('pcf', pcfFN, 0);
    
    params = getAudapterDefaultParams(defaultGender);
    params.bPitchShift = 1;
    
    AudapterIO('init', params);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please hum...');
    pause(2);
    fprintf(1, '\n');
    Audapter('stop');    
    
    bVis = 1;
    bVisOST = 1;
    visName = 'Two short pitch shifts';
    
elseif isequal(mode, 'timeWarp')
    ostFN = '../example_data/two_blips.ost';
    pcfFN = '../example_data/time_warp_demo.pcf';
    
    check_file(ostFN);
    check_file(pcfFN);
    Audapter('ost', ostFN, 0);
    Audapter('pcf', pcfFN, 0);
    
    params = getAudapterDefaultParams(defaultGender);
    params.bPitchShift = 1;
    
    AudapterIO('init', params);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please say "puh puh puh ..."...');
    pause(2);
    fprintf(1, '\n');
    Audapter('stop');    
    
    bVis = 1;
    bVisOST = 1;
    visName = 'Time warping';
    
elseif isequal(mode, 'globalDAF_multiVoice')
    Audapter('ost', '', 0);
    Audapter('pcf', '', 0);
    
    globalDelay = [0.100, 0.200];  % Unit: s
%     globalDelay = [0.200, 0.400];  % Unit: s
    gain = [1.0, 1.0];
    pitchShiftRatio = 2 .^ ([-2, 2] / 12);
    
    params = getAudapterDefaultParams(defaultGender);
    frameDur = params.frameLen / params.sr;
    
    params.nfb = length(globalDelay);
    params.pitchShiftRatio = pitchShiftRatio;
    params.delayFrames = round(globalDelay / frameDur);
    params.pitchShiftRatio = pitchShiftRatio;
    params.gain = gain;
    params.bPitchShift = 1;
    params.bBypassFmt = 1;
    
    AudapterIO('init', params);
    
    Audapter('reset');
    Audapter('start');
    fprintf(1, 'Please say something...');
    pause(3);
    fprintf(1, '\n');
    Audapter('stop');
    
    bVis = 1;
    
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
    
elseif isequal(mode, 'playToneSeq')
    Audapter('setParam', 'tsgNTones', 4, 0);
    Audapter('setParam', 'tsgToneDur', [0.75, 0.25, 0.25, 0.5], 0);
    Audapter('setParam', 'tsgToneFreq', 440 * 2 * (2 .^ ([-2, -9, -5, 0] / 12)), 0);
    Audapter('setParam', 'tsgToneAmp', [0.075, 0.05, 0.05, 0.10], 0);
    Audapter('setParam', 'tsgtoneramp', [0.05, 0.05, 0.05, 0.05], 0);
    Audapter('setParam', 'tsgInt', [0.75, 0.25, 0.25, 0.5], 0);
    Audapter('setParam', 'wgTime', 0, 0);
    
    Audapter('reset');
    Audapter('playToneSeq');
    pause(2);
    Audapter('stop');
    
    p = getAudapterParamSet();
else
    error('Unrecognized mode: %s', mode);
end


%% -- Visualization -- %%
if bVis
    data = AudapterIO('getData');
    
    frameDur = data.params.frameLen / data.params.sr;
    tAxis = 0 : frameDur : frameDur * (size(data.fmts, 1) - 1);
    
    %-----------------------%
    figure;
    subplot('Position', [0.1, 0.5, 0.8, 0.375]);
    show_spectrogram(data.signalIn, data.params.sr, 'noFig');
    
    if bVisFmts
        plot(tAxis, data.fmts(:, 1 : 2), 'Color', gray);
    end
    if bVisOST
        plot(tAxis, data.ost_stat * ostMult, 'b-');
    end
        
    ylabel('Frequency (Hz)');
    
    xs = get(gca, 'XLim');
    ys = get(gca, 'YLim');
    text(xs(1) + 0.025 * range(xs), ys(2) - 0.075 * range(ys), ...
         'Input sound', 'FontSize', 12);
    
    %-----------------------%
    subplot('Position', [0.1, 0.125, 0.8, 0.375]);
    hold on;
    show_spectrogram(data.signalOut, data.params.sr, 'noFig');
    
    legendItems = {};
    if bVisFmts
        plot(tAxis, data.fmts(:, 1 : 2), 'Color', gray);
        plot(tAxis, data.sfmts(:, 1 : 2), 'g');
        legendItems{end + 1} = 'Original F1';
        legendItems{end + 1} = 'Original F2';
        legendItems{end + 1} = 'Shifted F1';
        legendItems{end + 1} = 'Shifted F2';
    end
    if bVisOST
        plot(tAxis, data.ost_stat * ostMult, 'b-');
        legendItems{end + 1} = sprintf('OST stat * %d', ostMult);
    end
    
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    
    xs = get(gca, 'XLim');
    ys = get(gca, 'YLim');
    text(xs(1) + 0.025 * range(xs), ys(2) - 0.075 * range(ys), ...
         sprintf('Output sound: %s', visName), 'FontSize', 12);
     
    if ~isempty(legendItems)
        legend(legendItems, 'FontSize', legendFontSize, ...
               'Location', 'Southwest');
    end
end

return
