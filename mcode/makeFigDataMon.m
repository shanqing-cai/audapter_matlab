function figIdDat=makeFigDataMon()
fid=figure('Position',[300,60,560,640],'Name','Data monitor');
axes1=subplot('Position',[0.075,0.575,0.4,0.4]);   % Input waveform
axes2=subplot('Position',[0.075,0.1,0.4,0.4]);   % Output waveform
axes3=subplot('Position',[0.55,0.575,0.4,0.4]);
axes4=subplot('Position',[0.55,0.1,0.4,0.4]);
% axes5=subplot('Position',[0.7,0.575,0.275,0.4]);
% axes6=subplot('Position',[0.7,0.1,0.275,0.4]);
figIdDat=[fid,axes1,axes2,axes3,axes4];
return