function varargout = AudapterIO(action,params,inFrame,varargin)
%
persistent p

toPrompt=0; % set to 1 when necessary during debugging

switch(action)
    case 'init',
        p=params;
        
        if isfield(p, 'downFact')
            Audapter(3, 'downfact', p.downFact, toPrompt);
        end
  
        Audapter(3,'srate',p.sr, toPrompt);
        Audapter(3,'framelen',p.frameLen, toPrompt);
        
        Audapter(3,'ndelay',p.nDelay, toPrompt);
        Audapter(3,'nwin',p.nWin, toPrompt);
        Audapter(3,'nlpc',p.nLPC, toPrompt);
        Audapter(3,'nfmts',p.nFmts, toPrompt);
        Audapter(3,'ntracks',p.nTracks, toPrompt);        
        Audapter(3,'scale',p.dScale, toPrompt);
        Audapter(3,'preemp',p.preempFact, toPrompt);
        Audapter(3,'rmsthr',p.rmsThresh, toPrompt);
        Audapter(3,'rmsratio',p.rmsRatioThresh, toPrompt);
        Audapter(3,'rmsff',p.rmsForgFact, toPrompt);
        Audapter(3,'dfmtsff',p.dFmtsForgFact, toPrompt);
        Audapter(3,'bgainadapt',p.gainAdapt, toPrompt);
        Audapter(3,'bshift',p.bShift, toPrompt);
        Audapter(3,'btrack',p.bTrack, toPrompt);
        Audapter(3,'bdetect',p.bDetect, toPrompt);      
        Audapter(3,'avglen',p.avgLen, toPrompt);        
        Audapter(3,'bweight',p.bWeight, toPrompt);    
        
        if (isfield(p,'minVowelLen'))
            Audapter(3,'minvowellen',p.minVowelLen, toPrompt);
        end
        
        if (isfield(p,'bRatioShift'))
            Audapter(3,'bratioshift',p.bRatioShift, toPrompt);
        end
        if (isfield(p,'bMelShift'))
            Audapter(3,'bmelshift',p.bMelShift, toPrompt);
		end
		
%% SC(2009/02/06) RMS Clipping protection
% 		if (isfield(p,'bRMSClip'))
% 			Audapter(3,'brmsclip',p.bRMSClip, toPrompt);
% 		end
% 		if (isfield(p,'rmsClipThresh'))
% 			Audapter(3,'rmsclipthresh',p.rmsClipThresh, toPrompt);
% 		end
		
%% SC-Mod(2008/05/15) Cepstral lifting related
        if (isfield(p,'bCepsLift'))
            Audapter(3,'bcepslift',p.bCepsLift, toPrompt);
        else
            Audapter(3,'bcepslift',0, toPrompt);
        end
        if (isfield(p,'cepsWinWidth'))
            Audapter(3,'cepswinwidth',p.cepsWinWidth, toPrompt);
        end        
        
%% Audapter mode
        if (isfield(p, 'bBypassFmt'))  % Mel
            Audapter(3, 'bbypassfmt', p.bBypassFmt, toPrompt);
        end

