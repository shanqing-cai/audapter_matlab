function splt=getSPLTarg(varargin)

if isempty(fsic(varargin,'perc'))
    if (isempty(varargin)) % Transition prod
        splt=76;        
    elseif nargin==1
        mouthMicDist=varargin{1};
        splt=76+20*log10(10/mouthMicDist);% assume the distance is x cm. it should be 75+20*log10(10/x)
    elseif nargin==2
        splTarg=varargin{1};
        mouthMicDist=varargin{2};
        splt=splTarg+20*log10(10/mouthMicDist);% assume the distance is x cm. it should be 75+20*log10(10/x)
    end
else
    splt=75;
end 
return