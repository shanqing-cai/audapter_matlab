function updateDataMonitor(data, handles)
set(0,'CurrentFigure',handles.figIdDat(1));

t0=1/data.params.sr;
taxis=0:t0:t0*(length(data.signalIn)-1);

% -- Input waveform --
set(gcf,'CurrentAxes',handles.figIdDat(2));
cla;
plot(taxis,data.signalIn);      hold on;
set(gca,'XLim',[taxis(1);taxis(end)]);
set(gca,'YLim',[-1,1]);
ylabel('Wave In');

% -- Output waveform --
set(gcf,'CurrentAxes',handles.figIdDat(3));
cla;
taxis=0:t0:t0*(length(data.signalOut)-1);
plot(taxis,data.signalOut*handles.dScale);     hold on;
set(gca,'XLim',[taxis(1);taxis(end)]);
set(gca,'YLim',[-1,1]);
xlabel('Time (sec)');
ylabel('Wave Out');


[i1,i2,f1,f2,iv1,iv2]=getFmtPlotBounds(data.fmts(:,1),data.fmts(:,2));
[k1,k2]=detectVowel(data.fmts(:,1),data.fmts(:,2),iv1,iv2,'eh','rms',data.rms(:,1));
if (~isnan(i1) && ~isnan(i2) && ~isempty(i1) && ~isempty(i2) && k2 >= k1)
	t1=k1*data.params.frameLen;
	t2=k2*data.params.frameLen;
	tv1=min(find(data.fmts(:,1)>0));
	tv2=max(find(data.fmts(:,1)>0));

	idx1=max([1,tv1-50]);
	idx2=min([tv2+50,length(data.signalIn)]);

%     wavInGain=0.13827;  % w/Pa
	p0=20e-6;           % Pa
% 	tRMSIn=sqrt(mean((data.signalIn(t1:t2)).^2));

    
	set(gcf,'CurrentAxes',handles.figIdDat(2));
	xs=get(gca,'XLim'); ys=get(gca,'YLim');
    
    load('micRMS_100dBA.mat');  % Gives micRMS_100dBA: the rms the microphone should read when the sound is at 100 dBA SPL
%     text(xs(1)+0.05*range(xs),ys(2)-0.1*range(ys),['RMS(In)=',num2str(tRMSIn)]);
%     text(xs(1)+0.05*range(xs),ys(2)-0.2*range(ys),...
%         ['soundLevel=',num2str(100+20*log10((rmsTrans/micRMS_100dBA))),' dBA SPL'],'FontSize',11);
    
%         text(xs(1)+0.05*range(xs),ys(2)-0.2*range(ys),...
%     ['soundLevel=',num2str(100+20*log10((rmsTrans/micRMS_100dBA))),' dBA SPL'],'FontSize',11);

%     text(xs(1)+0.05*range(xs),ys(2)-0.25*range(ys),...
%         ['BGNoiseLevel=',num2str(100+20*log10((rmsBGNoise/micRMS_100dBA))),' dBA SPL'],'FontSize',11);

%     text(xs(1)+0.05*range(xs),ys(2)-0.3*range(ys),...
%         ['SNR=',num2str(20*log10(rmsTrans/rmsBGNoise))],'FontSize',11);
    if isfield(data, 'vowelLevel')
        text(xs(1) + 0.05 * range(xs), ys(2) - 0.3 *range(ys), ...
             ['vowelLevel = ', num2str(data.vowelLevel)], 'FontSize', 11);
    end

	if (~isnan(t1) && ~isnan(t2) && t1>0 && t2>0 && t2>t1)
		plot([taxis(t1),taxis(t1)],[ys(1),ys(2)],'-','Color',[0.5,0.5,0.5],'LineWidth',0.5);  hold on;
		plot([taxis(t2),taxis(t2)],[ys(1),ys(2)],'-','Color',[0.5,0.5,0.5],'LineWidth',0.5);  hold on;
		tRMSOut=calcAWeightedRMS(data.signalOut(t1:t2),data.params.sr);
	else 
		tRMSOut=0;
    end

    soundLvOut=20*log10(tRMSOut*handles.dScale/(dBSPL2WaveAmp(0,1000)/sqrt(2)));  % dBA SPL

	set(gcf,'CurrentAxes',handles.figIdDat(3));
	xs=get(gca,'XLim'); ys=get(gca,'YLim');
	if (~isnan(t1) && ~isnan(t2) && t1>0 && t2>0 && t2>t1)	
		plot([taxis(t1),taxis(t1)],[ys(1),ys(2)],'-','Color',[0.5,0.5,0.5],'LineWidth',0.5);  hold on;
		plot([taxis(t2),taxis(t2)],[ys(1),ys(2)],'-','Color',[0.5,0.5,0.5],'LineWidth',0.5);  hold on;
    end
	text(xs(1)+0.05*range(xs),ys(2)-0.15*range(ys),...
		['dScale=',num2str(handles.dScale)],'FontSize',11);    
	text(xs(1)+0.05*range(xs),ys(2)-0.2*range(ys),...
		['soundLevel=',num2str(soundLvOut),' dBA SPL'],'FontSize',11);

    % -- Formant trajectories --
