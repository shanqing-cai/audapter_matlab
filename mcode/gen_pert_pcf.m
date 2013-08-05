function gen_pert_pcf(nStates, pertStates, pitchPertST, pertAmp, pertPhi, pcf_fn)
pcf = fopen(pcf_fn, 'wt');

fprintf(pcf, '# Section 1 (Time warping): tBegin, rate1, dur1, durHold, rate2 \n');
fprintf(pcf, '0\n');
fprintf(pcf, '\n');

fprintf(pcf, '# Section 2: stat pitchShift(st) gainShift(dB) fmtPertAmp fmtPertPhi(rad)\n');
fprintf(pcf, '%d\n', nStates + 1);
for i1 = 0 : nStates
    if ~isempty(find(pertStates == i1, 1))
        fprintf(pcf, '%d, %f, 0, %f, %f\n', i1, pitchPertST, pertAmp, pertPhi);
    else
        fprintf(pcf, '%d, 0, 0, 0, 0\n', i1);
    end
end

fclose(pcf);
return