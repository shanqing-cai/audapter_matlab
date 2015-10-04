function runExperiment(exptConfigFN, varargin)
DEBUG = 0;
DEBUG_PS = 0;

[~, hostName] = system('hostname');

fclose all;
close all force;

%% ---- Read and parse exptConfig file (e.g., expt_config_fmt.txt) ----
check_file(exptConfigFN);
expt_config = read_parse_expt_config(exptConfigFN);

% if ~(isequal(expt_config.PERT_MODE, 'PITCH') || isequal(expt_config.PERT_MODE, 'FMT'))
%     error('Unrecognized PERT_MODE: %s', expt_config.PERT_MODE);
% end

if expt_config.TRIGGER_BY_MRI_SCANNER && expt_config.SHOW_KIDS_ANIM
    error('TRIGGER_BY_MRI_SCANNER == 1 and SHOW_KIDS_ANIM == 1 are not compatible');
end

%% Optional: full schedule file for experiment design 
if length(expt_config.FULL_SCHEDULE_FILE) < 2 || ...
   ~isequal(expt_config.FULL_SCHEDULE_FILE(1), '"') || ...
   ~isequal(expt_config.FULL_SCHEDULE_FILE(end), '"')
    error('Unrecognized format in FULL_SCHEDULE_FILE: %s', expt_config.FULL_SCHEDULE_FILE);
end

expt_config.FULL_SCHEDULE_FILE = expt_config.FULL_SCHEDULE_FILE(2 : end - 1);
if ~isempty(expt_config.FULL_SCHEDULE_FILE)
    check_file(expt_config.FULL_SCHEDULE_FILE);
end

%% Check ost and pcf
% check_file(expt_config.OST_FN);

%% ---- Subject and experiment information ---
subject.expt_config         = expt_config;
subject.name				= expt_config.SUBJECT_ID;
subject.sex					= expt_config.SUBJECT_GENDER;  % male / female
subject.age                 = expt_config.SUBJECT_AGE;
subject.group               = expt_config.SUBJECT_GROUP;

subject.mouthMicDist        = expt_config.MOUTH_MIC_DIST;   % cm
subject.closedLoopGain      = 14 - 20 * log10(10 / subject.mouthMicDist);

subject.dBRange1            = expt_config.SPL_RANGE/0.4;        % is the one-sided dBRange1*0.4
% subject.dBRange2            =12;         % Tightened level range after the initial pract1 training. 

subject.trialLen            = expt_config.TRIAL_LEN;
subject.trialLenMax         = expt_config.TRIAL_LEN_MAX;

subject.hostName            = deblank(hostName);

subject.dataDir             = expt_config.DATA_DIR;

subject.trigByScanner		= expt_config.TRIGGER_BY_MRI_SCANNER;
subject.TA					= expt_config.FMRI_TA;
subject.ITI					= 6;

subject.vumeterMode         = 2;     % 1: 10 ticks; 2: 3 ticks;

if subject.trigByScanner== 1
	subject.showProgress		= 1;
	subject.showPlayButton      = 0;
else
	subject.showProgress		= 1;
	subject.showPlayButton      = 1;
end

subject.designNum			= 2;

subject.lvNoise             = 75; % dBA SPL. The level of noise for completely masking speech (mode trialType = 2 or 3).

bAlwaysOn = expt_config.ALWAYS_ON;

bSim = 0;
simDataDir = '';
if ~isempty(fsic(varargin, 'sim'))
    bSim = 1;
    simDataDir = varargin{fsic(varargin, 'sim') + 1};
end

subject.bAlwaysOn = bAlwaysOn;

%%
subject.date				= clock;

if (~isempty(findStringInCell(varargin, 'subject')))
    clear('subject');
    subject = varargin{findStringInCell(varargin, 'subject') + 1};
end

subject.pcrKnob=0;

%%
bNew=true;

dirname=fullfile(subject.dataDir,num2str(subject.name));

if (~isempty(findStringInCell(varargin,'dirname')))
    clear('dirname');
    dirname=varargin{findStringInCell(varargin,'dirname')+1};
end

if isdir(dirname)
    if ~isempty(fsic(varargin, 'forceOverwrite'))
        bNew = true;
        fprintf('Forced to overwrite directory: %s\n', dirname);
    else
        messg={sprintf('The specified directory %s already contains a previously recorded experiment', dirname)
            ''
            'Continue experiment, overwrite  or cancel ?'};
        button1 = questdlg(messg, 'DIRECTORY NOT EMPTY', 'Continue', 'Overwrite', 'Cancel', 'Continue');
        switch button1
            case 'Overwrite'
                button2 = questdlg({sprintf('Are you sure you want to overwrite data in %s?', dirname)} ,'OVERWRITE EXPERIMENT ?');
                switch button2
                    case 'Yes',
                        rmdir(dirname,'s')
                    otherwise,
                        return
                end
            case 'Continue'
                bNew=false;

            otherwise,
                return

        end
    end
end

