function varargout = UIRecorder(varargin)
% UIRECORDER M-file for uirecorder.fig
%      UIRECORDER, by itself, creates a new UIRECORDER or raises the existing
%      singleton*.
%
%      H = UIRECORDER returns the handle to a new UIRECORDER or the handle to
%      the existing singleton*.
%
%      UIRECORDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIRECORDER.M with the given input arguments.
%
%      UIRECORDER('Property','Value',...) creates a new UIRECORDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UIRecorder_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UIRecorder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uirecorder

% Last Modified by GUIDE v2.5 05-Aug-2013 16:36:07

%%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @UIRecorder_OpeningFcn, ...
    'gui_OutputFcn',  @UIRecorder_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% SCai: data displaying function
% if (~isempty(findStringInCell(varargin,'figIdDat'))) 
%     figIdDat=varargin{findStringInCell(varargin,'figIdDat')+1};
% end
% 
% if ~isempty(fsic(varargin, 'dirname'))
%     dirname = varargin{fsic(varargin, 'dirname') + 1};
% end

%% --- Executes just before uirecorder is made visible.
function UIRecorder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
if (length(varargin)>=2)
    figIdDat=varargin{2};
else
    figIdDat=[];
end

if (~isempty(findStringInCell(varargin,'trad')))
	isTrad=1;
else 
	isTrad=0;
end

if ~isempty(fsic(varargin, 'dirname'))
    dirname = varargin{fsic(varargin, 'dirname') + 1};
end

handles.trigByScanner=0;
handles.TA=2.0;
handles.phase='';
handles.trigKey = 'equal';	% To change
handles.trialLen = 3;
handles.trialLenMax = 8;
handles.debug=0;
handles.vumeterMode=NaN;  % 1: 10 ticks; 2: 3 ticks;
handles.bShowCorrAnim = 1;

handles.debug_pitchShiftLogF = 0;

handles.showKidsAnim = 0;
              
handles.timeCreated=clock;

% handles.promptGain = 0.2;

handles.bAlwaysOn = 0;
handles.dScale = 1;

handles.msgImgDir='./uimg';
handles.utterImgDir='./utterimg';
if (isTrad)
	handles.msgImgDir=fullfile(handles.msgImgDir,'trad');
	handles.utterImgDir=fullfile(handles.utterImgDir,'trad');
end

handles.showRmsPrompt = 1;
handles.showSpeedPrompt = 1;
handles.promptMode = 'v'; % 'v', 'a', 'or 'av'

% --- SMN related --- %
handles.smnGain = 10.0;
handles.smnFF0 = 0.8;
handles.smnFF0 = 0.95;
handles.smnOnRamp = 0.08;
handles.smnOffRamp = 0.10;

handles.fb3Gain = 0.0;

% --- OST and PCF related --- %
handles.pertStates = [1, 2];

set(hObject,'visible','off');
set(handles.UIRecorder,'interruptible','on','busyaction','queue')
%--------------------------------------------------------------------------
%SC Construct the volume/speed indicator template
% vumeter  = permute(jet(100),[1,3,2]);
% color1=vumeter(20,:,:);
% color2=vumeter(53,:,:);
% color3=vumeter(90,:,:);
% for n=1:100
%     if n<=30
%         vumeter(n,:,:)=color1;
%     elseif n<=70
%         vumeter(n,:,:)=color2;
%     else
%         vumeter(n,:,:)=color3;
%     end
% end
% vumeter2=vumeter;
% vumeter(10:10:90,:)=0;    %SC-Commented(12/11/2007)
% vumeter0=nan(size(vumeter,2),size(vumeter,1),size(vumeter,3));
% vumeter0(:,:,1)=transpose(vumeter(:,:,1));
% vumeter0(:,:,2)=transpose(vumeter(:,:,2));
% vumeter0(:,:,3)=transpose(vumeter(:,:,3));
% vumeter=vumeter0;
% % vubounds=[1,30,70,100];%SC The boundaries are at 29 and 69.
% 
% vumeter2([30,70],:)=0;
% vumeter02=nan(size(vumeter2,2),size(vumeter2,1),size(vumeter2,3));
% vumeter02(:,:,1)=transpose(vumeter2(:,:,1));
% vumeter02(:,:,2)=transpose(vumeter2(:,:,2));
% vumeter02(:,:,3)=transpose(vumeter2(:,:,3));
% vumeter2=vumeter02;
%--------------------------------------------------------------------------
%SC Construct the progress indicator template
progressmeter=1*ones(1,100,3);
%SC ~Construct the progress indicator template
%--------------------------------------------------------------------------
% if (handles.vumeterMode==1)
%     handles.rms_imgh = image(vumeter,'parent',handles.rms_axes);
%     handles.speed_imgh=image(vumeter,'parent',handles.speed_axes);
%     set(handles.rms_imgh,'CData',zeros(size(vumeter)));
%     set(handles.speed_imgh,'CData',zeros(size(vumeter)));
% else
%     handles.rms_imgh = image(vumeter,'parent',handles.rms_axes);
%     handles.speed_imgh=image(vumeter,'parent',handles.speed_axes);
%     set(handles.rms_imgh,'CData',zeros(size(vumeter2)));
%     set(handles.speed_imgh,'CData',zeros(size(vumeter2))); 
% end

if (~isempty(findStringInCell(varargin,'showVuMeter')))    
    set(handles.rms_imgh,'CData',vumeter0);
end



% if (~isempty(findStringInCell(varargin,'showVuMeter')))
%     set(handles.speed_imgh,'CData',vumeter0);
% end

% set(handles.phrase_axes,'Box','off');
% set(handles.axes_msgh,'Box','off');
set(handles.axes_pic,'Box','off');


handles.progress_imgh = image(progressmeter,'parent',handles.progress_axes);

% set(handles.rms_label,'string','Volume');
% set(handles.speed_label,'string','Speed');

handles.pcrKnob=NaN;
% handles.trialType=4;
% handles.word='Ready...';

% handles.bAuto=1;

handles.time1=[];
handles.time2=[];

% set(handles.auto_btn,'Value',get(handles.auto_btn,'Max'));
skin=struct('pause', imread(fullfile(pwd,'graphics','skin-pause.jpg')),...
    'play', imread(fullfile(pwd,'graphics','skin-play.jpg')),...
    'good', imread(fullfile(pwd,'graphics','choice-yes.gif')),...
    'bad', imread(fullfile(pwd,'graphics','choice-cancel.gif')),...
	'fixation',imread(fullfile(pwd,'graphics','fixation.bmp')),...
	'faceOrder', [],...
	'facePnt', 1);

skin.bed = double(imread(fullfile(pwd, 'images', 'cartoon-bed-1.png'))) / 255.;
skin.bed_alt{1} = double(imread(fullfile(pwd, 'images', 'cartoon-bed-a1.png'))) / 255.;
skin.bed_alt{2} = double(imread(fullfile(pwd, 'images', 'cartoon-bed-a2.png'))) / 255.;
skin.bed_alt{3} = double(imread(fullfile(pwd, 'images', 'cartoon-bed-a3.png'))) / 255.;
skin.bed_alt{4} = double(imread(fullfile(pwd, 'images', 'cartoon-bed-a4.png'))) / 255.;

skin.head = double(imread(fullfile(pwd, 'images', 'cartoon-head-a1.png'))) / 255.;
skin.head0 = double(imread(fullfile(pwd, 'images', 'cartoon-head-1.png'))) / 255.;
skin.head_alt{1} = double(imread(fullfile(pwd, 'images', 'cartoon-head-a2.png'))) / 255.;
skin.head_alt{2} = double(imread(fullfile(pwd, 'images', 'cartoon-head-a3.png'))) / 255.;
skin.head_alt{3} = double(imread(fullfile(pwd, 'images', 'cartoon-head-a4.png'))) / 255.;
skin.head_alt{4} = double(imread(fullfile(pwd, 'images', 'cartoon-head-a5.png'))) / 255.;
skin.head_alt{5} = double(imread(fullfile(pwd, 'images', 'cartoon-head-a6.png'))) / 255.;
skin.head_alt{6} = double(imread(fullfile(pwd, 'images', 'cartoon-head-a7.png'))) / 255.;

skin.Ted = double(imread(fullfile(pwd, 'images', 'cartoon-ted-1.png'))) / 255.;
skin.Ted2 = double(imread(fullfile(pwd, 'images', 'cartoon-ted-2.png'))) / 255.;

