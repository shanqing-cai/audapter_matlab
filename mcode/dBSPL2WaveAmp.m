% function wp=dBSPL2WaveAmp(lv, f, pcrKnob)
% % lv: level in dB SPL (rms)
% % f in Hz, can only be one of the following [0.25, 0.5, 1, 2, 3, 4, 6] kHz;
% % pcrKnob in the range [-2.5, 0.5]
% % wp: wave in 
%     if (~isfile('C:\speechres\signals\leveltest\waveVoltGain.mat'))
%         addpath('C:\speechres\signals\leveltest\');
%         calcPhoneGain('noPlot');
%     end
%     load('C:\speechres\signals\leveltest\waveVoltGain.mat');
%     
%     fs=[0.25, 0.5, 1, 2, 3, 4, 6]*1e3;
%     idxf=find(fs==f);
%     
%     if (isempty(idxf))
%         wp=NaN
%         return;
%     end
%     if (pcrKnob>0.5 | pcrKnob<-2.5)
%         wp=NaN;
%         return;
%     end
%     
%     wvg=interp1(waveVoltGain{idxf}(:,1),waveVoltGain{idxf}(:,2),pcrKnob);   % wave-voltage gain: V_p/wave_p
%     
%     % According to the manual, 10-Ohm phone: 102.5 dB SPL at 0.1 V_rms
%     lv=lv+5;    % two ear piece compensation, 
%     volt=10^((lv-102.5)/20) * (0.1*sqrt(2));    % Assumption: ER-3A manual talks about one phone
%     
%     wp=volt/wvg;
% return

function wp=dBSPL2WaveAmp(lv, f, varargin)
% Note: this applies to balance = 0 and Phones/CtrlRoom = Max on Behringer
% Use Shanqing1 profile in M-Audio control panel. 
% load('../../signals/leveltest/outputCalibration_S14.mat'); % contains calib at 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5 kHz. 
% % calib.f, calib.dBASPL (at max). 
% 
% wp0=0.1;
% 
% dBASPL0=interp1(log10(calib.f),calib.dBASPL,log10(f));
% dBSPL0=dBASPL0-20*log10(weightA(f));
% 
% wp=10^((lv-dBSPL0)/20)*wp0;

wp0=0.1;
% wp=10^((lv-103.5)/20)*wp0;
wp = 10 ^ ((lv - 100) / 20) * wp0;

return