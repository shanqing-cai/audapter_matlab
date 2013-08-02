function varargout=compareFormTrackParams(expDir,varargin)
%% 
    stg={'pre','pract1','pract2'};
	numTrialTypes=2;
	
%% 
    if isfile(fullfile(expDir, 'expt.mat'))
        load(fullfile(expDir, 'expt.mat'));   % gives expt
    else
        disp('The subject directory doesn''t exist. Terminated.');
        return
    end
    sex=expt.subject.sex;
    subjName=expt.subject.name;

%     if (~isfield(expt,'trainWords'))
%         words=expt.words;
%     else
%         words=expt.trainWords;
%     end
    nReps=nan(1,length(stg));
    for n=1:length(stg)
        nReps(n)=expt.script.(stg{n}).nReps;
    end
    
    if (isequal(sex,'male'))
        fmtLims=[0,2500];
    else
        fmtLims=[0,3200];
    end
    
%     word=words(1:5);
    
%% Default new params

	d=dir(fullfile(expDir,[stg{1}],['rep1'],'*-1.mat'));
    load(fullfile(expDir,[stg{1}],['rep1'],d(1).name));
    nLPC=data.params.nLPC;
    nDelay=data.params.nDelay;
    avgLen=data.params.avgLen;
    if (isfield(data.params,'bCepsLift'))
        bCepsLift=data.params.bCepsLift;
        cepsWinWidth=data.params.cepsWinWidth;
    else
        bCepsLift=1;
        if (isequal(sex,'male'))
            cepsWinWidth=45;
        else
            cepsWinWidth=30;
        end
    end
    if (isfield(data.params,'fn1'))
        fn1=data.params.fn1;
    else
        if (isequal(sex,'male'))
            fn1=591;
        else
            fn1=675;
        end
    end
    if (isfield(data.params,'fn2'))
        fn2=data.params.fn2;
    else
        if (isequal(sex,'male'))
            fn2=1314;
        else
            fn2=1392;
        end
    end
    if (isfield(data.params,'aFact'))
        aFact=data.params.aFact;
    else
        aFact=1;
    end    
    if (isfield(data.params,'bFact'))
        bFact=data.params.bFact;
    else
        bFact=1;
    end
    if (isfield(data.params,'gFact'))
        gFact=data.params.gFact;
    else
        gFact=1;
    end     
    
    clear expt
%% 
    % Initialize it
    for n=1:2
        load(fullfile(expDir,[stg{1}],['rep1'],d(1).name));
%         data=expt.(stg{1}).(['rep',num2str(1)]).(word{1}).data;
        p=data.params;

        % Update params
        p.nLPC=nLPC;
        p.nDelay=nDelay;        
        p.bufLen=(2*p.nDelay-1)*(p.frameLen);
        p.anaLen=p.frameShift+2*(p.nDelay-1)*p.frameLen;
        p.avgLen=avgLen;
        p.bCepsLift=bCepsLift;
        p.cepsWinWidth=cepsWinWidth;
        p.fn1=fn1;
        p.fn2=fn2;
        p.aFact=aFact;
        p.bFact=bFact;
        p.gFact=gFact;
        
        [fmts1,transLims]=testTSM(data,p);
    end
    t0=data.params.frameLen/data.params.sr;
        
    disp('Green: re-estimated; white: original');
    cmd='';
    %debug
%     cmd='nLPC=15;nDelay=9;avgLen=10;bCepsLift=0;cepsWinWidth=32';
    
    while ~(isequal(cmd,'q') | isequal(cmd,'Q'))