if bNew % set up new experiment
    if isdir(dirname)
        rmdir(dirname, 's');
    end
    mkdir(dirname)
    copyfile(exptConfigFN, fullfile(dirname, 'expt_config.txt'));
    
	expt.subject=subject;
    
    expt.allPhases={'pre', 'pract1', 'pract2'};
    expt.recPhases={'pre', 'pract1', 'pract2'}; %SC The pahses during which the data are recorded

    for i1 = 1 : expt_config.N_RAND_RUNS
        expt.allPhases{end + 1} = sprintf('rand%d', i1);
        expt.recPhases{end + 1} = sprintf('rand%d', i1);
    end
    
    expt.allPhases = [expt.allPhases, {'start', 'ramp', 'stay', 'end'}];
    expt.recPhases = [expt.recPhases, {'start', 'ramp', 'stay', 'end'}];
    
    expt.stimUtter = expt_config.STIM_UTTER;
    
    expt.trialTypes=[1];
    expt.trialOrderRandReps = 1;	%How many reps are randomized together
    expt.script.pre.nReps = expt_config.PRE_REPS;    %SC Numbers of repetitions in the stages   % !!1!!	
    expt.script.pract1.nReps = expt_config.PRACT1_REPS; %SC Default 2   %SC-Mod(09/26/2007)        % !!1!!
    expt.script.pract2.nReps = expt_config.PRACT2_REPS; %SC Default 2   %SC-Mod(09/26/2007)        % !!1!!
    
    expt.sustWords = expt_config.STIM_UTTER;
    expt.script.start.nReps = expt_config.SUST_START_REPS;
    expt.script.ramp.nReps = expt_config.SUST_RAMP_REPS;
    expt.script.stay.nReps = expt_config.SUST_STAY_REPS;
    expt.script.end.nReps = expt_config.SUST_END_REPS;

	expt.trialTypeDesc = cell(1, 5);
	expt.trialTypeDesc{1} = 'Speech with auditory feedback';
	expt.trialTypeDesc{2} = 'Speech with masking noise';
	expt.trialTypeDesc{3} = 'Listen to masking noise, no speech';
	expt.trialTypeDesc{4} = 'Rest (no speech) in silence';
	expt.trialTypeDesc{5} = 'Non-speech bracket task in silence';
	
    fprintf(1, 'Generating script for the practice phases...\n');
    expt.script.pre    = genPhaseScript('pre',    ...
                                        expt.script.pre.nReps, expt.stimUtter);
    expt.script.pract1 = genPhaseScript('pract1', ...
                                        expt.script.pract1.nReps, expt.stimUtter);
    expt.script.pract2 = genPhaseScript('pract2', ...
                                        expt.script.pract2.nReps, expt.stimUtter);
    
    for i1 = 1 : expt_config.N_RAND_RUNS
        phs = sprintf('rand%d', i1);
        fprintf(1, 'Generating script for the random-perturbation phase %s...\n', phs);
        [expt.script.(phs), expt.pertDes] = ...
            genRandScript(phs, ...
                          expt_config.N_BLOCKS_PER_RAND_RUN, expt_config.TRIALS_PER_BLOCK, ...
                          expt_config.TRIAL_TYPES_IN_BLOCK, expt_config.MIN_DIST_BETW_SHIFTS, ...
                          expt_config.ONSET_DELAY_MS, expt_config.NUM_SHIFTS, ...
                          expt_config.INTER_SHIFT_DELAYS_MS, expt_config.PITCH_SHIFTS_CENT, ...
                          expt_config.INT_SHIFTS_DB, ...
                          expt_config.F1_SHIFTS_RATIO, expt_config.F2_SHIFTS_RATIO, ...
                          expt_config.SHIFT_DURS_MS, expt_config.STIM_UTTER, expt_config.FULL_SCHEDULE_FILE);
    end
	fprintf('Done.\n');
    
    t_phases = {'start', 'ramp', 'stay', 'end'};
    for k1 = 1 : length(t_phases)
        t_phase = t_phases{k1};
        expt.script.(t_phase).noiseRepsRatio = expt_config.NOISE_REPS_RATIO; % TODO
        
%         expt.script.(t_phase)  = ...
%             genPhaseScript(t_phase,  ...
%                            expt.script.(t_phase).nReps,  expt.sustWords, ...
%                            'noiseRepsRatio', expt.script.(t_phase).noiseRepsRatio);
        if expt.script.(t_phase).nReps > 0
            fprintf(1, 'Generating script for the random-perturbation phase %s...\n', t_phase);
            [expt.script.(t_phase), expt.pertDes] = ...
                genRandScript(t_phase, ...
                              expt.script.(t_phase).nReps, expt_config.SUST_TRIALS_PER_BLOCK, ...
                              {}, {}, ...
                              expt_config.SUST_ONSET_DELAY_MS, expt_config.SUST_NUM_SHIFTS, ...
                              expt_config.SUST_INTER_SHIFT_DELAYS_MS, expt_config.SUST_PITCH_SHIFTS_CENT, ...
                              expt_config.SUST_INT_SHIFTS_DB, ...
                              expt_config.SUST_F1_SHIFTS_RATIO, expt_config.SUST_F2_SHIFTS_RATIO, ...
                              expt_config.SUST_SHIFT_DURS_MS, expt_config.SUST_STIM_UTTER, '');
        else
            info_log(sprintf('Sust phase %s will not be included due to nReps == 0', t_phase));
            idxKeep = setxor(1 : length(expt.allPhases), fsic(expt.allPhases, t_phase));
            expt.allPhases = expt.allPhases(idxKeep);
            expt.recPhases = expt.recPhases(idxKeep);
        end
    end
    fprintf('Done.\n');

    
    p = getAudapterDefaultParams(subject.sex,...
        'closedLoopGain',expt.subject.closedLoopGain,...
        'trialLen',expt.subject.trialLen,...
        'trialLenMax', expt.subject.trialLenMax, ...
        'mouthMicDist',expt.subject.mouthMicDist, ...
        'sr',expt_config.SAMPLING_RATE/expt_config.DOWNSAMP_FACT,...
        'downFact',expt_config.DOWNSAMP_FACT,...
        'frameLen',expt_config.FRAME_SIZE/expt_config.DOWNSAMP_FACT, ...
        'pvocFrameLen', expt_config.PVOC_FRAME_LEN, ...
        'pvocHop', expt_config.PVOC_HOP);
    p.rmsThresh = expt_config.INTENSITY_THRESH;
    
    if isequal(expt_config.DEVICE_NAME, 'UltraLite')
        %--- Settings for MOTU UlraLite---%
        cfgUltraLite.downFact = 4;
        cfgUltraLite.sr = 12000;
        cfgUltraLite.frameLen = 64;
        
        Audapter('deviceName', 'MOTU Audio');
        
        p.downFact = cfgUltraLite.downFact;
        p.sr = cfgUltraLite.sr;
        p.frameLen = cfgUltraLite.frameLen;
        
        fprintf(1, 'INFO: Using MOTU UltraLite settings. \n');
        fprintf(1, 'INFO: Make sure in MOTU Audio Console, the following parameter values are set:\n');
        fprintf(1, 'INFO:    sampling rate = %d\n', cfgUltraLite.downFact * cfgUltraLite.sr);        
        fprintf(1, 'INFO:    buffer size = %d\n', cfgUltraLite.downFact * cfgUltraLite.frameLen);
        fprintf(1, '\n');
    elseif isequal(expt_config.DEVICE_NAME, 'MicroBook')
        Audapter('deviceName', 'MOTU MicroBook');
    else
        error('Unrecognized DEVICE_NAME: %s', expt_config.DEVICE_NAME);
    end
    
    if isequal(expt_config.STEREO_MODE, 'LR_AUDIO')
        p.stereoMode = 1;
    elseif isequal(expt_config.STEREO_MODE, 'L_AUDIO')
        p.stereoMode = 0;
    elseif isequal(expt_config.STEREO_MODE, 'L_AUDIO_R_SIM_TTL')
        p.stereoMode = 2;
    else
        error('Unrecognized value of STEREO_MODE: %s', expt_config.STEREO_MODE);
    end
    
%     if isequal(expt_config.PERT_MODE, 'PITCH')
%         p.bBypassFmt = 1;
%     end
    
    state.phase=1;
    state.rep=1;
    state.params=p;
    rmsPeaks=[];
    
    save(fullfile(dirname,'expt.mat'),'expt');
    save(fullfile(dirname,'state.mat'),'state');