skin.bird_nFrames = numel(dir(fullfile(pwd, 'images', 'cartoon-bird-flying-1-*.jpg')));
skin.birdFrames = cell(1, skin.bird_nFrames);
for i1 = 1 : skin.bird_nFrames
    skin.birdFrames{i1} = double(imread(fullfile(pwd, 'images', sprintf('cartoon-bird-flying-1-%.3d.jpg', i1)))) / 255.;
end

skin.tick = double(imread(fullfile(pwd, 'images', 'cartoon-tickmark-1.jpg'))) / 255.;
skin.pencil_ruler = double(imread(fullfile(pwd, 'images', 'cartoon-pencil-ruler-1.jpg'))) / 255.;
skin.pencil_long_1 = double(imread(fullfile(pwd, 'images', 'cartoon-pencil-long.jpg'))) / 255.;
skin.pencil_short_1 = double(imread(fullfile(pwd, 'images', 'cartoon-pencil-short.jpg'))) / 255.;
skin.ruler = double(imread(fullfile(pwd, 'images', 'cartoon-ruler-1.jpg'))) / 255.;
skin.speaker_base = double(imread(fullfile(pwd, 'images', 'cartoon-speaker_base.png'))) / 255.;
skin.speaker_loud_1 = double(imread(fullfile(pwd, 'images', 'cartoon-speaker_loud_1.png'))) / 255.;
skin.speaker_soft_1 = double(imread(fullfile(pwd, 'images', 'cartoon-speaker_soft_1.png'))) / 255.;

handles.skin=skin;

% Create subplot slots for images and animations
hkf = figure('Position', [50, 100, 1000, 600], 'Color', 'w', ...
             'Name', 'Participant window', 'NumberTitle', 'off', ...
             'Toolbar', 'none', 'Menubar', 'none');
handles.hkf = hkf;

handles.msgTxt = uicontrol('Parent', handles.hkf, 'Style', 'text', ...
                           'Unit', 'normalized', ...
                           'Position', [0.05, 0.45, 0.9, 0.5], ...
                           'String', {'Hello', 'world'}, ...
                           'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'normal', 'ForegroundColor', [0, 0, 1], ...
                           'HorizontalAlignment', 'left', ...
                           'visible', 'off');

nMainPanels = 3;
leftMargin = 0.075;
panelSpacing = 0.025;
panelWidth = (1 - 2 * leftMargin - (nMainPanels - 1) * panelSpacing) / nMainPanels;
panelHeight = 0.525;

hsp = nan(1, nMainPanels);
for i1 = 1 : nMainPanels
    hsp(i1) = subplot('Position', [leftMargin + (i1 - 1) * (panelWidth + panelSpacing), 0.375, panelWidth, panelHeight]);
    set(gca, 'XTick', [], 'YTick', []);
    set(gca, 'XColor', 'w', 'YColor', 'w');
end
% hsp_1 = subplot('Position', [0.1, 0.375, 0.275, 0.6]);
% hsp_2 = subplot('Position', [0.4, 0.375, 0.275, 0.6]);
% hsp_3 = subplot('Position', [0.7, 0.375, 0.275, 0.6]);

handles.nMainPanels = nMainPanels;
handles.leftMargin = leftMargin;
handles.panelSpacing = panelSpacing;
handles.panelWidth = panelWidth;
handles.panelHeight = panelHeight;
handles.hsp = hsp;
% handles.hsp_1 = hsp_1;
% handles.hsp_2 = hsp_2;
% handles.hsp_3 = hsp_3;

% Panels for intensity and duration display
hsp_vol = subplot('Position', [0.3, 0.05, 0.15, 0.25]);
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XColor', 'w', 'YColor', 'w');
hsp_dur = subplot('Position', [0.6, 0.05, 0.15, 0.25]);
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XColor', 'w', 'YColor', 'w');

handles.hsp_vol = hsp_vol;
handles.hsp_dur = hsp_dur;

hsp_resp = subplot('Position', [0.465, 0.92, 0.15, 0.075]);
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XColor', 'w', 'YColor', 'w');

handles.hsp_resp = hsp_resp;


hsp_corrCnt = subplot('Position', [0.05, 0.1, 0.05, 0.075]);
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XColor', 'w', 'YColor', 'w');

if handles.showKidsAnim
    htxt_corrCnt = text(0, 0, 'You have made 0 correct responses!', 'Color', 'b', 'FontSize', 12);
else
    htxt_corrCnt = NaN;
end

handles.hsp_corrCnt = hsp_corrCnt;
handles.htxt_corrCnt = htxt_corrCnt;
handles.corrCnt = 0;
handles.dirname = dirname;

if ~isfile(fullfile(handles.dirname, 'corr_count.mat'))
    corr_count = 0;
    save(fullfile(handles.dirname, 'corr_count.mat'), 'corr_count');
end

set(0, 'CurrentFigure', handles.UIRecorder);

handles.showWordHint = 1;
handles.showWarningHint = 1;
handles.showInfoOnlyErr = 0;
handles.showCorrCount = 1;
handles.trialStartWithAnim = 1;
handles.trialPresetDur = 1;
handles.promptMode = 'v';
handles.promptVol = -6; % dB [-30, 3]

handles.uiConfigFN = fullfile(handles.dirname, 'uiConfig.mat');
if ~isfile(handles.uiConfigFN)
    uiConfig = struct('showWordHint', handles.showWordHint, ...
                      'showWarningHint', handles.showWarningHint, ...
                      'showInfoOnlyErr', handles.showInfoOnlyErr, ...
                      'showCorrCount', handles.showCorrCount, ...
                      'bShowCorrAnim', handles.bShowCorrAnim, ...
                      'trialStartWithAnim', handles.trialStartWithAnim, ...
                      'trialPresetDur', handles.trialPresetDur, ...
                      'promptMode', handles.promptMode, ...
                      'promptVol', handles.promptVol);
    save(handles.uiConfigFN, 'uiConfig');
else
    load(handles.uiConfigFN);   % gives uiConfig
    handles.showWordHint = uiConfig.showWordHint;
    handles.showWarningHint = uiConfig.showWarningHint;
    handles.showInfoOnlyErr = uiConfig.showInfoOnlyErr;
    handles.showCorrCount = uiConfig.showCorrCount;
    handles.bShowCorrAnim = uiConfig.bShowCorrAnim;
    handles.trialStartWithAnim = uiConfig.trialStartWithAnim;
    handles.trialPresetDur = uiConfig.trialPresetDur;
    handles.promptMode = uiConfig.promptMode;
    handles.promptVol = uiConfig.promptVol;
end

% handles.pic_imgh=image(handles.skin.fixation,'parent',handles.axes_pic);
% set(handles.pic_imgh,'visible','off');

% set(handles.prev,'cdata',skin.prev);
% set(handles.next,'cdata',skin.next);
set(handles.play,'cdata',skin.play);
set(handles.play,'UserData',0);
set(handles.play,'Value',get(handles.play,'Min'));
% set(handles.rms_axes,'xtick',[],'ytick',[]);
% axis(handles.rms_axes, 'xy');

% set(handles.speed_axes,'xtick',[],'ytick',[])
% axis(handles.speed_axes, 'xy');

% set(handles.axes_pic,'xtick',[],'ytick',[],'box','off','visible','off');

% set(handles.progress_axes,'xtick',[],'ytick',[]);
% axis(handles.progress_axes, 'xy');

handles.figIdDat=figIdDat;

handles.dataOut=[];
handles.bRmsRepeat=0;
handles.bSpeedRepeat=0;
handles.vocaLen=NaN;    %SC-Mod(2008/01/05) Old value: 300 
handles.lenRange=NaN;   %SC(2008/01/05)

handles.ITI=6;			%SC(2009/02/05) Inter-trial interval

handles.showTextCue=0;  %SC(2008/01/06)

handles.dBRange=NaN;
handles.rmsTransTarg_spl=NaN;
% load calibMic;  % gets micGain: wav rms/ Pa rms (Pa^-1)
load('micRMS_100dBA.mat');  % Gives micRMS_100dBA: the rms the microphone should read when the sound is at 100 dBA SPL
handles.rmsTransTarg=micRMS_100dBA / (10^((100-handles.rmsTransTarg_spl)/20));

handles.nextMessage=imread(fullfile(handles.msgImgDir,'message_pre2.bmp'));

set(handles.UIRecorder,'keyPressFcn',@key_Callback);
set(handles.strh,'keyPressFcn',@key_Callback);
set(handles.play,'keyPressFcn',@key_Callback);
% set(handles.rec_slider,'keyPressFcn',@key_Callback);
set(handles.msgh,'keyPressFcn',@key_Callback);

set(handles.strh,'string','HELLO','visible','on');

