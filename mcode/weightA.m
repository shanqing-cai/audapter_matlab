function w=weightA(f)
% A: the (relative) weight
% f: frequency in Hz
%     f=20:1:10000;
    w=12200^2 * f.^4 ./ (f.^2 + 20.6^2) ./ sqrt((f.^2+107.7.^2).*(f.^2+737.9^2)) ./ (f.^2+12200^2);
    w=w*(10^(2/20));
%     semilogx(20*log10(w));
return