else % load expt
    load(fullfile(dirname,'state.mat'));
    load(fullfile(dirname,'expt.mat'));            
    p=state.params;
%     nPeaks=length(expt.trainWords);
%     if state.phase>1
%     rmsPeaks=ones(length(expt.trainWords),1)*p.rmsMeanPeak;    %SC ***Bug!!***
%     end
    subject=expt.subject;
end

%% initialize algorithm
AudapterIO('init',p);      %SC Set the initial (default) parameters

if ((p.frameShift-round(p.frameShift)~=0) || (p.frameShift>p.frameLen))
    uiwait(errordlg(['Frameshift = ' num2str(p.frameShift) ' is a bad value. Set nWin and frameLen appropriately. Frameshift must be an integer & Frameshift <= Framelen'],'!! Error !!'))
    return
else

    fprintf('\n  \n')
    Audapter(0);           %SC Gives input/output device info, and serves as an initialization.

    fprintf('\nSettings : \n')
    fprintf('DMA Buffer    = %i samples \n',p.frameLen) %SC Buffer length after downsampling
    fprintf('Samplerate    = %4.2f kHz \n',p.sr/1000)   %SC sampling rate after downsampling
    fprintf('Analysis win  = %4.2f msec \n',p.bufLen/p.sr*1000)
    fprintf('LPC  window   = %4.2f msec \n',p.anaLen/p.sr*1000)

    fprintf('Process delay = %4.2f msec \n',p.nDelay*p.frameLen/p.sr*1000)
    fprintf('Process/sec   = %4.2f \n',p.sr/p.frameShift)

end

%% Load the multi-talker babble noise
[mbw, fs_mtb]=read_audio('mtbabble48k.wav');

% Normalize the amplitude of the mtb noise
mbw = mbw - mean(mbw);
mb_rms = rms(mbw);
mbw = mbw / mb_rms;

maxPBSize = Audapter('getMaxPBLen');
if length(mbw) > maxPBSize
    mbw = mbw(1 : maxPBSize);
end

Audapter(3, 'datapb', mbw, 0);

%% expt
figIdDat=makeFigDataMon;

% wordList=expt.words;

allPhases=expt.allPhases;
recPhases=expt.recPhases;
% nWords=length(wordList);

hgui = UIRecorder('figIdDat', figIdDat, 'dirname', dirname);
set(hgui.UIRecorder, 'Position', [900, 60, 440, 700]);
% winontop(hgui.UIRecorder, 1);


if ~isempty(fsic(varargin, 'twoScreens'))
    subjFigPos = get(hgui.hkf, 'Position')
    set(hgui.hkf, 'Position', [1800, 100, subjFigPos(3), subjFigPos(4)]);
end

% if (expt.subject.designNum==2)
%     expt.script=addFaceInfo(expt.script,hgui.skin.dFaces);
%     expt.dFaces=hgui.skin.dFaces;
% end

hgui.showKidsAnim = expt.subject.expt_config.SHOW_KIDS_ANIM;

hgui.bSim = bSim;
hgui.simDataDir = simDataDir;
hgui.dirname = dirname;

hgui.pcrKnob=subject.pcrKnob;
hgui.ITI=expt.subject.ITI;
hgui.trigByScanner = expt.subject.trigByScanner;
hgui.trigKey = expt_config.MRI_TRIGGER_KEY;
hgui.TA = expt.subject.TA;
hgui.dBRange=expt.subject.dBRange1;
hgui.trialLen=expt.subject.trialLen;
hgui.trialLenMax = expt.subject.trialLenMax;
% hgui.skin.faceOrder=randperm(length(hgui.skin.dFaces));
hgui.skin.facePnt=1;

hgui.bAlwaysOn = bAlwaysOn;
hgui.dScale=p.dScale;

hgui.vumeterMode=expt.subject.vumeterMode;

hgui.rmsTransTarg_spl=getSPLTarg(expt_config.SPL_TARGET,expt.subject.mouthMicDist);
load('micRMS_100dBA.mat');  % Gives micRMS_100dBA: the rms the microphone should read when the sound is at 100 dBA SPL
hgui.rmsTransTarg=micRMS_100dBA / (10^((100-hgui.rmsTransTarg_spl)/20));

hgui.fb3Gain = dBSPL2WaveAmp(expt_config.BLEND_NOISE_DB);

hgui.pertStates = expt_config.PERT_STATES;

hgui.debug_pitchShiftLogF = 0;

%%
fprintf('\n');
disp(['Mouth-microphone distance = ',num2str(expt.subject.mouthMicDist),' cm']);
disp(['hgui.rmsTransTarg_spl = ',num2str(hgui.rmsTransTarg_spl),' dBA SPL']);
fprintf('\n');

hgui.vocaLen=round(expt_config.VOWEL_LEN_TARG*p.sr/(p.frameLen)); % 300 ms, 225 frames
hgui.lenRange=2.5*round(expt_config.VOWEL_LEN_RANGE*p.sr/(p.frameLen));  % single-sided tolerance range: 0.4*250 = 100 ms
disp(['Vowel duration range: [',num2str(300-0.4*250),',',num2str(300+0.4*250),'] ms.']);

hgui.debug=DEBUG;


% --- Speech-modulated noise (SMN) --- %
hgui.smnGain = expt_config.SMN_GAIN;
hgui.smnFF0 = expt_config.SMN_FF_0;
hgui.smnFF1 = expt_config.SMN_FF_1;
hgui.smnOnRamp = expt_config.SMN_ON_RAMP;
hgui.smnOffRamp = expt_config.SMN_OFF_RAMP;