set(hObject,'visible','on');

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes uirecorder wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% --- Outputs from this function are returned to the command line.
function varargout = UIRecorder_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = handles;

%% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of play

% set(handles.button_next,'visible','off');

% CDataMessageBlank=zeros(750,720,3);
% CDataMessageBlank(:,:,1)=64/255*ones(750,720);
% CDataMessageBlank(:,:,3)=64/255*ones(750,720);

if(get(handles.play,'userdata')==0) % currently in pause mode
    set(handles.play,'cdata',handles.skin.pause,'userdata',1); % now in play mode
    set(handles.msgh,'string','');
	handles.trialType=-1;
	handles.word='Ready...';	

    singleTrial(handles.play,[],handles)   %%SC
else % currently in play mode
    set(handles.play,'cdata',handles.skin.play,'userdata',0); % now in pause mode
    if handles.bAlwaysOn == 1
%         Audapter(3, 'scale', 0);
    else
        Audapter(2) %%SC stop Audapter
    end
    set(handles.msgh,'string','Press play to continue...');
end

function key_Callback(src, evnt)
hgui=guidata(src);
timeNow=clock;
eTime=etime(timeNow,hgui.timeCreated);

if (isequal(evnt.Key,hgui.trigKey) || isequal(evnt.Key,'a'))
% 	set(hgui.uirecorder,'UserData','go');
    disp(['--> Trigger at ',num2str(eTime),' sec <--']);
	uiresume(hgui.UIRecorder);
else
% 	set(hgui.uirecorder,'UserData','nogo');
end

return