%% SC-Mod(2008/04/04) Perturbatoin field related 
        if (isfield(p,'F2Min'))  % Mel
            Audapter(3,'f2min',p.F2Min, toPrompt);
        end
        if (isfield(p,'F2Max'))  % Mel
            Audapter(3,'f2max',p.F2Max, toPrompt);
        end
        if (isfield(p,'F1Min'))
            Audapter(3,'f1min',p.F1Min, toPrompt);
        end
        if (isfield(p,'F1Max'))
            Audapter(3,'f1max',p.F1Max, toPrompt);
        end
        if (isfield(p,'LBk'))
            Audapter(3,'lbk',p.LBk, toPrompt);
        end
        if (isfield(p,'LBb'))
            Audapter(3,'lbb',p.LBb, toPrompt);
        end
        if (isfield(p,'pertF2'))   % Mel, 257(=256+1) points
            Audapter(3,'pertf2',p.pertF2, toPrompt);
        end
        if (isfield(p,'pertAmp'))   % Mel, 257 points
            Audapter(3,'pertamp',p.pertAmp, toPrompt);
        end   
        if (isfield(p,'pertPhi'))   % Mel, 257 points
            Audapter(3,'pertphi',p.pertPhi, toPrompt);
        end       
        
        if (isfield(p,'fb'))    % 2008/06/18
            Audapter(3,'fb',p.fb, toPrompt);
        end
        if (isfield(p,'nfb'))    % 2008/06/18
            Audapter(3,'nfb',p.nfb, toPrompt);
        else
            Audapter(3, 'nfb', 1, toPrompt);
        end       
        if (isfield(p,'trialLen'))  %SC(2008/06/22)
            Audapter(3,'triallen',p.trialLen, toPrompt);
        else
            Audapter(3,'triallen',2.5, toPrompt);
        end
        if (isfield(p,'rampLen'))  %SC(2008/06/22)
            Audapter(3,'ramplen',p.rampLen, toPrompt);
        else
            Audapter(3,'ramplen',0.05, toPrompt);
        end
        
        %SC(2008/07/16)
        if (isfield(p,'aFact'))
            Audapter(3,'afact',p.aFact, toPrompt);
        else
            Audapter(3,'afact',1, toPrompt);
        end
        if (isfield(p,'bFact'))
            Audapter(3,'bfact',p.bFact, toPrompt);
        else
            Audapter(3,'bfact',0.8, toPrompt);
        end
        if (isfield(p,'gFact'))
            Audapter(3,'gfact',p.gFact, toPrompt);
        else
            Audapter(3,'gfact',1, toPrompt);
        end
        
        if (isfield(p,'fn1'))
            Audapter(3,'fn1',p.fn1, toPrompt);
        else
            Audapter(3,'fn1',500, toPrompt);
        end
        if (isfield(p,'fn2'))
            Audapter(3,'fn2',p.fn2, toPrompt);
        else
            Audapter(3,'fn2',1500, toPrompt);
        end
        
        if (isfield(p, 'fb3Gain'));
            Audapter(3, 'fb3gain', p.fb3Gain, toPrompt);
        end
        
        if (isfield(p, 'fb4GainDB'));
            Audapter(3, 'fb4gaindb', p.fb4GainDB, toPrompt);
        end
        
        if (isfield(p, 'rmsFF_fb'));
            Audapter(3, 'rmsff_fb', p.rmsFF_fb, toPrompt);
        end
        
        %SC(2012/03/05) Frequency/pitch shifting
        if (isfield(p, 'bPitchShift'))
            Audapter(3, 'bpitchshift', p.bPitchShift, toPrompt);
        end
        if (isfield(p, 'pitchShiftRatio'))
            Audapter(3, 'pitchshiftratio', p.pitchShiftRatio, toPrompt);
        end
        if (isfield(p, 'gain'))
            Audapter(3, 'gain', p.gain, toPrompt);
        end
        
        if (isfield(p, 'mute'))
            Audapter(3, 'mute', p.mute, toPrompt);
        end
        
        if (isfield(p, 'pvocFrameLen'))
            Audapter(3, 'pvocframelen', p.pvocFrameLen, toPrompt);
        end
        if (isfield(p, 'pvocHop'))
            Audapter(3, 'pvochop', p.pvocHop, toPrompt);
        end
        
        if (isfield(p, 'bDownSampFilt'))
            Audapter(3, 'bdownsampfilt', p.bDownSampFilt, toPrompt);
        end
        
        if (isfield(p, 'stereoMode'))
            Audapter(3, 'stereomode', p.stereoMode, toPrompt);
        end
        
        if (isfield(p, 'tsgNTones'))
            Audapter(3, 'tsgNTones', p.tsgNTones, toPrompt);
        end
        if (isfield(p, 'tsgToneDur'))
            Audapter(3, 'tsgToneDur', p.tsgToneDur, toPrompt);
        end
        if (isfield(p, 'tsgToneFreq'))
            Audapter(3, 'tsgToneFreq', p.tsgToneFreq, toPrompt);
        end
        if (isfield(p, 'tsgToneAmp'))
            Audapter(3, 'tsgToneAmp', p.tsgToneAmp, toPrompt);
        end
        if (isfield(p, 'tsgToneRamp'))
            Audapter(3, 'tsgToneRamp', p.tsgToneRamp, toPrompt);
        end
        if (isfield(p, 'tsgInt'))
            Audapter(3, 'tsgInt', p.tsgInt, toPrompt);
        end
        
        if (isfield(p, 'delayFrames'))
            Audapter(3, 'delayFrames', p.delayFrames, toPrompt);
        end
        
        if (isfield(p, 'wgFreq'))
            Audapter(3, 'wgFreq', p.wgFreq, toPrompt);
        end
        if (isfield(p, 'wgAmp'))
            Audapter(3, 'wgAmp', p.wgAmp, toPrompt);
        end
        if (isfield(p, 'wgTime'))
            Audapter(3, 'wgTime', p.wgTime, toPrompt);
        end
        
        if (isfield(p, 'dataPB'))
            Audapter(3, 'dataPB', p.dataPB, toPrompt);
        end
        
        return;