if (isempty(findStringInCell(varargin,'twoScreens')))
% 	set(hgui.UIRecorder,...
% 		'position', [0    5.0000  250.6667   65.8750],...
% 		'toolbar','none');  %SC Set the position of the expt window, partially for the use of multiple monitors.
else
% 	if (expt.subject.trigByScanner==1)
% 		ms=get(0,'MonitorPosition');
% 		set(hgui.UIRecorder,'Position',[ms(2,1),ms(1,4)-ms(2,4),ms(2,3)-ms(2,1)+1,ms(2,4)+20],'toolbar','none','doublebuffer','on','renderer','painters');
% 		pos_win=get(hgui.UIRecorder,'Position');
% 		pos_strh=get(hgui.strh,'Position');
% 		pos_axes_pic=get(hgui.axes_pic,'Position');
% 		pos_rms_axes=get(hgui.rms_axes,'Position');
% 		pos_speed_axes=get(hgui.speed_axes,'Position');
% 		pos_rms_label=get(hgui.rms_label,'Position');
% 		pos_rms_too_soft=get(hgui.rms_too_soft,'Position');
% 		pos_rms_too_loud=get(hgui.rms_too_loud,'Position');
% 		pos_speed_label=get(hgui.speed_label,'Position');
% 		pos_speed_too_slow=get(hgui.speed_too_slow,'Position');
% 		pos_speed_too_fast=get(hgui.speed_too_fast,'Position');
% 		set(hgui.strh,'Position',[(pos_win(3)-pos_strh(3))/2+5,(pos_win(4)-pos_strh(4))/2-15,pos_strh(3),pos_strh(4)*0.9]);
% 		set(hgui.axes_pic,'Position',[(pos_win(3)-pos_axes_pic(3))/2,(pos_win(4)-pos_axes_pic(4))/2,pos_axes_pic(3),pos_axes_pic(4)]);
% 		set(hgui.rms_axes,'Position',[(pos_win(3)-pos_rms_axes(3))/2,pos_rms_axes(2),pos_rms_axes(3),pos_rms_axes(4)]);
% 		set(hgui.rms_label,'Position',[(pos_win(3)-pos_rms_label(3))/2,pos_rms_label(2),pos_rms_label(3),pos_rms_label(4)]);
% 		set(hgui.rms_too_soft,'Position',[(pos_win(3)-pos_rms_axes(3))/2,pos_rms_too_soft(2),pos_rms_too_soft(3),pos_rms_too_soft(4)]);
% 		set(hgui.rms_too_loud,'Position',[(pos_win(3)-pos_rms_axes(3))/2+pos_rms_axes(3)-pos_rms_too_loud(3),pos_rms_too_loud(2),pos_rms_too_loud(3),pos_rms_too_loud(4)]);
% 		set(hgui.speed_axes,'Position',[(pos_win(3)-pos_speed_axes(3))/2,pos_speed_axes(2),pos_speed_axes(3),pos_speed_axes(4)]);		
% 		set(hgui.speed_label,'Position',[(pos_win(3)-pos_speed_label(3))/2,pos_speed_label(2),pos_speed_label(3),pos_speed_label(4)]);
% 		set(hgui.speed_too_slow,'Position',[(pos_win(3)-pos_speed_axes(3))/2,pos_speed_too_slow(2),pos_speed_too_slow(3),pos_speed_too_slow(4)]);
% 		set(hgui.speed_too_fast,'Position',[(pos_win(3)-pos_speed_axes(3))/2+pos_speed_axes(3)-pos_speed_too_fast(3),pos_speed_too_fast(2),pos_speed_too_fast(3),pos_speed_too_fast(4)]);
%         set(hgui.msgh,'FontSize',17);
% 	else
% 		set(hgui.UIRecorder,'Position',[-1400,180,1254,857],'toolbar','none');
% 	end
	
end

if (subject.showProgress)
	set(hgui.progress_axes,'visible','on');
	set(hgui.progress_imgh,'visible','on');
	progress_meter=0.5*ones(1,100,3);
	progress_mask=zeros(1,100,3);
	set(hgui.progress_imgh,'Cdata',progress_meter.*progress_mask);
    set(hgui.progress_axes, 'YTick', [], 'YColor', [0, 0, 0]);
    set(hgui.progress_axes, 'XTick', [0 : 25 : 100]);
else
	set(hgui.progress_axes,'visible','off');
	set(hgui.progress_imgh,'visible','off');
end

Audapter(2);
if bAlwaysOn    
    AudapterIO('reset');
    Audapter(1);
%     Audapter(3, 'scale', 0);
end

rProgress=0;
startPhase=state.phase; %SC For the purpose of resumed experiments
startRep=state.rep;     %SC For the purpose of resumed experiments
for n=startPhase:length(allPhases)
    state.phase=n;
    state.rep=1;
    thisphase=allPhases{1,n};
    subdirname=fullfile(dirname,thisphase);
    mkdir(subdirname);
    
    hgui.phase=thisphase;
    
    disp(['--- Coming up: ',thisphase,'. nReps = ',num2str(expt.script.(thisphase).nReps),...
          '; nTrials = ',num2str(expt.script.(thisphase).nTrials),' ---']);
    
    % Adjust the number of reps
%     if (~isequal(thisphase,'ramp') && ~isequal(thisphase,'stay'))
%         disp(['--- Coming up: ',thisphase,'. nReps = ',num2str(expt.script.(thisphase).nReps),...
%             '; nTrials = ',num2str(expt.script.(thisphase).nTrials),' ---']);
%         nRepsNew=input('(Modify nReps) nRepsNew = ','s');
%         nRepsNew=str2num(nRepsNew);
%         if (~isempty(nRepsNew) && ~ischar(nRepsNew) && nRepsNew~=expt.script.(thisphase).nReps)
%             expt.script.(thisphase).nReps=nRepsNew;
%             expt.script.(thisphase)=genPhaseScript(thisphase, expt.script.(thisphase).nReps,...
%                 expt.preWords, expt.trialTypes,expt.trainWords,expt.testWords,expt.pseudoWords,...
%                 expt.trialOrderRandReps,expt.subject.designNum);
%             disp(['Changed: ',thisphase,'. nReps = ',num2str(expt.script.(thisphase).nReps),...
%                 '; nTrials = ',num2str(expt.script.(thisphase).nTrials),' ---']);
%             save(fullfile(dirname,'expt.mat'),'expt');
%             disp(['Saved ',fullfile(dirname,'expt.mat')]);
%         end
%     elseif isequal(thisphase,'ramp')
%         disp(['--- Coming up: ','ramp','. nReps = ',num2str(expt.script.ramp.nReps),...
%             '; nTrials = ',num2str(expt.script.ramp.nTrials),' ---']);
%         disp(['--- Coming up: ','stay','. nReps = ',num2str(expt.script.stay.nReps),...
%             '; nTrials = ',num2str(expt.script.stay.nTrials),' ---']);
%         disp(['--- Ramp+Stay: nReps = ',num2str(expt.script.ramp.nReps+expt.script.stay.nReps),...
%             '; nTrials = ',num2str(expt.script.ramp.nTrials+expt.script.stay.nTrials)]);
%         nRepsNew=input('(Modify nReps) Ramp: nRepsNew = ','s');
%         nRepsNew=str2num(nRepsNew);
%         if (~isempty(nRepsNew) && ~ischar(nRepsNew) && nRepsNew~=expt.script.(thisphase).nReps)
%             expt.script.ramp.nReps=nRepsNew;
%             expt.script.ramp=genPhaseScript('ramp',expt.script.ramp.nReps,...
%                 expt.trialTypes,expt.preWords, expt.trainWords,expt.testWords,expt.pseudoWords,...
%                 expt.trialOrderRandReps,expt.subject.designNum);
%             disp(['Changed: ramp. ','nReps = ',num2str(expt.script.ramp.nReps),...
%                 '; nTrials = ',num2str(expt.script.ramp.nTrials),' ---']);
%             save(fullfile(dirname,'expt.mat'),'expt');
%             disp(['Saved ',fullfile(dirname,'expt.mat')]);
%         end
%         nRepsNew=input('(Modify nReps) Stay: nRepsNew = ','s');
%         nRepsNew=str2num(nRepsNew);
%         if (~isempty(nRepsNew) && ~ischar(nRepsNew) && nRepsNew~=expt.script.(thisphase).nReps)
%             expt.script.stay.nReps=nRepsNew;
%             expt.script.stay=genPhaseScript('stay',expt.script.stay.nReps,...
%                 expt.trialTypes,expt.preWords, expt.trainWords,expt.testWords,expt.pseudoWords,...
%                 expt.trialOrderRandReps,expt.subject.designNum);
%             disp(['Changed: stay. ','nReps = ',num2str(expt.script.stay.nReps),...
%                 '; nTrials = ',num2str(expt.script.stay.nTrials),' ---']);
%             save(fullfile(dirname,'expt.mat'),'expt');
%             disp(['Saved ',fullfile(dirname,'expt.mat')]);
%         end
%         disp(['--- Ramp+Stay: nReps = ',num2str(expt.script.ramp.nReps+expt.script.stay.nReps),...
%             '; nTrials = ',num2str(expt.script.ramp.nTrials+expt.script.stay.nTrials)]);
%     end
    % Adjust the number of reps
    
    nReps=expt.script.(thisphase).nReps;
