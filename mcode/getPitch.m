function f0s=getPitch(varargin)
%% Load signal and specify parameters
if (nargin==0)
    [sig,sr]=wavread('site2.wav');        % Site2: Fric.(9338:11400),Vowel:(11700:16380)
else
%     fileName=varargin{1};
%     load(fileName); % gives data
    sig=varargin{1};
    sr=varargin{2};
    sex=varargin{3};
end
nFrame=16;
anaLen=31;
hLen=(anaLen-1)/2;
nLPC=13;
nFmts=4;
% nAC=80; % nAC=nLPC+1, nLPC=nAC-1
nFFT=1024;
nStart=1;

%% 
if (isequal(sex,'male') | isequal(sex,'m'))
    pitchRange=[30,200];    % Hz
elseif (isequal(sex,'female') | isequal(sex,'f'))
    pitchRange=[120,300];   % Hz
end
    
cepsPitchWin=fliplr(round(sr./pitchRange))+1;
dThresh=3;

f0s=[];
fmts=zeros(0,nFmts);
for n0=nStart+hLen*nFrame:nFrame:length(sig)-(anaLen*nFrame-hLen*nFrame)
    %% Get a window of the signal

    nWin=[n0-hLen*nFrame:n0+(hLen+1)*nFrame-1];
    x=sig(nWin);
%     figure;plot(x);

    %% Apply a Hanning window
    hanWin=hanning(length(nWin));
    x=x.*hanWin;
%         figure;plot(x);
    
    X=fft(x,nFFT);  % Signal spectrum
    Xceps=ifft(log(abs(X))); % Signal cepstrum

   	pceps=Xceps(cepsPitchWin(1):cepsPitchWin(2));
    
    K=floor(length(pceps)/2)*2;
    mpceps1=pceps(1:2:K-1);
    mpceps2=pceps(2:2:K);
    mpceps=transpose([mpceps1,mpceps2]);
    mpceps=mean(mpceps);
    
    [pmax,imax]=max(mpceps);
    mpceps1=mpceps([1:imax-1,imax+1:end]);
    d=(pmax-mean(mpceps1))/(std(mpceps1));
    
    if (d>dThresh)
        [foo,idx]=max(pceps([imax*2-1:imax*2]));
        imax=imax*2+idx-2;
        f0s=[f0s,sr/(imax+cepsPitchWin(1)-1)];  % Hz
    else
        f0s=[f0s,0];
    end
end

%% Pruning intervals

% %% Visualization
% [s,f,t]=spectrogram(sig,96,80,1024,sr);
% figure;
% imagesc(t,f,log10(abs(s)));
% hold on;
% axis xy;
% tt=((nStart+hLen*nFrame)/sr):(nFrame/sr):((nStart+hLen*nFrame)/sr)+(nFrame/sr)*(length(f0s)-1);
% plot(tt,f0s,'LineWidth',2);
% set(gca,'YLim',[0,3000]);
% return
% 
% function [radius,phi]=getRPhiBW(rts)
%     nLPC=length(rts);
%     wr=real(rts);   wi=imag(rts);
%     radius=[];
%     phi=[];
%     
%     for i0=1:nLPC
%         if (wi(i0)>0)
%             phi=[phi,atan2(wi(i0),wr(i0))];
%             radius=[radius,sqrt(wi(i0)*wi(i0)+wr(i0)*wr(i0))];
%         end
%     end
%     
%     [phi,idx]=sort(phi);
%     radius=radius(idx);
% return