% 	set(gcf,'CurrentAxes',handles.figIdDat(4));
% 	cla;
% 	if (data.params.frameLen*idx1>=1 & data.params.frameLen*idx2<=length(taxis) & idx1>=1 & idx2 <= size(data.fmts,1))
% 		plot(taxis(data.params.frameLen*(idx1:idx2)),data.fmts(idx1:idx2,1),'k-','LineWidth',1.5);   hold on;
% 		plot(taxis(data.params.frameLen*(idx1:idx2)),data.fmts(idx1:idx2,2),'k-','LineWidth',1.5); 
% 		plot(taxis(data.params.frameLen*(idx1:idx2)),data.sfmts(idx1:idx2,1),'b-','LineWidth',1.5);
% 		plot(taxis(data.params.frameLen*(idx1:idx2)),data.sfmts(idx1:idx2,2),'b-','LineWidth',1.5);
% 		set(gca,'XLim',taxis(data.params.frameLen*([idx1,idx2])));
% 		set(gca,'YLim',[0,3000]);
% 		xs=get(gca,'XLim'); ys=get(gca,'YLim');
% 		plot(taxis(data.params.frameLen*([k1,k1])),[ys(1),ys(2)],'-','Color',[0.5,0.5,0.5],'LineWidth',0.5);  hold on;
% 		plot(taxis(data.params.frameLen*([k2,k2])),[ys(1),ys(2)],'-','Color',[0.5,0.5,0.5],'LineWidth',0.5);  hold on;    
% 		xlabel('Time (sec)');
% 		ylabel('Formant freqs (Hz)');
%         
%         
% 	else
% 		cla;
%     end

    % -- F1/F2 plane plot --
% 	set(gcf,'CurrentAxes',handles.figIdDat(5));
% 	cla;
% 	if (~isnan(k1) && ~isnan(k2) && k1>0 && k2>0 && t2>t1)
% 		plot(data.fmts(k1:k2,1),data.fmts(k1:k2,2),'b-','LineWidth',1.5);   hold on;
% 		plot(data.sfmts(k1:k2,1),data.sfmts(k1:k2,2),'b-','LineWidth',1.5);   hold off;
% 	end
% 	set(gca,'XLim',[0,2000]);
% 	set(gca,'YLim',[0,3000]);
% 	grid on;
% 	xlabel('F1 (Hz)');
% 	ylabel('F2 (Hz)');

    % -- Input spectrogram and formant trajectories -- %
    for ii = [4, 5]
        set(gcf,'CurrentAxes',handles.figIdDat(ii));
        cla;
        if (~isnan(k1) && ~isnan(k2) && k1>0 && k2>0 && t2>t1)
            idx_seg_1 = max([1, (idx1 - 1) * data.params.frameLen + 1]);
            idx_seg_2 = min([idx2 * data.params.frameLen, length(data.signalIn)]);
            
            if ii == 4
                sigSeg = data.signalIn(idx_seg_1 : idx_seg_2);
            else
                sigSeg = data.signalOut(idx_seg_1 : idx_seg_2);
            end
            
            [s, f, t] = spectrogram(sigSeg, 128, 96, 1024, data.params.sr);
            imagesc(t,f,10*log10(abs(s))); hold on;
            axis xy;
            hold on;

            frameDur = data.params.frameLen / data.params.sr;
            taxis1 = frameDur * (idx1 - 1) : frameDur : frameDur * (idx2 - 1);
            taxis1 = 0 : frameDur : frameDur * (idx2 - idx1);
            if idx2 <= size(data.fmts, 1)
                plot(taxis1, data.fmts(idx1 : idx2, 1), 'k-', 'LineWidth', 1.5);   hold on;
                plot(taxis1, data.fmts(idx1 : idx2, 2), 'k-', 'LineWidth', 1.5);
                
                if ii == 5
                    plot(taxis1, data.sfmts(idx1 : idx2, 1 : 2), 'c-', 'LineWidth', 1.5);
                end

                plot(taxis1, data.ost_stat(idx1 : idx2) * 500, 'b-');
                
                % -- Show time interval that contains the perturbation -- %
                 minPertState = min(handles.pertStates);
                 maxPertState = max(handles.pertStates);

                 idxPert_0 = find(data.ost_stat(idx1 : idx2) == minPertState, 1, 'first');
                 if ~isempty(idxPert_0)
                     idxPert_1 = find(data.ost_stat(idx1 : idx2) == maxPertState, 1, 'last');
                     if isempty(idxPert_1)
                         idxPert_1 = find(data.ost_stat(idx1 : idx2) == minPertState, 1, 'last');
                     end
                     
                     ys = get(gca, 'YLim');
                     plot(repmat(taxis1(idxPert_0), 1, 2), ys, 'm--');
                     plot(repmat(taxis1(idxPert_1), 1, 2), ys, 'm-');
                 end
                 
            end
            
            % --- Draw the perturbed time interval  --- %


            set(gca, 'XLim', [t(1),t(end)]);
            set(gca, 'YLim', [0, 5000]);
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            
            xs = get(gca, 'XLim');
            ys = get(gca, 'YLim');
            if ii == 4
                text(xs(1) + 0.025 * range(xs), ys(2) - 0.06 * range(ys), ...
                     'Mic. input');
            else
                text(xs(1) + 0.025 * range(xs), ys(2) - 0.06 * range(ys), ...
                     'Auditory feedback');
            end
            
            grid on;
        end
    end
    
    % -- Input spectrogram and formant trajectories -- %
end

return