%     if ~isequal(thisphase,'stay')
        phaseTrialCnt=1;
%     end

    expt.script.(thisphase).startTime=clock;

    hgui.showSpeedPrompt = 0;
    hgui.showRmsPrompt = 0;
    hgui.bSpeedRepeat = 0;
    hgui.bRmsRepeat = 0;
	
	if (subject.showPlayButton==0)
		set(hgui.play,'visible','off');
    end        
   
    bIsPertPhase = (length(thisphase) >= 4 && isequal(thisphase(1 : 4), 'rand')) ...
            || isequal(thisphase, 'start') ...
            || isequal(thisphase, 'ramp') ...
            || (length(thisphase) >= 4 && isequal(thisphase(1 : 4), 'stay')) ...
            || isequal(thisphase, 'end');
    
    if isequal(thisphase, 'pre')
            set(hgui.play,'cdata',hgui.skin.play,'userdata',0);

            hgui.showRmsPrompt = 0;
            hgui.showSpeedPrompt = 0;
            hgui.bRmsRepeat=0;
            hgui.bSpeedRepeat=0;
            
            p.bDetect=0;
            p.bShift = 0;       %SC No shift in the practice-1 phase           
            
    elseif isequal(thisphase, 'pract1')         
            set(hgui.play,'cdata',hgui.skin.play,'userdata',0);
%             if (hgui.vumeterMode==1)
%                 vumeter=hgui.skin.vumeter;
%             elseif (hgui.vumeterMode==2)
%                 vumeter=hgui.skin.vumeter2;
%             end
%             mask=0.5*ones(size(vumeter));
%             % mask(1:50,:,:) = 1;           %SC-Commented(12/11/2007)
%             set(hgui.rms_imgh,'Cdata',vumeter.*mask);
            p.bDetect=0;
            p.bShift = 0;       %SC No shift in the practice-1 phase
            
            hgui.showRmsPrompt = 1;
            hgui.showSpeedPrompt = 0;
            hgui.bRmsRepeat=1;
            hgui.bSpeedRepeat=0;
   
            if exist('rmsPeaks') && ~isempty(rmsPeaks)
                p.rmsMeanPeak=mean(rmsPeaks);
%                 p.rmsThresh=p.rmsMeanPeak/4;       %SC !! Adaptive RMS threshold setting. Always updating 
            end

            hgui.showTextCue=1;
            
            subjProdLevel=[];         
            
     elseif isequal(thisphase, 'pract2')
            if exist('subjProdLevel')
                subjProdLevel=subjProdLevel(find(~isnan(subjProdLevel)));

                if (~isempty(subjProdLevel))
                    hgui.rmsTransTarg_spl=mean(subjProdLevel);
                    load('micRMS_100dBA.mat');  % Gives micRMS_100dBA: the rms the microphone should read when the sound is at 100 dBA SPL
                    hgui.rmsTransTarg=micRMS_100dBA / (10^((100-hgui.rmsTransTarg_spl)/20));
                end
            end
            
            fprintf('\n');
            disp(['Target level set as subject mean production level: ',num2str(hgui.rmsTransTarg_spl),' dBA SPL']);
            fprintf('\n');            
             
            set(hgui.play,'cdata',hgui.skin.play,'userdata',0);
            p.bDetect=0;
            p.bShift = 0;
            
            hgui.showRmsPrompt = 1;
            hgui.showSpeedPrompt = 1;
            hgui.bRmsRepeat = 1;  %1 
            hgui.bSpeedRepeat = 1;        %SC Make the speed monitor visible %1
            
            if exist('rmsPeaks') && ~isempty(rmsPeaks)
                p.rmsMeanPeak=mean(rmsPeaks);
%                 p.rmsThresh=p.rmsMeanPeak/4;       %SC !! Adaptive RMS threshold setting. Always updating 
            end 

            hgui.showTextCue=1;

    elseif bIsPertPhase
            if bAlwaysOn
                Audapter(2);
            end
            
            % SC(2008/06/10) Manually determine the optimum tracking params
            % Warning: for consistency, don't change nDelay			
			set(hgui.msgh,'visible','on');
%             set(hgui.msgh_imgh,'CData',CDataMessage.ftparampicking,'visible','on');
			drawnow;
			
			set(hgui.msgh,'string',{'Please stand by...'},'visible','on');
            
            if (hgui.debug==0)
                [vowelF0Mean,vowelF0SD] = getVowelPitches(dirname);
                
                disp(['Vowel meanF0 = ', num2str(vowelF0Mean),' Hz: stdF0 = ',num2str(vowelF0SD),' Hz']);
                disp(['Recommended cepsWinWidth = ',num2str(round(p.sr/vowelF0Mean*0.54))]);
                [vowelF1Mean,vowelF2Mean]=getVowelMeanF1F2(dirname);
                disp(['Vowel meanF1 = ',num2str(vowelF1Mean),' Hz; meanF2 = ',num2str(vowelF2Mean),' Hz']);
                fprintf(1, '\n');
            end
            % ~SC(2008/06/10) Manually determine the optimum tracking
            
            if bAlwaysOn
                Audapter(1);