% %% --- Executes on button press in prev.
% function prev_Callback(hObject, eventdata, handles)
% % hObject    handle to prev (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% singleTrial(handles.prev,[],handles);

%% --- Executes on button press in next.
% function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% --- Single trial callback function.
function singleTrial(hObject, eventdata, handles, varargin)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(handles.next,'enable','off','visible','off')
% set(handles.prev,'enable','off','visible','off')
record(handles);

%% SUBFUNCTIONS
%% --------------------------------------------------------------------------
function [dataOut, rmsRes, speedRes] = checkData(data, handles)
% This function is called after stoprec is executed. It checks the data and
% displays the rms and transition length . If the rms and speed are in range
%, the data is stored in handles.dataOut.

% t0=1/data.params.sr;
% taxis=0:t0:t0*(length(data.signalIn)-1);

dBrange=handles.dBRange; %SC-Mod(2008/01/05). One side tolerance: 0.4*dBrange 
rmsval=50;
speedval=0;
dataOut=data;

% if (handles.bMon==1)
[i1,i2,f1,f2,iv1,iv2]=getFmtPlotBounds(data.fmts(:,1),data.fmts(:,2));
[k1,k2]=detectVowel(data.fmts(:,1),data.fmts(:,2),iv1,iv2,'eh','rms',data.rms(:,1));
if ~isempty(data)
	vocaLen=handles.vocaLen;
	lenRange=handles.lenRange;
	rmsTransTarg=handles.rmsTransTarg;

	t1=k1*data.params.frameLen;
	t2=k2*data.params.frameLen;

	vocaLenNow=k2-k1+1;   %SC-Mod(2008/04/06)
    
    if ~(isnan(k1) || isnan(k2) || k1==0 || k2==0 || k2<=k1) && k2-k1>=60
        tSig=data.signalIn((k1+1)*data.params.frameLen:(k2-1)*data.params.frameLen);
        if data.params.nLPC<12
            sex='female';
        else
            sex='male';
        end
        dataOut.f0s=getPitch(tSig,data.params.sr,sex);
        dataOut.medianF0=nanmedian(dataOut.f0s(dataOut.f0s>0));
    else
        dataOut.f0s=[];
        dataOut.medianF0=NaN;
    end

	%SC-Mod(2008/04/06): Look at the rms during the transition, instead of
	%   during the entire vocal part.
	if (isnan(t1) || isnan(t2) || isempty(t1) || isempty(t2) || t1>=t2)
		rmsTrans=0;
		rmsBGNoise=0;
        if ~isempty(data.signalIn)
            rmsBGNoise=calcAWeightedRMS(data.signalIn(1:round(0.2*data.params.sr)),data.params.sr);
        end
	else
% 		rmsTrans=sqrt(mean(data.signalIn(t1:t2).^2));
% 		rmsBGNoise=sqrt(mean(data.signalIn(1:round(0.2*data.params.sr)).^2));
		rmsTrans=calcAWeightedRMS(data.signalIn(t1:t2),data.params.sr);
		rmsBGNoise=calcAWeightedRMS(data.signalIn(1:round(0.2*data.params.sr)),data.params.sr);
	end

	rmsval   = round(100/dBrange*max(0,min(dBrange,dBrange/2+10*log10(rmsTrans/rmsTransTarg))));   %SC-Mod(2007/12/29)
	speedval = round(100/lenRange*max(0,min(lenRange,lenRange/2+(vocaLen-vocaLenNow)/2)));   
    
    fprintf('vocaLen = %d; vocaLenNow = %d; speedval = %d\n', vocaLen, vocaLenNow, speedval);
end
%--------------------------------------------------------------------------
%SC Set the volume/speed indicator
% if (handles.vumeterMode==1)
%     vumeter=handles.skin.vumeter;
% elseif (handles.vumeterMode==2);
%     vumeter=handles.skin.vumeter2;
% end
% vumeter0=vumeter*0.5;
% vubounds=handles.skin.vubounds; %SC(12/11/2007)


% mask=zeros(size(vumeter));
% mask0=zeros(size(vumeter));

rmsval1 = floor(rmsval / 10) * 10;
if (rmsval1 + 10 > 100)
	rmsval1 = 100 - 10;
end
if (rmsval1 < 0)
	rmsval1 = 0;
end
% if (handles.trialType == 3 || handles.trialType == 4 || handles.trialType == 5)
% 	rmsval1 = 40 + rand * 10;
% 	if (rmsval1 > 45) 
%         rmsval1 = 50;
% 	else rmsval1 = 40;
% 	end
% end

% if (handles.vumeterMode==1)
%     mask(:,rmsval1+1:rmsval1+10,:) = 1;   %SC-Commented(12/11/2007)
%     mask0=1-mask;
% elseif (handles.vumeterMode==2)
%     if (rmsval1<30)
%         mask(:,1:30,:) = 1;
%     elseif (rmsval1>=30 && rmsval1<70)
%         mask(:,31:70,:) = 1;
%     else
%         mask(:,70:100,:) = 1;                
%     end
%     mask0=1-mask;    
% end

% set(handles.rms_imgh,'Cdata',vumeter.*mask+vumeter0.*mask0);

% mask=zeros(size(vumeter));
% mask0=zeros(size(vumeter));

speedval1 = floor(speedval / 10) * 10;
if (speedval1 + 10 > 100)
	speedval1 = 100 - 10;
end
if (speedval1 < 0)
	speedval1 = 0;
end
% if (handles.trialType==3 | handles.trialType==4 | handles.trialType==5)
% 	speedval1=40+rand*10;
% 	if (speedval1>45) speedval1=50;
% 	else speedval1=40;
% 	end	
% end
% if isempty(fsic({'HEAD','SAID','SET','BET','BECK','BED','DECK','TECH','TED','MET','PEP','PET'},upper(handles.word)))
%     speedval1=50;
% end

% if (handles.vumeterMode==1)
%     mask(:,speedval1+1:speedval1+10,:) = 1;         %SC(2008/01/05)
%     mask0=1-mask;
% elseif (handles.vumeterMode==2)
%     if (speedval1<30)
%         mask(:,1:30,:) = 1;
%     elseif (speedval1>=30 && speedval1<70)
%         mask(:,31:70,:) = 1;
%     else
%         mask(:,70:100,:) = 1;          
%     end
%     mask0=1-mask;
% end

% if (handles.trialType==1 | handles.trialType==2)
% set(handles.speed_imgh,'Cdata',vumeter.*mask+vumeter0.*mask0);
    
% end
%SC ~Set the volume/speed indicator
%--------------------------------------------------------------------------
drawnow

msg1='';    msg2='';
instr1='';  instr2='';
if (rmsval < 70 && rmsval > 30)
	rmsRes = 0;
else
	if (rmsval >= 70)   %SC(2008/01/05)
        rmsRes = 1;
		msg1='Softer';
		instr2='Loud';
        if rmsval > 90
            rmsRes = 2;
        end
	else % Then rmsval <= 30
        rmsRes = -1;
		msg1='Louder';
		instr2='Soft';
        if rmsval < 10
            rmsRes = -2;
        end
	end
end

if (speedval < 70 && speedval > 30) %SC-Mod(2008/01/05) Used to be speedval > 20
	speedRes = 0;
else
% 	bSpeedGood=0;
	if (speedval >= 70) %SC (2008/01/05): too fast, or to short
        speedRes = 1;
		msg2='Slower';
		instr1='Fast';
        if speedval > 90
            speedRes = 2;
        end
    else % too slow, or two long
        speedRes = -1;
		msg2='Faster';
		instr1='Slow';
        if speedval < 10
            speedRes = -2;
        end
	end
end

if isequal(handles.trialType, 3) || isequal(handles.trialType, 4) || isequal(handles.trialType, 5)
	bRmsGood=1;
	bSpeedGood=1;
end
if isempty(fsic({'HEAD','SAID','SET','BET','BECK','BED','DECK','TECH','TED','MET','PEP','PET'},upper(handles.word)))
    bSpeedGood=1;
end

%SC(2008/01/05)
% if (~bRmsGood || ~bSpeedGood)
% 	if (~bRmsGood && ~bSpeedGood)
% %         msgc=['Please speak ',msg1,' and ',msg2,'.'];
% 		msgc=[msg1,' and ',lower(msg2),' please!'];
% 	elseif (~bRmsGood)
% %         msgc=['Please speak ',msg1,'.'];
% 		msgc=[msg1,' please!'];        
% 	elseif (~bSpeedGood)
% 		msgc=['Please speak ',msg2,'.'];
% 		msgc=[msg2,' please!'];
% 	end
% 
% 	if (handles.showTextCue)
% 		set(handles.msgh,'string',{'';msgc});
% % 		pause(1);
% 	end
% end

dataOut.params.dScale=handles.dScale;
%         load calibMic;  % gets micGain: wav rms/ Pa rms (Pa^-1)
load('micRMS_100dBA.mat');
dataOut.vowelLevel = 100+20*log10((rmsTrans/micRMS_100dBA));


%         load calibOutput;   
% gives 'freq' and 'voltGains', measured at 'shanqing' M-audio configuration 
% and -1.65 Phone volume knob.
%         mvg=mean(voltGains) * sqrt(2);    % mean voltage gain (V_rms / wavAmp_rms)



% --- SCai: update the data monitor window ---
updateDataMonitor(dataOut, handles);
% --- ~SCai: update the data monitor window ---
% --------------------------------------------------------------------------

handles.time2=clock;
if (handles.trigByScanner==1)
	timeToPause=handles.ITI-etime(handles.time2,handles.time1)-0.1; % 0.1 is the safety margin
	if (timeToPause>0)
		pause(timeToPause);
    end
else
    pause(0.25);
end

set(handles.msgh, 'string', '');
% if (handles.vumeterMode==1)
%     vumeter=handles.skin.vumeter;
% elseif (handles.vumeterMode==2)
%     vumeter=handles.skin.vumeter2;
% end
% mask=0.5*ones(size(vumeter));
% set(handles.rms_imgh,'Cdata',vumeter.*mask);
% set(handles.speed_imgh,'Cdata',vumeter.*mask);

%% --------------------------------------------------------------------------
function startRec(obj,event,handles)
% startRec displays a string and starts a timer object (handles.rect_timer)
% who's TimerFcn Callback (@stopRec) is called after a timeout period, set by
% the Value of the slider (handles.rec_slider)
% the StartFcn / StopFcn of the timer object starts/stops the recording
% (@soundDevice('start')/('stop')
% CDataPhrase=imread('utterimg/phrase.bmp');

fprintf('startRec\n')

handles.dataOut=[];
str=get(handles.strh,'string');
set(handles.rms_imgh,'Cdata',zeros(size(get(handles.rms_imgh,'Cdata'))));
set(handles.speed_imgh,'Cdata',zeros(size(get(handles.speed_imgh,'Cdata'))));

% set(handles.phrase_axes,'CData',CDataPhrase,'visible','on');

% clockStart=clock;
% clockStart(6) = clockStart(6) + get(handles.rec_slider,'Value');
% startat(handles.rec_timer, clockStart);
set(handles.strh,'string',str);

%% --------------------------------------------------------------------------
function stopRec(obj,event,handles)
% this function stops the recording if the timer object (handles.rec_timer)
% is still running. After the recording is stoped, checkData is executed,
% and the next and previous buttons are activated
fprintf('stopRec\n')
% if(strcmp(get(handles.rec_timer,'Running'),'on'))
%     stop(handles.rec_timer)
% end

handles.dataOut = checkData(getData, handles);


guidata(handles.UIRecorder, handles);

% set(handles.next,'enable','on')
% set(handles.prev,'enable','on')
% set(handles.next,'visible','on')
% set(handles.prev,'visible','on')
% if(get(handles.auto_btn,'Value')==get(handles.auto_btn,'Max'))
%     next_Callback(handles.uirecorder,[],handles)
% end

%% --------------------------------------------------------------------------
function soundDevice(obj,event,handles,action)
% interface to teh external sounddevice
switch(action)
    case 'init'
        Audapter(0)
    case 'start'
        Audapter(1)
    case 'stop'
        Audapter(2)
    otherwise,
end

%% --------------------------------------------------------------------------
function dataOut= getData
% gets the data
dataOut=AudapterIO('getData');

%% --- Executes on button press in auto_btn.
% function auto_btn_Callback(hObject, eventdata, handles)
% hObject    handle to auto_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto_btn

%%
function record(handles)
% tWords={'BECK','BET','DECK','DEBT','PECK','PEP','PET','TECH'};

if (handles.trigByScanner==1)
    set(handles.play,'userdata',1);
    uiwait(handles.UIRecorder);
else
    waitfor(handles.play,'userdata',1);
end

if isequal(get(handles.msgTxt, 'visible'), 'on')
    set(handles.msgTxt, 'visible', 'off');
end

if (handles.debug==0)
    
    go=get(handles.UIRecorder,'UserData');
    if isequal(go,'nogo')
        return
    end

    handles.dataOut=[];
    guidata(handles.UIRecorder,handles);

    set(handles.strh,'visible','off');
    set(handles.msgh,'visible','off');

    handles.time1=clock;

    if (handles.trigByScanner==1)
        if (~isequal(handles.phase,'pract1') && ~isequal(handles.phase,'pract2'))
            pause(handles.TA);
        else
            pause(0.25);
        end
    else
        pause(0.25);
    end

    if (isequal(handles.word,'Ready...') || isequal(handles.trialType, -1))
        return
    end

    if isequal(handles.trialType, 1) || length(handles.trialType) > 1
        if handles.fb3Gain == 0;
            Audapter(3, 'fb', 1);
        else
            Audapter(3, 'fb', 3);
            Audapter(3, 'fb3gain', handles.fb3Gain);
        end
    elseif isequal(handles.trialType, 2)
        Audapter(3, 'fb', 4);
        Audapter(3, 'rmsff_fb', ...
                 [handles.smnFF0, handles.smnFF1, handles.smnOnRamp, handles.smnOffRamp], 0);
        Audapter(3, 'fb4gaindb', handles.smnGain, 0);
    elseif isequal(handles.trialType, 3)
        Audapter(3, 'fb', 2);
    elseif isequal(handles.trialType, 4)
        Audapter(3,'fb',1);
    elseif isequala(handles.trialType, 5)
        Audapter(3,'fb',1);
    else
        error('Unrecognized trialType: %d', handles.trialType);
    end
    
	load(handles.uiConfigFN);   % gives uiConfig
    
    if isequal(handles.trialType, 1) || isequal(handles.trialType, 2) || length(handles.trialType) > 1
        for i1 = 1 : numel(handles.hsp)            
            set(0, 'CurrentFigure', handles.hkf);
            
            set(gcf, 'CurrentAxes', handles.hsp_vol);
            cla;
%             set(gcf, 'CurrentAxes', handles.hsp_dur);
%             cla;
            
            set(gcf, 'CurrentAxes', handles.hsp(i1));
            cla;
%             t_hsp = subplot('Position', [handles.leftMargin + (i1 - 1) * (handles.panelWidth + handles.panelSpacing), 0.375, handles.panelWidth, handles.panelHeight]);
            
            if i1 == 1
                im_trg = handles.skin.bed;
                t_word = 'bed';
            elseif i1 == 2
                if uiConfig.bShowCorrAnim == 1
                    im_trg = handles.skin.head;
                else
                    im_trg = handles.skin.head0;
                end
                t_word = 'head';
            elseif i1 == 3
                im_trg = handles.skin.Ted;
                t_word = 'Ted';
            end
            
            if handles.showKidsAnim
                imh = image(im_trg);
            end
            
            axis square;
            box off;
            set(gca, 'XTick', [], 'YTick', []);
            set(gca, 'XColor', 'w', 'YColor', 'w');
            hold on;
            
                        
        end
        
        if handles.showKidsAnim
            a_words = {'bed', 'head', 'ted'};
            idx = fsic(a_words, lower(handles.word));
            set(gcf, 'CurrentAxes', handles.hsp(idx));
            
            xPrg = 0;
            if isequal(lower(handles.word), 'bed')
                yPrg = -120;
            else
                yPrg = -80;
            end
        else
            set(gcf, 'CurrentAxes', handles.hsp(ceil(length(handles.hsp) / 2)));
        end
%         cla;
          
        load(handles.uiConfigFN);
        handles.showWordHint = uiConfig.showWordHint;
        if handles.showWordHint || ~handles.showKidsAnim
            xs = get(gca, 'XLim');
            ys = get(gca, 'YLim');
            
            if handles.trigByScanner && length(handles.phase) >= 4 && isequal(handles.phase(1 : 4), 'rand')
                htxt = text(xs(1) + 0.3 * range(xs), ys(1) + 0.3 * range(ys), handles.word, ...
                            'FontName', 'Courier New', 'FontSize', 36, 'FontWeight', 'bold', 'Color', 'b');
            else
                htxt = text(xs(1) + 0.3 * range(xs), ys(1) + 0.92 * range(ys), handles.word, ...
                            'FontName', 'Courier New', 'FontSize', 36, 'FontWeight', 'bold', 'Color', 'b');
            end
        end

        if uiConfig.trialStartWithAnim == 1 || ~handles.showKidsAnim
            if isequal(handles.phase, 'rand')   % DEBUG
                f = fopen(fullfile(handles.dirname, 'tmp.log'), 'at');                
                fprintf(f, 'Starting trial: setting trialLen... %s\n', handles.trialType);
                fclose(f);
            end
            
            if uiConfig.trialPresetDur == 1
                Audapter(3, 'triallen', handles.trialLen);
            else
                Audapter(3, 'triallen', handles.trialLenMax);
            end
            
            if isequal(handles.phase, 'rand')   % DEBUG
                f = fopen(fullfile(handles.dirname, 'tmp.log'), 'at');
                fprintf(f, 'Starting trial: setting trialLen done. %s\n', handles.trialType);
                fprintf(f, 'Starting trial: reseting... %s\n', handles.trialType);
                
                fclose(f);
            end
            
            AudapterIO('reset');
            if isequal(handles.phase, 'rand')   % DEBUG
                f = fopen(fullfile(handles.dirname, 'tmp.log'), 'at');
                fprintf(f, 'Starting trial: reset done. %s\n', handles.trialType);
                
                fclose(f);
            end
           
%             fprintf(1, 'handles.debug_pitchShiftLogF = %d\n', ...
%                     handles.debug_pitchShiftLogF);
%             if handles.debug_pitchShiftLogF > 0
%                 fprintf(handles.debug_pitchShiftLogF, 'Starting trial\n');
%             end
            
            if ~handles.bAlwaysOn
                Audapter(1);
            end
        end
        
        if handles.showKidsAnim
            tic; 
            frmCnt = 1;
            totFrames = 12;
            for i0 = 1 : totFrames
                imh = image(handles.skin.birdFrames{frmCnt}, 'XData', [10, 140] + xPrg, 'YData', [60, 160] + yPrg);
                xPrg = xPrg + 8;
                yPrg = yPrg + 2;
                hold on;
                axis square;
                box off;
                alphaImg = 0. * ones(size(handles.skin.birdFrames{frmCnt}(:, :, 1)));
                alphaImg(handles.skin.birdFrames{frmCnt}(:, :, 1) < 0.9) = 1.;
                set(imh, 'AlphaData', alphaImg);
            %     set(imh, 'AlphaData', 0.75);
                set(gca, 'XTick', [], 'XColor', 'w');
                set(gca, 'YTick', [], 'YColor', 'w');
                drawnow;

                frmCnt = frmCnt + 1;
                if (frmCnt > numel(handles.skin.birdFrames))
                    frmCnt = 1;
                end

                pause(0.05);
                if ~(i0 == totFrames)
                    delete(imh);
                end
            %     end
            end
            animDur = toc;
        else
            animDur = 0.0;
        end
                
        if uiConfig.trialPresetDur == 1 || handles.showKidsAnim
            waitTime = handles.trialLen - animDur;
            if waitTime >= 0
                pause(waitTime);
                
                if ~handles.bAlwaysOn
                    Audapter(2);
                end
            end
        else
            if uiConfig.trialStartWithAnim == 1
                set(handles.button_endCurTrial, 'Enable', 'on');
                waitfor(handles.button_endCurTrial, 'Enable', 'off');
            end
        end
        if isequal(handles.phase, 'rand')   % DEBUG
            f = fopen(fullfile(handles.dirname, 'tmp.log'), 'at');
            fprintf(f, 'Ended trial: %s\n', handles.trialType);
            fclose(f);
        end
           
    end
    
    if handles.bSim == 1
        % Determine the sim data file name
        dir1 = dir(fullfile(handles.simDataDir, handles.phase, ...
                            ['rep', num2str(handles.repNum)], ...
                            ['trial-', num2str(handles.trialNum), '*.wav']));
        if length(dir1) ~= 1
            error('Not exactly one wav file was found.');
        end
        
        [wx, fs] = read_audio(fullfile(handles.simDataDir, handles.phase, ...
                              ['rep', num2str(handles.repNum)], ...
                              dir1(1).name));
        if fs ~= 48000  % Resample
            wx = resample(wx, 48000, fs);
        end
        
        AudapterIO('reset');
        wxInCell=makecell(wx, 64);
        for n = 1 : length(wxInCell)
%             tic;
            Audapter(5,wxInCell{n});
        end
        
    else        
%         tic;
        if uiConfig.trialStartWithAnim == 0
            if handles.bAlwaysOn == 1
                AudapterIO('reset');
%                 Audapter(3, 'scale', handles.dScale);
            else            
                AudapterIO('reset');
                if uiConfig.trialPresetDur == 1
                    Audapter(3, 'triallen', handles.trialLen);
                else
                    Audapter(3, 'triallen', handles.trialLenMax);
                end
                
                if ~bAlwaysOn
                    Audapter(1);
                end
                
                if uiConfig.trialPresetDur == 1
                    pause(handles.trialLen);  % Changed 2008/06/18 to make the pause longer +1.5 --> +2.0
                else            
                    set(handles.button_endCurTrial, 'Enable', 'on');            
                end
            end
        end
%         startupTime=toc;
%         fprintf('Start-up time = %.3f sec\n',startupTime);
        
    end

    
    if get(handles.play,'userdata')==0 % in pause mode
        record(handles); % re-do recording
    end
    
    if handles.showKidsAnim
        delete(imh);
    else
        delete(htxt);
    end

    if uiConfig.trialStartWithAnim == 0
        if uiConfig.trialPresetDur == 1
            if handles.bSim == 0
                if handles.bAlwaysOn == 1
%                     Audapter(3, 'scale', 0);
                else
                    if ~bAlwaysOn
                        Audapter(2);
                    end
                end
            end
        else
            waitfor(handles.button_endCurTrial, 'Enable', 'off');
        end
    end

    [dataOut, rmsRes, durRes] = checkData(getData, handles);
    tmp_data_fn = fullfile(handles.dirname, 'tmp_dataOut.mat');
    save(tmp_data_fn, 'dataOut');
    % TODO: Revise checkData
    
                        
    if handles.showKidsAnim
        % -- Experimenter response re. correctness of the subject's production --    
        button_correct = uicontrol('Parent', handles.UIRecorder, 'Style', 'pushbutton', ...
                                'Unit', 'normalized', ...
                                'Position', [0.25, 0.17, 0.24, 0.05], ...
                                'String', 'Word correct', 'FontSize', 9, 'ForegroundColor', [0, 0.5, 0]);
        button_incorrect = uicontrol('Parent', handles.UIRecorder, 'Style', 'pushbutton', ...
                                'Unit', 'normalized', ...
                                'Position', [0.50, 0.17, 0.24, 0.05], ...
                                'String', 'Word incorrect', 'FontSize', 9, 'ForegroundColor', [1, 0, 0]);
        button_forcerep = uicontrol('Parent', handles.UIRecorder, 'Style', 'pushbutton', ...
                                'Unit', 'normalized', ...
                                'Position', [0.75, 0.17, 0.24, 0.05], ...
                                'String', 'Force repeat', 'FontSize', 9, 'ForegroundColor', [1, 0, 1]);

        handles.button_correct = button_correct;
        handles.button_incorrect = button_incorrect;
        handles.button_forcerep = button_forcerep;
        set(button_correct, 'Callback', {@button_correct_callback, handles});
        set(button_incorrect, 'Callback', {@button_incorrect_callback, handles});
        set(button_forcerep, 'Callback', {@button_forcerep_callback, handles});

        set(handles.button_reproc, 'enable', 'on');
        %     set(handles.button_reproc, 'Callback', {@button_reproc_Callback});
        waitfor(button_correct);
    end
    
    clear('dataOut');
    load(tmp_data_fn);
    [dataOut, rmsRes, durRes] = checkData(dataOut, handles);
    
    if handles.showKidsAnim
        load(fullfile(handles.dirname, 'resp_correct.mat')); % gives resp_correct
        dataOut.resp_correct = resp_correct;
        load(fullfile(handles.dirname, 'corr_count.mat'));   % gives corr_count
        if isequal(handles.phase, 'pre')
            corr_count = corr_count + max([resp_correct, 0]);
        elseif isequal(handles.phase, 'pract1')
            if rmsRes == 0
                corr_count = corr_count + max([resp_correct, 0]);
            end
        else
            if rmsRes == 0 && durRes == 0
                corr_count = corr_count + max([resp_correct, 0]);
            end
        end
        save(fullfile(handles.dirname, 'corr_count.mat'), 'corr_count');
        handles.corrCnt = corr_count;
        guidata(handles.UIRecorder, handles);
    
        respCorrAnim(resp_correct, handles);
        
    else
        dataOut.resp_correct = NaN;
    end
    
    % DEBUG
%     rmsRes = -1;     % 0 - good; -1 - too soft; +1 - too loud
%     durRes = 1;   % 0 - good; -1 - too shoft; +1 - too long

    bRmsGood = (rmsRes == 0);
    bSpeedGood = (durRes == 0);
    
    % Show intensity animation
    if handles.showRmsPrompt == 1
        if ~isempty(strfind(uiConfig.promptMode, 'v')) % Visual prompt
            if rmsRes == 0
                if uiConfig.showInfoOnlyErr == 0
                    volDurOK_anim(handles, 'vol');
                end
            elseif rmsRes >= 1
                volErr_anim(handles, 'loud');
            else
                volErr_anim(handles, 'soft');
            end
        end
        if ~isempty(strfind(uiConfig.promptMode, 'a')) % Auditory prompt
            if rmsRes ~= 0
                if rmsRes == 2
                    msg = 'softer';
                elseif rmsRes == 1
                    msg = 'a little softer';
                elseif rmsRes == -2
                    msg = 'louder';
                else
                    msg = 'a little louder';
                end
                play_prompt(msg, 'audio', 10 ^ (uiConfig.promptVol / 20));
            end
        end
    end
    
    if handles.showSpeedPrompt == 1
        if ~isempty(strfind(uiConfig.promptMode, 'v')) % Visual prompt
            if durRes == 0
                if uiConfig.showInfoOnlyErr == 0
                    volDurOK_anim(handles, 'dur');
                end
            elseif durRes >= 1
                durErr_anim(handles, 'short');
            else
                durErr_anim(handles, 'long');
            end
        end
        if ~isempty(strfind(uiConfig.promptMode, 'a')) % Auditory prompt
            if durRes ~= 0
                if durRes == 2
                    msg = 'longer';
                elseif durRes == 1
                    msg = 'a little longer';
                elseif durRes == -2
                    msg = 'shorter';
                else
                    msg = 'a little shorter';
                end
                play_prompt(msg, 'audio', 10 ^ (uiConfig.promptVol / 20));
            end
        end
    end
    
    if handles.showKidsAnim
        if resp_correct == 1
            if isequal(handles.phase, 'pre')
                if uiConfig.bShowCorrAnim
                    show_corr_anim(handles);
                end
            elseif isequal(handles.phase, 'pract1')
                if rmsRes == 0
                    if uiConfig.bShowCorrAnim
                        show_corr_anim(handles);
                    end
                end
            else
                if rmsRes == 0 && durRes == 0
                    if uiConfig.bShowCorrAnim
                        show_corr_anim(handles);
                    end
                end
            end        
        end
    end

    bRmsRepeat = handles.bRmsRepeat;
    bSpeedRepeat = handles.bSpeedRepeat;
    if isequal(handles.trialType, 3) || isequal(handles.trialType, 4)
        if (bRmsRepeat==1)
            bRmsRepeat=0;
        end
        if (bSpeedRepeat==1)
            bSpeedRepeat=0;
        end
    end

    if ((~bRmsGood && bRmsRepeat) || (~bSpeedGood && bSpeedRepeat))
        % Repeat until the volume and/or speed criteria are met.
        if handles.showKidsAnim
            button_repeat = uicontrol('Parent', handles.UIRecorder, 'Style', 'pushbutton', ...
                                'Unit', 'normalized', ...
                                'Position', [0.25, 0.1, 0.24, 0.05], ...
                                'String', 'Repeat', 'FontSize', 9, 'FontWeight', 'Bold', ...
                                'ForegroundColor', [0, 0, 0]);
            handles.button_repeat = button_repeat;
            set(button_repeat, 'Callback', {@button_repeat_callback, handles});

            set(button_repeat, 'enable', 'on');
        
            waitfor(button_repeat);
        end
        
        record(handles);
    elseif handles.showKidsAnim && resp_correct == -1
        record(handles);
    else
        % data is saved as UserData in the fig handle (wicht is the signal for
        % the host function to launch the next single trial
        dataOut.uiConfig = uiConfig;
        set(handles.UIRecorder, 'UserData', dataOut);
    end
% end
%     if (handles.trigByScanner==0)
%         pause(0.25);
%     end
    set(handles.strh,'visible','off');
% set(handles.pic_imgh,'cdata',handles.skin.fixation);
% set(handles.pic_imgh,'visible','off');
else
    dataOut=struct;
    dataOut.signalIn=[]; dataOut.signalOut=[];
    dataOut.rms=[];
    set(handles.UIRecorder,'UserData',dataOut);
end
return

%%
function volDurOK_anim(handles, opt)
set(0, 'CurrentFigure', handles.hkf);

if isequal(opt, 'vol')
    im1 = handles.skin.speaker_base;
    set(gcf, 'CurrentAxes', handles.hsp_vol);
elseif isequal(opt, 'dur')
    im1 = handles.skin.pencil_ruler;
%     set(gcf, 'CurrentAxes', handles.hsp_dur);
    subplot('Position', [0.6, 0.05, 0.15, 0.25]);
end
cla;

imh1 = image(im1);
hold on;
axis square;
box off;
set(gca, 'XTick', [], 'XColor', 'w');
set(gca, 'YTick', [], 'YColor', 'w');

im_tick_0 = handles.skin.tick;

totFrames = 10;
for i1 = 1 : totFrames
    t_ratio = i1 / totFrames;
    im_tick = im_tick_0;
    im_tick = im_tick(:, 1 : round(t_ratio * size(im_tick_0, 2)), :);
    
    alphaImg = 0. * ones(size(im_tick(:, :, 1)));
    alphaImg(im_tick(:, :, 3) < 0.9) = 1.;

    if isequal(opt, 'vol')
        imh_tick = image(im_tick, 'XData', [0, 200 * t_ratio], 'YData', [0, 200]);
    elseif isequal(opt, 'dur')
        imh_tick = image(im_tick, 'XData', [0, 440 * t_ratio], 'YData', [0, 200]);
    end
    set(imh_tick, 'AlphaData', alphaImg);
    
    pause(0.02);
    
    if ~(i1 == totFrames)
        delete(imh_tick);
    end
end

% pause(1);
cla;
drawnow;
return

function volErr_anim(handles, opt)
set(0, 'CurrentFigure', handles.hkf);
im_lsp = handles.skin.speaker_base;
if isequal(opt, 'loud')
    im_lsp_alt = handles.skin.speaker_loud_1;
else
    im_lsp_alt = handles.skin.speaker_soft_1;
end

set(gcf, 'CurrentAxes', handles.hsp_vol);
basePos = get(gca, 'Position');
if isequal(opt, 'loud')    
    set(gca, 'Position', [0.3, 0.05, 0.15 * 1.25, 0.25 * 1.25]); % base value: [0.3, 0.05, 0.15, 0.25]
    warning_msg = 'Softer, please!';
elseif isequal(opt, 'soft')    
    set(gca, 'Position', [0.3, 0.05, 0.15 * 0.75, 0.25 * 0.75]);
    warning_msg = 'Louder, please!';
end
cla;
% set(gca, 'XTick', [], 'XColor', 'w');
% set(gca, 'YTick', [], 'YColor', 'w');

% im_tick_0 = double(imread('images/cartoon-tickmark-1.jpg')) / 255.;
load(handles.uiConfigFN);    % gives uiConfig
handles.showWarningHint = uiConfig.showWarningHint;

totFrames = 10;
for i1 = 1 : totFrames
%     t_ratio = i1 / totFrames;
%     im_tick = im_tick_0;
%     im_tick = im_tick(:, 1 : round(t_ratio * size(im_tick_0, 2)), :);
    
%     alphaImg = 0. * ones(size(im_tick(:, :, 1)));
%     alphaImg(im_tick(:, :, 3) < 0.9) = 1.;

    if mod(i1, 2) == 1
        imh_lsp = image(im_lsp);
    else
        imh_lsp = image(im_lsp_alt);
    end
    hold on;
    axis square;
    box off;
    set(gca, 'XTick', [], 'XColor', 'w');
    set(gca, 'YTick', [], 'YColor', 'w');

    if handles.showWarningHint
        xs = get(gca, 'XLim');
        ys = get(gca, 'YLim');
        htxt = text(xs(1) + 0.3 * range(xs), ys(1) + 0.92 * range(ys), ...
                    warning_msg, ...
                    'FontSize', 18, 'FontWeight', 'bold', 'Color', 'k');
    end
    
    drawnow;
    pause(0.15);
    if ~(i1 == totFrames)
        delete(imh_lsp);
        if handles.showWarningHint
            delete(htxt);
        end
    end
    
    

end
set(gca, 'Position', basePos);



% pause(1); 
% delete(hsp_vol);
return


%%
function durErr_anim(handles, opt)
set(0, 'CurrentFigure', handles.hkf);
if isequal(opt, 'short')
    im_pencil_0 = handles.skin.pencil_short_1;
    warning_msg = 'Longer, please!';
elseif isequal(opt, 'long')
    im_pencil_0 = handles.skin.pencil_long_1;
    warning_msg = 'Shorter, please!';
end

im_ruler = handles.skin.ruler;

% hsp_vol = subplot('Position', [0.7, 0.05, 0.15, 0.3]);

% imh_lsp = image(im_pencil);
hold on;
% axis square;    
% box off;
% set(gca, 'XTick', [], 'XColor', 'w');
% set(gca, 'YTick', [], 'YColor', 'w');

% set(gcf, 'CurrentAxes', handles.hsp_dur);
% cla;
basePos = get(gca, 'Position');         % [0.3, 0.05, 0.15, 0.25]

% hsp_vol = subplot('Position', [basePos(1), 0.10, basePos(3), basePos(4) * 0.4]);
basePos = [0.6, 0.05, 0.15, 0.25];
hsp_vol = subplot('Position', [basePos(1), 0.10, basePos(3), basePos(4) * 0.4]);
% set(gcf, 'CurrentAxes', handles.hsp_dur);
cla;
imh_lsp = image(im_ruler);
hold on;
% axis square;    
box off;
set(gca, 'XTick', [], 'XColor', 'w');
set(gca, 'YTick', [], 'YColor', 'w');

% hsp_vol = subplot('Position', [0.7, 0.15, 0.15, 0.15]);
% imh_lsp = image(im_pencil);
hold on;
% axis square;    
box off;
set(gca, 'XTick', [], 'XColor', 'w');
set(gca, 'YTick', [], 'YColor', 'w');

% im_tick_0 = double(imread('images/cartoon-tickmark-1.jpg')) / 255.;
load(handles.uiConfigFN);    % gives uiConfig
handles.showWarningHint = uiConfig.showWarningHint;

totFrames = 10;

if isequal(opt, 'short')
    hsp_pen = subplot('Position', [basePos(1), 0.20, basePos(3) * 0.5, basePos(4) * 0.6]);
elseif isequal(opt, 'long')
    hsp_pen = subplot('Position', [basePos(1), 0.20, basePos(3) * 2, basePos(4) * 0.6]);
end
im_pencil_bg = ones(size(im_pencil_0));
image(im_pencil_bg);
hold on;

for i1 = 1 : totFrames
    t_ratio = i1 / totFrames;
    im_pencil = im_pencil_0;
    im_pencil = im_pencil(:, 1 : round(t_ratio * size(im_pencil_0, 2)), :);
    
    alphaImg = 0. * ones(size(im_pencil(:, :, 1)));
    alphaImg(im_pencil(:, :, 3) < 0.9) = 1.;

    if isequal(opt, 'long')
        imh_pencil = image(im_pencil, 'XData', [0, 550 * t_ratio], 'YData', [0, 100]);
    elseif isequal(opt, 'short')
        imh_pencil = image(im_pencil, 'XData', [0, 180 * t_ratio], 'YData', [0, 100]);
    end
    set(imh_pencil, 'AlphaData', alphaImg);
    box off;
    set(gca, 'XTick', [], 'XColor', 'w');
    set(gca, 'YTick', [], 'YColor', 'w');
    
    if handles.showWarningHint
        xs = get(gca, 'XLim');
        ys = get(gca, 'YLim');
        htxt = text(xs(1) + 0.3 * range(xs), ys(1) + 0.92 * range(ys), ...
                    warning_msg, ...
                    'FontSize', 18, 'FontWeight', 'bold', 'Color', 'k');
    end
    
    drawnow;
    pause(0.02);
    
    if ~(i1 == totFrames)
        delete(imh_pencil);
        if handles.showWarningHint
            delete(htxt);
        end
    end
end

pause(1);
subplot('Position', basePos);
cla;
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XColor', 'w', 'YColor', 'w');

% delete(imh_pencil);
% delete(imh_lsp);
return

% --- Executes on button press in button_next.
% function button_next_Callback(hObject, eventdata, handles)
% % hObject    handle to button_next (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if (isfield(handles,'nextMessage'))
%     set(handles.msgh_imgh,'CData',handles.nextMessage,'visible','on');
% end
% set(handles.button_next,'visible','off');
% 
% set(handles.play,'visible','on');

function dFaces=getDFaces(fileMask)
    dFaces=struct;
    dFaces.d=dir(fileMask);
    dFaces.sex=cell(1,length(dFaces.d));
    dFaces.subjID=nan(1,length(dFaces.d));
    
    for n=1:length(dFaces.d)
        fn=dFaces.d(n).name;
        idx=strfind(fn,'.bmp');
        dFaces.sex{n}=dFaces.d(n).name(idx-1);
        idx1=strfind(fn,'-s');
        idx2=strfind(fn,['-',dFaces.sex{n}]);
        dFaces.subjID(n)=str2num(dFaces.d(n).name(idx1+2:idx2-1));
    end
return

function button_correct_callback(hObject, eventdata, handles)
resp_correct = 1;
save(fullfile(handles.dirname, 'resp_correct.mat'), 'resp_correct');
delete(handles.button_correct);
delete(handles.button_incorrect);
delete(handles.button_forcerep);
return

function button_incorrect_callback(hObject, eventdata, handles)
resp_correct = 0;
save(fullfile(handles.dirname, 'resp_correct.mat'), 'resp_correct');
delete(handles.button_correct);
delete(handles.button_incorrect);
delete(handles.button_forcerep);
return

function button_forcerep_callback(hObject, eventdata, handles)
resp_correct = -1;
save(fullfile(handles.dirname, 'resp_correct.mat'), 'resp_correct');
delete(handles.button_correct);
delete(handles.button_incorrect);
delete(handles.button_forcerep);
return

function button_repeat_callback(hObject, eventdata, handles)
delete(handles.button_repeat);
return

function respCorrAnim(resp_correct, handles)
set(0, 'CurrentFigure', handles.hkf);
set(gcf, 'CurrentAxes', handles.hsp_resp);
cla;
if resp_correct == 1
    for i1 = 1 : 3
        htxt = text(0, 0, 'Correct', 'FontSize', 24, 'Color', [0, 0.5, 0]);
        pause(0.2);
        delete(htxt);
        pause(0.2);
    end
elseif resp_correct == 0
    for i1 = 1 : 3
        htxt = text(0, 0, 'Incorrect', 'FontSize', 24, 'Color', [1, 0, 0]);
        pause(0.2);
        delete(htxt);
        pause(0.2);
    end
end

load(handles.uiConfigFN);   % gives uiConfig
handles.showCorrCount = uiConfig.showCorrCount;
if handles.showKidsAnim
    if handles.showCorrCount
        oldTxt = get(handles.htxt_corrCnt, 'String');
        if handles.corrCnt <= 1
            newTxt = sprintf('You have made %d correct response!', handles.corrCnt);
        else
            newTxt = sprintf('You have made %d correct responses!', handles.corrCnt);
        end
        set(handles.htxt_corrCnt, 'String', newTxt);
    else
        set(handles.htxt_corrCnt, 'String', '');
    end
end

return



function edit_param_rmsThresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_rmsThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_rmsThresh as text
%        str2double(get(hObject,'String')) returns contents of edit_param_rmsThresh as a double

% --- Executes during object creation, after setting all properties.
function edit_param_rmsThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_rmsThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit_param_fn1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_fn1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_fn1 as text
%        str2double(get(hObject,'String')) returns contents of edit_param_fn1 as a double


% --- Executes during object creation, after setting all properties.
function edit_param_fn1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_fn1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_param_fn2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_fn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_fn2 as text
%        str2double(get(hObject,'String')) returns contents of edit_param_fn2 as a double


% --- Executes during object creation, after setting all properties.
function edit_param_fn2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_fn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_param_aFact_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_aFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_aFact as text
%        str2double(get(hObject,'String')) returns contents of edit_param_aFact as a double


% --- Executes during object creation, after setting all properties.
function edit_param_aFact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_aFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_param_bFact_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_bFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_bFact as text
%        str2double(get(hObject,'String')) returns contents of edit_param_bFact as a double


% --- Executes during object creation, after setting all properties.
function edit_param_bFact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_bFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_param_gFact_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_gFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_gFact as text
%        str2double(get(hObject,'String')) returns contents of edit_param_gFact as a double


% --- Executes during object creation, after setting all properties.
function edit_param_gFact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_gFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_showWordHint.
function rb_showWordHint_Callback(hObject, eventdata, handles)
% hObject    handle to rb_showWordHint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_showWordHint
val = get(handles.rb_showWordHint, 'Value');
load(handles.uiConfigFN);   % gives uiConfig
uiConfig.showWordHint = val;
save(handles.uiConfigFN, 'uiConfig');

% handles.showWordHint = val;
% guidata(hObject, handles);
% guidata(handles.uirecorder, handles);
return

% --- Executes on button press in rb_showWarningHint.
function rb_showWarningHint_Callback(hObject, eventdata, handles)
% hObject    handle to rb_showWarningHint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_showWarningHint
val = get(handles.rb_showWarningHint, 'Value');
load(handles.uiConfigFN);   % gives uiConfig
uiConfig.showWarningHint = val;
save(handles.uiConfigFN, 'uiConfig');
return

% --- Executes on button press in rb_showCorrCount.
function rb_showCorrCount_Callback(hObject, eventdata, handles)
% hObject    handle to rb_showCorrCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_showCorrCount
val = get(handles.rb_showCorrCount, 'Value');
load(handles.uiConfigFN);   % gives uiConfig
uiConfig.showCorrCount = val;
save(handles.uiConfigFN, 'uiConfig');
return

% --- Executes on button press in button_reproc.
function button_reproc_Callback(hObject, eventdata, handles)
% hObject    handle to button_reproc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
relTol = 1e-4;

tmp_data_fn = fullfile(handles.dirname, 'tmp_dataOut.mat');
load(tmp_data_fn, 'dataOut');   % gives dataOut

% Compare the parameters to see if there is any change
paramList = {'rmsThresh', 'nLPC', 'fn1', 'fn2', ...
             'aFact', 'bFact', 'gFact', ...
             'bCepsLift', 'cepsWinWidth'};
reprocCmd = 'dataOut = reprocData(dataOut, ';
chgList = {};
chgVals = [];
for i1 = 1 : numel(paramList)
    t_item = paramList{i1};
    old_val = dataOut.params.(t_item);
    fld_name = ['edit_param_', t_item];
    new_val = str2num(get(handles.(fld_name), 'String'));
    if isempty(new_val) ||  isnan(new_val)
        continue;
    end
    
    if abs((new_val - old_val) / old_val) > relTol
        chgList{end + 1} = t_item;
        chgVals{end + 1} = new_val;
        reprocCmd = [reprocCmd, '''', t_item, '''', ', ', num2str(new_val), ', '];
    end
    
end


if ~isempty(chgList)
    reprocCmd = [reprocCmd(1 : end - 2), ');'];
    eval(reprocCmd);
end
% dataOut.paramChgList = chgList;
% dataOut.paramChgVals = chgVals;
save(tmp_data_fn, 'dataOut');   % gives dataOut

updateDataMonitor(dataOut, handles);


return

function edit_param_nLPC_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_nLPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_nLPC as text
%        str2double(get(hObject,'String')) returns contents of edit_param_nLPC as a double


% --- Executes during object creation, after setting all properties.
function edit_param_nLPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_nLPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_param_bCepsLift_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_bCepsLift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_bCepsLift as text
%        str2double(get(hObject,'String')) returns contents of edit_param_bCepsLift as a double


% --- Executes during object creation, after setting all properties.
function edit_param_bCepsLift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_bCepsLift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_param_cepsWinWidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_cepsWinWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_cepsWinWidth as text
%        str2double(get(hObject,'String')) returns contents of edit_param_cepsWinWidth as a double


% --- Executes during object creation, after setting all properties.
function edit_param_cepsWinWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_cepsWinWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_showInfoOnlyErr.
function rb_showInfoOnlyErr_Callback(hObject, eventdata, handles)
% hObject    handle to rb_showInfoOnlyErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_showInfoOnlyErr
val = get(handles.rb_showInfoOnlyErr, 'Value');
load(handles.uiConfigFN);   % gives uiConfig
uiConfig.showInfoOnlyErr = val;
save(handles.uiConfigFN, 'uiConfig');

return


% --- Executes on button press in rb_showCorrAnim.
function rb_showCorrAnim_Callback(hObject, eventdata, handles)
% hObject    handle to rb_showCorrAnim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_showCorrAnim
val = get(handles.rb_showCorrAnim, 'Value');
load(handles.uiConfigFN);   % gives uiConfig
uiConfig.bShowCorrAnim = val;
save(handles.uiConfigFN, 'uiConfig');


return


% --- Executes on selection change in pm_timingMode.
function pm_timingMode_Callback(hObject, eventdata, handles)
% hObject    handle to pm_timingMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_timingMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_timingMode
val = get(handles.pm_timingMode, 'Value');
load(handles.uiConfigFN);   % gives uiConfig

listItems = get(handles.pm_timingMode, 'String');
t_item = listItems{val};

if ~isempty(strfind(t_item, 'with anim'))
    uiConfig.trialStartWithAnim = 1;
else
    uiConfig.trialStartWithAnim = 0;
end

if ~isempty(strfind(t_item, 'preset dur'))
    uiConfig.trialPresetDur = 1;
else
    uiConfig.trialPresetDur = 0;
end
save(handles.uiConfigFN, 'uiConfig');

return

% --- Executes during object creation, after setting all properties.
function pm_timingMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_timingMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_endCurTrial.
function button_endCurTrial_Callback(hObject, eventdata, handles)
% hObject    handle to button_endCurTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Audapter(2);
set(handles.button_endCurTrial, 'Enable', 'off');
return


% --- Executes on selection change in pm_promptMode.
function pm_promptMode_Callback(hObject, eventdata, handles)
% hObject    handle to pm_promptMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_promptMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_promptMode
val = get(handles.pm_promptMode, 'Value');
load(handles.uiConfigFN);   % gives uiConfig

listItems = get(handles.pm_promptMode, 'String');
t_item = listItems{val};

if isequal(lower(t_item), 'visual only')
    uiConfig.promptMode = 'v';
elseif isequal(lower(t_item), 'auditory only')
    uiConfig.promptMode = 'a';
elseif isequal(lower(t_item), 'auditory + visual')
    uiConfig.promptMode = 'av';
end

save(handles.uiConfigFN, 'uiConfig');
return

% --- Executes during object creation, after setting all properties.
function pm_promptMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_promptMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sld_promptVol_Callback(hObject, eventdata, handles)
% hObject    handle to sld_promptVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(handles.sld_promptVol, 'Value');
load(handles.uiConfigFN);   % gives uiConfig

uiConfig.promptVol = val;
set(handles.text_promptVol, 'String', sprintf('%.1f dB', val));

save(handles.uiConfigFN, 'uiConfig');
return


% --- Executes during object creation, after setting all properties.
function sld_promptVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_promptVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
