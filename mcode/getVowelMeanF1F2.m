function [f1_mean,f2_mean] = getVowelMeanF1F2(dataDir,varargin)
%SC Input parameters
%SC   varargin(1) = dirname; (expt dir name)
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

load(fullfile(dataDir,'expt.mat'));   % gives expt
% if (~isfield(expt,'trainWords'))
%     trainWords=expt.words;
% else
%     trainWords=expt.trainWords;
% end

%% Load and format data

subDirs=dir(fullfile(dataDir,thisPhase,'rep*'));
meanF1s=[];
meanF2s=[];

fprintf('Calculating mean F1 & F2 ');
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
        if (isnan(k1) | isnan(k2) | k1==0 | k2==0 | k2<=k1)
            continue;
        end
        if (k2-k1<60)
            continue;
        end
        meanF1s=[meanF1s,mean(data.fmts(k1:k2,1))];
        meanF2s=[meanF2s,mean(data.fmts(k1:k2,2))];
    end
end
f1_mean=mean(meanF1s);
f2_mean=mean(meanF2s);
fprintf('\n');

return