%                 Audapter(3,'scale',0);
            end
            
            set(hgui.msgh, 'string', {''}, 'visible', 'on'); 
            if exist('rmsPeaks')
                p.rmsMeanPeak=mean(rmsPeaks);
            end
            
            if expt_config.TRIGGER_BY_MRI_SCANNER
                hgui.showRmsPrompt = 0;
                hgui.showSpeedPrompt = 0;
            else
                hgui.showRmsPrompt = 1;
                hgui.showSpeedPrompt = 1;
            end
            hgui.bRmsRepeat = 0;  %1
            hgui.bSpeedRepeat = 0; 

            p.bDetect=1;
            p.bShift=0;
            
            if ~(isequal(thisphase, 'ramp') || ...
                 (length(thisphase) >= 4 && isequal(thisphase(1 : 4), 'stay')) || ...
                 isequal(thisphase, 'end'))
                set(hgui.play,'cdata',hgui.skin.play,'userdata',0);
            end
            hgui.showTextCue=1;
            
            % -- Prepare pitch shift log file -- %
            dfns = dir(fullfile(dirname, 'pitch_shift.*.log'));
            pitchShiftLogFN = fullfile(dirname, sprintf('pitch_shift.%.2d.log', length(dfns) + 1));
            pitchShiftLogF = fopen(pitchShiftLogFN, 'at');
            fprintf(pitchShiftLogF, 'trialFileName, voiceOnset(ms), pitchShiftOnset(ms), pitchShiftEnd(ms), pitchShift(cent)\n');
    end
%     elseif isequal(thisphase, 'start')
%             hgui.showRmsPrompt = 1;
%             hgui.showSpeedPrompt = 1;
%             hgui.bRmsRepeat = 0;  %1 
%             hgui.bSpeedRepeat = 0; 
%             
%             set(hgui.play,'cdata',hgui.skin.play,'userdata',0);
%             hgui.showTextCue=1;
%             
%     elseif isequal(thisphase,'ramp')      %SC !! Notice that adaptive RMS threshold updating is no longer done here.           			
%             hgui.showRmsPrompt = 1;
%             hgui.showSpeedPrompt = 1;
%             hgui.bRmsRepeat = 0;  %1 
%             hgui.bSpeedRepeat = 0; 
%             
%             p.bDetect = 1;
% 			p.bShift = 1;
%             
%             if bAlwaysOn
%                 Audapter(1);
% %                 Audapter(3, 'scale', 0);
%             end
%             
%             set(hgui.play,'cdata',hgui.skin.play,'userdata',0);
% 			hgui.showTextCue=1;
% 
%             
% %             if doPlot
% %                 uiwait(gcf,10);
% % 			end
%     elseif isequal(thisphase, 'stay')
% 			set(hgui.msgh,'visible','on');
%             
%             hgui.showRmsPrompt = 1;
%             hgui.showSpeedPrompt = 1;
%             hgui.bRmsRepeat = 0;  %1 
%             hgui.bSpeedRepeat = 0; 
%             
%             p.bDetect = 1;
%             p.bShift = 1;
%             hgui.showTextCue=1;
%     elseif isequal(thisphase, 'end')
% 			set(hgui.msgh,'visible','on');
%             
%             hgui.showRmsPrompt = 1;
%             hgui.showSpeedPrompt = 1;
%             hgui.bRmsRepeat = 0;  %1 
%             hgui.bSpeedRepeat = 0; 
%             
%             p.bDetect = 0;
%             p.bShift = 0;
%             hgui.showTextCue=1;
%             elseif isequal(thisphase, 'test3')
%     end

    drawnow    

%     set(hgui.msgh,'string',getMsgStr(thisphase),'visible','on');    
    set(0, 'CurrentFigure', hgui.UIRecorder);
    xs = get(gca, 'XLim');
    ys = get(gca, 'YLim');
    set(hgui.msgTxt, 'visible', 'on', 'String', getMsgStr(thisphase));
