Audapter('deviceName', 'MOTU Audio');
Audapter(3, 'srate', 12000);
Audapter(3, 'downfact', 4);
Audapter(3, 'framelen', 64);

% Audapter playTone;
Audapter(1);
pause(2);
Audapter(2);

sig = Audapter(4);

show_spectrogram(sig(:, 1), 12e3);