function varargout=calibOutput()
%% Frequency response at 0 knob setting

waveAmp=[0.005,0.01,0.025,0.05];    % Peak amplitude of the digital wave played by Audapter(11)

freq=[0.25,0.50,1,2,3,4,5,7.5,10];
voltAmp{1}=[2.7,2.7,2.7,2.6,2.5,2.3,2.5,2.8,2.9;
            2.7,2.7,2.6,2.6,2.5,2.4,2.5,2.8,3.0] / 2 / 1e3;       % RMS voltage amplitude (V)
voltAmp{2}=[5.4,5.4,5.4,5.3,5.0,4.7,5.1,5.7,6.0;
            5.4,5.4,5.3,5.3,5.0,4.7,5.1,5.7,6.0] / 2 / 1e3;
voltAmp{3}=[13.4,13.4,13.4,13.3,12.6,11.9,12.8,14.4,15.2;
            13.5,13.4,13.4,13.4,12.7,12.0,12.8,14.4,15.2] / 2 / 1e3;        
voltAmp{4}=[27.0,26.9,26.9,26.8,25.4,24.0,25.8,29.1,30.4;
            27.0,26.9,26.9,26.8,25.4,24.0,25.8,29.0,30.5] / 2 / 1e3;
        
voltAmps=[mean(voltAmp{1});mean(voltAmp{2});mean(voltAmp{3});mean(voltAmp{4})];       
voltGains=nan(1,size(voltAmps,2));        
rs=nan(1,size(voltAmps,2));
  
for n = 1:length(voltGains)
   [b,bint,r,rint,stats]=regress(voltAmps(:,n),[ones(length(waveAmp),1),waveAmp']);
   voltGains(n)=b(2);
   rs(n)=stats(1);
end

figure('Position',[300,300,400,300]);
set(gca,'FontSize',11);
% loglog(freq,mean(voltAmp{1}),'bo-');  hold on;
% loglog(freq,mean(voltAmp{2}),'ro-');
% loglog(freq,mean(voltAmp{3}),'go-');
idx1k=find(freq==1);
loglog(freq,voltGains,'bo-','LineWidth',2);  hold on;
% semilogx(freq,20*log10(voltGains/voltGains(idx1k)),'bo-');  hold on;

set(gca,'XTick',[0.1,1,10]);
set(gca,'XTickLabel',[0.1,1,10]);
set(gca,'YLim',[0.1,1])
set(gca,'YTick',[0.1,1])
set(gca,'YTickLabel',[0.1,1]);
xlabel('Frequency (kHz)');
ylabel('Wave output gain (V rms)');
ys=get(gca,'YLim');
text(0.15,0.15,['Average gain=',num2str(mean(voltGains)),' V_r_m_s'],'FontSize',11);
grid on;


%% Relationship between the gain and the knob setting

knobs=[-3,-2,-1,0,1,2];
freq=[0.25,1,5];
voltAmp{1}=[1.7,3.3,9.2,14.6,21.3,35.1] / 2 / 1e3;  % Voltage rms (V)
voltAmp{2}=[1.7,3.4,9.3,14.7,22.6,35.0] / 2 / 1e3;
voltAmp{3}=[1.5,3.3,8.7,13.6,21.7,35.6] / 2 / 1e3;
voltAmps=[voltAmp{1};voltAmp{2};voltAmp{3}];

knobGains=nan(1,size(voltAmps,1));
figure;
for n=1:size(voltAmps,1)
    semilogy(knobs,voltAmps(n,:),'bo-'); hold on;
    [b,bint,r,rint,stats]=regress(transpose(log10(voltAmps(n,:))),[ones(size(voltAmps,2),1),knobs']);
    knobGains(n)=20*b(2);
end

figure('Position',[300,300,400,300]);
set(gca,'FontSize',11);
semilogx(freq,20*knobGains,'bo-','LineWidth',2);
xlabel('Frequency (kHz)');
ylabel('Phone/CtrlRoom knob gain (dB / tick)');
set(gca,'XLim',[0.1,10]);
set(gca,'XTick',[0.1,1,10]);
set(gca,'XTickLabel',[0.1,1,10]);
set(gca,'YLim',[0,10]);
grid on;
xs=get(gca,'XLim');
ys=get(gca,'YLim');
text(xs(1)+0.005*range(xs),ys(1)+0.12*range(ys),['Gain=',num2str(mean(knobGains)),' dB/tick'],'FontSize',11);

save('../mcode/calibOutput.mat','freq','voltGains','knobGains');

return