%         errF1s=[];
%         errF2s=[];
        figure('Position',[10,70,1200,560]);
        
        if (~isempty(cmd) & ~strcmp(cmd(end),';'))
            cmd=[cmd,';'];
        end
        idxsc=strfind(cmd,';');
        if (~isempty(strfind(cmd,'nLPC=')))
            k1=strfind(cmd,'nLPC=');
            k2=idxsc(min(find(idxsc>k1)));
            nLPC=str2num(cmd((k1+5:k2-1)));
        end
        if (~isempty(strfind(cmd,'nDelay=')))
            k1=strfind(cmd,'nDelay=');
            k2=idxsc(min(find(idxsc>k1)));
            nDelay=str2num(cmd((k1+7:k2-1)));
        end
        if (~isempty(strfind(cmd,'avgLen=')))
            k1=strfind(cmd,'avgLen=');
            k2=idxsc(min(find(idxsc>k1)));
            avgLen=str2num(cmd((k1+9:k2-1)));
        end
        if (~isempty(strfind(cmd,'bCepsLift=')))
            k1=strfind(cmd,'bCepsLift=');
            k2=idxsc(min(find(idxsc>k1)));
            bCepsLift=str2num(cmd((k1+10:k2-1)));
        end
        if (~isempty(strfind(cmd,'cepsWinWidth=')))
            k1=strfind(cmd,'cepsWinWidth=');
            k2=idxsc(min(find(idxsc>k1)));
            cepsWinWidth=str2num(cmd((k1+13:k2-1)));
        end
        if (~isempty(strfind(cmd,'fn1=')))
            k1=strfind(cmd,'fn1=');
            k2=idxsc(min(find(idxsc>k1)));
            fn1=str2num(cmd((k1+4:k2-1)));
        end
        if (~isempty(strfind(cmd,'fn2=')))
            k1=strfind(cmd,'fn2=');
            k2=idxsc(min(find(idxsc>k1)));
            fn2=str2num(cmd((k1+4:k2-1)));
        end
        if (~isempty(strfind(cmd,'aFact=')))
            k1=strfind(cmd,'aFact=');
            k2=idxsc(min(find(idxsc>k1)));
            aFact=str2num(cmd((k1+6:k2-1)));
        end
        if (~isempty(strfind(cmd,'bFact=')))
            k1=strfind(cmd,'bFact=');
            k2=idxsc(min(find(idxsc>k1)));
            bFact=str2num(cmd((k1+6:k2-1)));
        end
        if (~isempty(strfind(cmd,'gFact=')))
            k1=strfind(cmd,'gFact=');
            k2=idxsc(min(find(idxsc>k1)));
            gFact=str2num(cmd((k1+6:k2-1)));
        end
    
        disp(['--- nLPC=',num2str(nLPC),'; nDelay=',num2str(nDelay),'; avgLen=',num2str(avgLen),...
            '; bCepsLift=',num2str(bCepsLift),'; cepsWinWidth=',num2str(cepsWinWidth),...
            '; fn1=',num2str(fn1),'; fn2=',num2str(fn2),...
            '; aFact=',num2str(aFact),'; bFact=',num2str(bFact),'; gFact=',num2str(gFact),' ---']);
        
        counter=1;
        for k1=1:length(stg)
            for k2=1:2				
                for r=1:nReps(k1)
                    if (counter>10)
                        continue;
                    end
                            
					d=dir(fullfile(expDir,[stg{k1}],['rep',num2str(r)],['trial-*-',num2str(k2),'.mat']));
					for k3=1:length(d)
						if (counter<=10)
							subplot(2,5,counter);
						else
							continue;
						end
						load(fullfile(expDir,[stg{k1}],['rep',num2str(r)],d(k3).name));    % gives data
						p=data.params;

						% Update params
						p.nLPC=nLPC;
						p.nDelay=nDelay;        
						p.bufLen=(2*p.nDelay-1)*(p.frameLen);
						p.anaLen=p.frameShift+2*(p.nDelay-1)*p.frameLen;
						p.avgLen=avgLen;
						p.bCepsLift=bCepsLift;
						p.cepsWinWidth=cepsWinWidth;
						p.fn1=fn1;
						p.fn2=fn2;
						p.aFact=aFact;
						p.bFact=bFact;
						p.gFact=gFact;

						[fmts1,transLims]=testTSM(data,p);
						if (counter==1)
							[fmts1,transLims]=testTSM(data,p);
						end
						counter=counter+1;

						fmts0=data.fmts(:,1:2);
						l=size(fmts1,1);

						fmts1=[fmts1(p.nDelay:end,:);zeros(p.nDelay-1,2)];
						fmts0=[fmts0(data.params.nDelay:end,:);zeros(data.params.nDelay-1,2)];        

						[s,f,t]=spectrogram(data.signalIn,128,120,1024,data.params.sr);
						imagesc(t*1e3,f,log10(abs(s)));
						axis xy;    hold on;

						taxis=1e3*(0:t0:t0*(size(fmts1,1)-1));
                        
                        commonLen=min([length(taxis),size(fmts1,1)]);
						plot(taxis(1:commonLen),fmts1(1:commonLen,:),'g','LineWidth',1.5);
                        commonLen=min([length(taxis),size(fmts0,1)]);
						plot(taxis(1:commonLen),fmts0(1:commonLen,:),'w','LineWidth',1);
						set(gca,'YLim',fmtLims);
						if (~isnan(transLims(1)) & ~isnan(transLims(2)))
							set(gca,'XLim',1e3*t0*[transLims(1)-50,min(transLims(2)+50,length(taxis))]);
% 							errF1s=[errF1s,sqrt(mean((fmts1(transLims(1):transLims(2),1)-fmts0(transLims(1):transLims(2),1)).^2))];
% 							relErrF1s=errF1s/(mean(fmts1(transLims(1):transLims(2),1)));
% 							errF2s=[errF2s,sqrt(mean((fmts1(transLims(1):transLims(2),2)-fmts0(transLims(1):transLims(2),2)).^2))];
% 							relErrF2s=errF2s/(mean(fmts1(transLims(1):transLims(2),2)));                        
						end

						% RMS error (Hz)
					end
                end
            end
        end

%         set(gcf,'Name',[subjName,' | nLPC=',num2str(nLPC),'; nDelay=',num2str(nDelay),'; bCepsLift=',num2str(bCepsLift),...
%             ' | Err(F1)=',num2str(mean(errF1s)),'Hz; Err(F2)=',num2str(mean(errF2s)),'Hz.',...
%             'relErr(F1)=',num2str(mean(relErrF1s)),'; relErr(F2)=',num2str(mean(relErrF2s))]);
        
        cmd=input('cmd: ','s');
    end
    
%% Output
    optimParams=struct();
    optimParams.nLPC=p.nLPC;
    optimParams.nDelay=p.nDelay;
    optimParams.bufLen=p.bufLen;
    optimParams.anaLen=p.anaLen;
    optimParams.avgLen=p.avgLen;
    optimParams.bCepsLift=p.bCepsLift;
    optimParams.cepsWinWidth=p.cepsWinWidth;
    optimParams.fn1=fn1;
    optimParams.fn2=fn2;
    optimParams.aFact=aFact;
    optimParams.bFact=bFact;
    optimParams.gFact=gFact;
    
    varargout{1}=optimParams;
return