%%            
    case 'process',
        Audapter(5,inFrame);
        return;

    case 'getData',
        nout=nargout;
        [signalMat,dataMat]=Audapter(4);        
        data=[];

        switch(nout)
            case 1,
%                 data.signalIn       = signalMat(:,1);
%                 data.signalOut      = signalMat(:,2);
% 
%                 data.intervals      = dataMat(:,1);
%                 data.rms            = dataMat(:,2:4);
%                 
%                 offS = 5;
%                 data.fmts           = dataMat(:,offS:offS+p.nTracks-1);
%                 data.rads           = dataMat(:,offS+p.nTracks:offS+2*p.nTracks-1);
%                 data.dfmts          = dataMat(:,offS+2*p.nTracks:offS+2*p.nTracks+1);
%                 data.sfmts          = dataMat(:,offS+2*p.nTracks+2:offS+2*p.nTracks+3);
% 
%                 offS = offS+2*p.nTracks+4;
%                 data.ai             = dataMat(:,offS:offS+p.nLPC);
                
                data.signalIn       = signalMat(:,1);
                data.signalOut      = signalMat(:,2);

                data.intervals      = dataMat(:,1);
                data.rms            = dataMat(:,2:4);
                
                offS = 5;
                data.fmts           = dataMat(:,offS:offS+p.nTracks-1);
                data.rads           = dataMat(:,offS+p.nTracks:offS+2*p.nTracks-1);
                data.dfmts          = dataMat(:,offS+2*p.nTracks:offS+2*p.nTracks+1);
                data.sfmts          = dataMat(:,offS+2*p.nTracks+2:offS+2*p.nTracks+3);

                offS = offS + 2 * p.nTracks + 4;
%                 data.ai             = dataMat(:,offS:offS+p.nLPC);
                
                offS = offS + p.nLPC + 1;
                data.rms_slope      = dataMat(:, offS);
                              
                offS = offS + 1;
                data.ost_stat       = dataMat(:, offS);
                
                offS = offS + 1;
                data.pitchShiftRatio = dataMat(:, offS);
                                
                data.params         = getAudapterParamSet();

                varargout(1)        = {data};


                return;

            case 2,
                varargout(1)        = {signalMat(:,1)};
                varargout(2)        = {signalMat(:,2)};
                return;

            case 3,
                varargout(1)        = {transdataMat(1:2,2)'};
                varargout(2)        = {transdataMat(1:2,3)'};
                varargout(3)        = {transdataMat(2,1)-transdataMat(1,1)};
                return;

            otherwise,

        end
    case 'reset',
        Audapter('reset');
        
    case 'ost',
        if nargin == 2
            Audapter(8, params);
        elseif nargin == 4
            Audapter(8, params, varargin{1});
        else
            error('%s: Invalid syntax under mode: %s', mfilename, action);
        end
    case 'pcf',
        if nargin == 2
            Audapter(9, params);
        elseif nargin == 4
            Audapter(9, params, varargin{1});
        else
            error('%s: Invalid syntax under mode: %s', mfilename, action);
        end
        
        
        
    otherwise,
        
    uiwait(errordlg(['No such action : ' action ],'!! Error !!'));


end
