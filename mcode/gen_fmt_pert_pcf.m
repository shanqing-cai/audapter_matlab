function gen_fmt_pert_pcf(pertAmp, pertPhi, pcf_fn)
pcf = fopen(pcf_fn, 'wt');

fprintf(pcf, '# Section 1 (Time warping): tBegin, rate1, dur1, durHold, rate2 \n');
fprintf(pcf, '0\n');
fprintf(pcf, '\n');

fprintf(pcf, '# Section 2: stat pitchShift(st) gainShift(dB) fmtPertAmp fmtPertPhi(rad)\n');
fprintf(pcf, '1\n');
fprintf(pcf, '0, 0.0, 0, %f, %f\n', pertAmp, pertPhi);

fclose(pcf);
return