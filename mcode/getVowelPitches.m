function [f0_mean,f0_std] = getVowelPitches(dataDir,varargin)
%SC Input parameters
%SC   varargin(1) = dirname; (experiment dir name)
%SC   varargin(2) = params
%SC   varargin(3) = doPlot

toPlot=0;
if (~isempty(findStringInCell(varargin,'plot')))
    toPlot=1;
end

%% Parameters
% dataDir='G:\scai\killick1_backup\TRIPHSA\PS401';
% N=257;
% pertRatio=p.pertRatio;
% pertDirection=p.shiftDirection;

% nRampReps=p.nRampReps;

thisPhase='pract2';  %SC This routine is always immmediately after the 'start' phase. The data from the 'start' phase will be used to generate the rotation parameters
% colors={'b','r','k'};

load(fullfile(dataDir,'expt.mat'));   % gives experiment
% if (~isfield(expt,'trainWords'))
%     trainWords=expt.words;
% else
%     trainWords=expt.trainWords;
% end
sex=expt.subject.sex;

%% Load and format data

subDirs=dir(fullfile(dataDir,thisPhase,'rep*'));
pitches=cell(1,0);

cntWords=0;
cntWordsDiscard=0;
fprintf('Calculating F0 ');
for n=1:length(subDirs)
    fprintf('.');
    d=dir(fullfile(dataDir,thisPhase,subDirs(n).name,'*.mat'));
    
    for m=1:length(d)
        tokenName=strrep(d(m).name,'.mat','');
		trialType=str2num(tokenName(end));
		if (trialType==3 | trialType==4)
			continue;
		end
		
        load(fullfile(dataDir,thisPhase,subDirs(n).name,d(m).name));  % gives data
        [i1,i2,f1,f2,iv1,iv2]=getFmtPlotBounds(data.fmts(:,1),data.fmts(:,2));
        [k1,k2]=detectVowel(data.fmts(:,1),data.fmts(:,2),iv1,iv2,'eh','rms',data.rms(:,1));
        if (isnan(k1) || isnan(k2) || k1==0 || k2==0 || k2<=k1)
            continue;
        end
        if (k2-k1<60)
            continue;
        end
        cntWords=cntWords+1;
        tSig=data.signalIn([(k1+1)*data.params.frameLen:(k2-1)*data.params.frameLen]);
        tPitch=getPitch(tSig,data.params.sr,sex);
        if (~isempty(find(diff(tPitch)>=30)))   
            cntWordsDiscard=cntWordsDiscard+1;
            continue;
        end
        pitches{length(pitches)+1}=tPitch;
    end
end
fprintf('\n');
disp([num2str(cntWordsDiscard),' of ',num2str(cntWords),' discarded.']);

meanPitches=[];
for n=1:length(pitches)
    meanPitches=[meanPitches,mean(pitches{n})];    
end
f0_mean=mean(meanPitches);
f0_std=std(meanPitches);

if (toPlot)
    figure;
    for n=1:length(pitches)
        plot(pitches{n});    hold on;
    end
    set(gca,'YLim',[0,400]);
end
%%
