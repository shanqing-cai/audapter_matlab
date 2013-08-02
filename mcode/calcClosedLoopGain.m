function closedLoopGain=calcClosedLoopGain(pcrKnob)
% The closed loop gain. Calculated at 1 kHz, but should apply to other
% frequencies as well.
    load('micRMS_100dBA.mat');      % gives micRMS_100dBA, the wave in level (rms) when the level is 100 dBA. See signals/leveltest/calcMicGain.m
    a=[dBSPL2WaveAmp(100,500),dBSPL2WaveAmp(100,1000),dBSPL2WaveAmp(100,2000),dBSPL2WaveAmp(100,3000),dBSPL2WaveAmp(100,4000)];
    waveRMS_100dBA=rms(a)/sqrt(2); % At 1000 kHz, the A-weighting correction is 0 dB. The division by sqrt(2) is for translating wave_p to wave_rms
    closedLoopGain=20*log10(micRMS_100dBA/waveRMS_100dBA);  % Unit: dB    
return