%     htxt = text(xs(1) + 0.05 * range(xs), ys(1) + 0.95 * range(ys), getMsgStr(thisphase), ...
%                 'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'normal', 'Color', 'b');

%     if ~bAlwaysOn
    if isfile(fullfile(dirname, 'p.mat'))
        load(fullfile(dirname, 'p.mat'))    % gives p;            
    end
    AudapterIO('init',p);  %SC Inject p to Audapter
%     else
%         p0 = p;
%         p0.dScale=0;
%         AudapterIO('init',p0);
%     end

    for i0 = startRep : nReps    %SC Loop for the reps in the phase
        repString=['rep',num2str(i0)];
        state.rep=i0;
        state.params=p;
        save(fullfile(dirname,'state.mat'),'state');
        
        nTrials=length(expt.script.(thisphase).(repString).trialOrder);

        subsubdirname=fullfile(subdirname, repString);
        mkdir(subsubdirname);
		
		% --- Perturbation field ---
		p.pertF2=linspace(p.F2Min, p.F2Max, p.pertFieldN);
%         if isequal(subject.expt_config.PERT_MODE, 'FMT')
%             t_amp = norm([subject.expt_config.SHIFT_RATIO_SUST_F1, ...
%                           subject.expt_config.SHIFT_RATIO_SUST_F2]);
%             t_angle = angle(subject.expt_config.SHIFT_RATIO_SUST_F1 + ...
%                             i * subject.expt_config.SHIFT_RATIO_SUST_F2);        
%         end

        pcf_fn = fullfile(subsubdirname, 'fmt.pcf');
           
        if ~bIsPertPhase
            p.bShift = 0;
            p.pitchShiftRatio = 0;
            p.pertAmp = zeros(1, p.pertFieldN);
            p.pertPhi = zeros(1, p.pertFieldN);
            gen_pert_pcf(subject.expt_config.OST_MAX_STATE, subject.expt_config.PERT_STATES, ...
                         0, 0, 0, pcf_fn);
                     
            check_file(pcf_fn);
            AudapterIO('pcf', pcf_fn, [], 0);
        end
        
%         AudapterIO('ost', subject.expt_config.OST_FN, [], 0);
        
% 		if ~bAlwaysOn
            AudapterIO('init',p);  %SC Inject p to Audapter
%         else
%             p0=p; 
%             p0.dScale=0;
%             AudapterIO('init',p0);
%         end
		% --- ~Perturbation field ---

        for k = 1 : nTrials
            thisTrial = expt.script.(thisphase).(repString).trialOrder(k); % 0: silent; 1: no noise; 2: noise only; 			
            thisWord = expt.script.(thisphase).(repString).word{k};     %SC Retrieve the word from the randomly shuffled list

            if iscell(thisTrial)
                thisTrial = thisTrial{1};
            end
            
            ost = fullfile(subsubdirname, ['trial-', num2str(k), '-', num2str(thisTrial), '.ost']);
            pcf = fullfile(subsubdirname, ['trial-', num2str(k), '-', num2str(thisTrial), '.pcf']);
            
            p.pertAmp = zeros(1, p.pertFieldN);
            p.pertPhi = zeros(1, p.pertFieldN);
            p.bShift = 1;
            p.bPitchShift = double(~isempty(find(struct2array(expt.pertDes.pitchShifts_cent) ~= 0, 1)));
            p.pitchShiftRatio = NaN;
            
            if bIsPertPhase   % Configure perturbation
                fprintf(1, 'Pert type = [%s]\n', thisTrial);
                
                if ~(isequal(thisTrial, 'ctrl') || isequal(thisTrial, 'baseline'))
                    p.pertAmp = abs(expt.script.(thisphase).(repString).F1Shifts_ratio{k}(1) + 1i * expt.script.(thisphase).(repString).F2Shifts_ratio{k}(1)) * ones(1, p.pertFieldN);
                    p.pertPhi = angle(expt.script.(thisphase).(repString).F1Shifts_ratio{k}(1) + 1i * expt.script.(thisphase).(repString).F2Shifts_ratio{k}(1)) * ones(1, p.pertFieldN);
                    
                    gen_multi_pert_pcf(ost, pcf, expt_config.INTENSITY_THRESH, ...
                                       expt.script.(thisphase).(repString).pitchShifts_cent{k}, ...
                                       expt.script.(thisphase).(repString).intShifts_dB{k}, ...
                                       expt.script.(thisphase).(repString).F1Shifts_ratio{k}, ...
                                       expt.script.(thisphase).(repString).F2Shifts_ratio{k}, ...
                                       expt.script.(thisphase).(repString).shifts_onset{k}, ...                                       
                                       expt.script.(thisphase).(repString).shiftDurs_ms{k});
                else % No perturbation
                    p.pertAmp = zeros(1, p.pertFieldN);
                    p.pertPhi = zeros(1, p.pertFieldN);
                    
                    gen_multi_pert_pcf(ost, pcf, ...
                                       expt_config.INTENSITY_THRESH, ...
                                       [0], [0], [0], [0], [60], [20]);
                end                               
                
                AudapterIO('init', p);
                
                check_file(ost);
                check_file(pcf);
                        
                if DEBUG_PS
                    fprintf(pitchShiftLogF, 'Loading ost file: %s...\n', ost); % DEBUG
                end
                AudapterIO('ost', ost, [], 0);
                if DEBUG_PS
                    fprintf(pitchShiftLogF, 'Done.\n');
                end
                
                if DEBUG_PS
                    fprintf(pitchShiftLogF, 'Loading pcf file: %s...\n', ost); % DEBUG
                end
                AudapterIO('pcf', pcf, [], 0);
                if DEBUG_PS
                    fprintf(pitchShiftLogF, 'Done.\n');
                end
            end

			hgui.trialType=thisTrial;
			hgui.word=thisWord;
            hgui.phase = thisphase;
            hgui.repNum = i0;
            hgui.trialNum = k;

%             if (hgui.trialType==2 || hgui.trialType==3)	% Speech with masking noise or passively listening to masking noise
%                 Audapter(3,'datapb',gainMTB_fb*x_mtb{3-mod(k,3)},0);
% 			end
               
			disp('');
            if (ischar(thisWord))
    			disp([thisphase,' - ',repString,', k = ',num2str(k),': trialType = ',num2str(hgui.trialType),' - ',thisWord]);
            else
                disp([thisphase,' - ',repString,', k = ',num2str(k),': trialType = ',num2str(hgui.trialType),' - Pseudoword-',num2str(thisWord)]);
            end
            
            % Count down    
            if ~(isequal(thisphase,'start') || isequal(thisphase,'ramp') || isequal(thisphase,'stay') || isequal(thisphase,'end'))
                disp(['Left: ',num2str(expt.script.(thisphase).nTrials - phaseTrialCnt+1),'/',num2str(expt.script.(thisphase).nTrials)]);
            else
                if ~(isequal(thisphase,'ramp') || isequal(thisphase,'stay'))
                    disp(['Left: ',num2str(expt.script.(thisphase).nTrials-phaseTrialCnt+1),'/',num2str(expt.script.(thisphase).nTrials),...
                        ', ',num2str((expt.script.(thisphase).nTrials-phaseTrialCnt+1)*hgui.ITI),' sec']);
                else
                    disp(['Left: ',num2str(expt.script.ramp.nTrials+expt.script.stay.nTrials-phaseTrialCnt+1),'/',...
                        num2str(expt.script.ramp.nTrials+expt.script.stay.nTrials),...
                        ', ',num2str((expt.script.ramp.nTrials+expt.script.stay.nTrials-phaseTrialCnt+1)*hgui.ITI),' sec']);
                end
            end
            % ~Count down
            
            if (isnumeric(hgui.trialType) && hgui.trialType >= 2)   %SC The distinction between train and test words                             
                Audapter(3, 'bdetect', 0, 1);
                Audapter(3, 'bshift', 0, 1);
			else
                Audapter(3, 'bdetect', p.bDetect, 1);
                Audapter(3, 'bshift', p.bShift, 1);                
            end
            
%             if (thisTrial==5)
% 				hgui.skin.facePnt=expt.script.(thisphase).(repString).face(k);
%             end
            
            updateParamDisp(p, hgui);
            set(hgui.button_reproc, 'enable', 'off');
            
%             if DEBUG_PS && isequal(thisphase, 'rand')
%                 hgui.ps_pitchShiftLogF = pitchShiftLogF;
%             end
            UIRecorder('singleTrial', hgui.play, 1, hgui);
            data = get(hgui.UIRecorder, 'UserData');           %SC Retrieve the data
            
            % -- Write pitch shift log -- 
            if bIsPertPhase
                [psSummary, voiceOnset] = getPitchShiftTimeStamps(data);
                for k2 = 1 : length(psSummary)
                    fprintf(pitchShiftLogF, '%s/%s/%s, %f, %f, %f, %f\n', ...
                            thisphase, repString, ...                            
                            ['trial-', num2str(k), '-', num2str(thisTrial)], ...
                            voiceOnset, ...
                            psSummary{k2}(1), psSummary{k2}(2), psSummary{k2}(3));
                end
            end
            
            % -- Attach uiConfig info --
            load(hgui.uiConfigFN);
            data.uiConfig = uiConfig;
            clear('uiConfig');
            
            % -- Update the parameter settings --
            checkParams = {'rmsThresh', 'nLPC', 'fn1', 'fn2', 'aFact', 'bFact', 'gFact'};
            for k0 = 1 : numel(checkParams)
                t_param = checkParams{k0};
                if ~isequal(p.(t_param), data.params.(t_param))
                    fprintf('Updating parameter %s: %f --> %f\n', t_param, p.(t_param), data.params.(t_param));
                    p.(t_param) = data.params.(t_param);
                    
                end
            end
            
            data.timeStamp=clock;
            data.subject=expt.subject;
            data.params.name=thisWord;
            data.params.trialType=thisTrial;
            
            if (thisTrial==1)
                if ~exist('rmsPeaks')
                    rmsPeaks = [];
                end
                
                if ~isempty(data.rms)
                    switch (thisphase)  %SC Record the RMS peaks in the bout
                        case 'pre'
                            rmsPeaks=[rmsPeaks ; max(data.rms(:,1))];
                        case 'pract1',
                            rmsPeaks=[rmsPeaks ; max(data.rms(:,1))];                    
                        case 'pract2',
                            rmsPeaks=[rmsPeaks ; max(data.rms(:,1))];                    
                        otherwise,
                    end
                end
            end
            
            if (isequal(thisphase,'pract1'))
                if (thisTrial==1 || thisTrial==2)
                    if (isfield(data,'vowelLevel') && ~isempty(data.vowelLevel) && ~isnan(data.vowelLevel) && ~isinf(data.vowelLevel))
                        subjProdLevel=[subjProdLevel,data.vowelLevel];
                    end
                end
            end
			
            save(fullfile(subsubdirname, ['trial-',num2str(k),'-',num2str(thisTrial)]),'data');
            disp(['Saved ',fullfile(subsubdirname,['trial-',num2str(k),'-',num2str(thisTrial)]),'.']);
            disp(' ');
            
            phaseTrialCnt=phaseTrialCnt+1;

            % Calculate and show progress
            if (subject.showProgress)
                [rProgress, nDoneTrials, nTotTrials] = calcExpProgress(expt, thisphase, i0, k, rProgress);
				if (~isnan(rProgress))
	                progress_mask=zeros(size(progress_meter));
		            progress_mask(:,1:round(rProgress*100),:)=1;            
			        set(hgui.progress_imgh, 'Cdata', progress_meter .* progress_mask);
                    set(hgui.txt_prog, 'String', sprintf('Completed: %d / %d', nDoneTrials, nTotTrials));
				end
            end
            
            if isequal(thisphase, 'pre') || isequal(thisphase,'pract1') || isequal(thisphase,'pract2') && ...
                ~isempty(data) && ~isempty(data.fmts)
                items={'rmsThresh', 'nLPC', 'fn1', 'fn2'};
                toRepeat=1;
                while toRepeat
                    statMsg = '[';
                    for k1  = 1 : numel(items)
                        statMsg = [statMsg, sprintf('%s=%.4f', items{k1}, p.(items{k1}))];
                        if k1 ~= numel(items)
                            statMsg = [statMsg, '; '];
                        else
                            statMsg = [statMsg, ']'];
                        end
                    end
                    
                    fprintf('%s\n', statMsg);
                    cmdAdj = input(sprintf('cmd: '), 's');
                    cmdAdj = strrep(cmdAdj, ' ', '');
                    
                    for j1=1:length(items)
                        cmdAdj=strrep(cmdAdj,';','');
                        idx=strfind(cmdAdj,[items{j1},'=']);
                        if ~isempty(idx)
                            tVal=str2num(cmdAdj(idx+length([items{j1},'=']) : end));
                            if ~isfield(p, items{j1})
                                fprintf('WARNING: p does not have the field %s\n', items{j1})
                                cmdAdj = '';
                            else
                                p.(items{j1})=tVal;
                            end
                            
%                             data=reprocAPSTVData(data,'iF2LB',p.iF2LB,'uF2UB',p.uF2UB,'rmsThresh',p.rmsThresh);
%                             taxis1=0 : (data.params.frameLen/data.params.sr) : (data.params.frameLen/data.params.sr)*(length(data.sentStat)-1);
%                             plot(taxis1,data.sentStat*250,'w','LineWidth',2); hold on;
%                             set(gca,'XLim',xs);
%                             save(fullfile(subsubdirname,['trial-',num2str(k),'-',num2str(thisTrial)]),'data');
%                             disp(['Saved NEW ',fullfile(subsubdirname,['trial-',num2str(k),'-',num2str(thisTrial)]),'.']);
                        end
                    end
                    if isempty(cmdAdj) || isequal(lower(cmdAdj),'q')
                        toRepeat=0;
                    end
                end
                
            end
        end
    end
    startRep=1;
end

fclose(pitchShiftLogF);

set(hgui.play,'cdata',hgui.skin.play,'userdata',0);
set(hgui.msgh,'string',...
	{'Congratulations!';...
	'You have finished the expt.'},'visible','on');
% set(hgui.msgh_imgh,'CData',CDataMessage.finish,'visible','on');
pause(3);
close(hgui.UIRecorder)
pause(2);
% saveExperiment(dirname);

if bAlwaysOn
    Audapter(2);
end

save(fullfile(dirname,'expt.mat'),'expt');
save(fullfile(dirname,'state.mat'),'state');

%% F1 JND (perceptual acuity) test
% percTokenInfo=chooseEHPercToken(dirname,'HEAD');
% percTokenInfo.prodF0=expt.ehaeInfo.F0;
% percTokenInfo.x0=1.0;
% percTokenInfo.bAlwaysOn=bAlwaysOn;

% expt.percTokenInfo=percTokenInfo;
save(fullfile(dirname,'expt.mat'),'expt');

% eh_discrim([expt.subject.name,'_updown1'],'eh',expt.subject.percDir,6,expt.percTokenInfo,expt.percTokenInfo.x0,'twoScreens');
% eh_discrim([expt.subject.name,'_updown2'],'eh',expt.subject.percDir,6,expt.percTokenInfo,expt.percTokenInfo.x0,'twoScreens');
% eh_discrim([expt.subject.name,'_updown3'],'eh',expt.subject.percDir,6,percTokenInfo,x0,'twoScreens');
% eh_discrim([expt.subject.name,'_updown4'],'eh',expt.subject.percDir,6,percTokenInfo,x0,'twoScreens');
% eh_discrim([expt.subject.name,'_updown5'],'eh',expt.subject.percDir,6,percTokenInfo,x0,'twoScreens');
% eh_discrim([expt.subject.name,'_updown6'],'eh',expt.subject.percDir,6,percTokenInfo,x0,'twoScreens');

return

