function [k1,k2]=detectVowel(f1,f2,i1,i2,varargin)
     
% fitlen=35;

% f11=[300,1600];
% f21=[500,2500];

% fmtMinDiff=0.5; % Hz/samp
% dFmtEdge1=0.5;
% dFmtEdge2=1;
% exitCntThresh=30;
% minTransLen=60;

% if ~isempty(findStringInCell(varargin,'rms'))
% 	rms1=varargin{findStringInCell(varargin,'rms')+1};
% end
% 
% rms1=mva(rms1,10);
% 
% maxRMS=max(rms1);
% threshRMS=0.5*maxRMS;
% idx1=find(rms1(1:end-1)<threshRMS & rms1(2:end)>=threshRMS);
% idx2=find(rms1(1:end-1)>=threshRMS & rms1(2:end)<threshRMS);
% 
% if (isempty(idx1) | isempty(idx2))
%     k1=0;
%     k2=0;
%     return
% end
% 
% % k1=idx1(1);
% % k2=idx2(end);
% if (idx2(1)<idx1(1))    % This means that the threshold is already crossed at the beginning
%     idx1=[1,idx1];
% end
% if (idx1(end)>idx2(end))    % This means that the rms doesn't come below the threshold at the end
%     idx2=[idx2,length(rms1)];
% end
% 
% if (length(idx1)~=length(idx2))
%     disp('detectVowel: Warning: length(idx1) ~= length(idx2)!!!');
%     k1=0;
%     k2=0;
%     return
% end
% lens=idx2-idx1;
% [jnk,idxmax]=max(lens);
% k1=idx1(idxmax);
% k2=idx2(idxmax);

if (isempty(i1) | isempty(i2) | isnan(i1) | isnan(i2))
	k1=0;
	k2=0;
	return
end

k1=i1;
k2=i2;
return