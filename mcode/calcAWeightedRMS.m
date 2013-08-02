function awrms=calcAWeightedRMS(x,fs)
    len=length(x);
    f=0:(fs/len):(fs/len*(len-1));
    f=f(1:floor(len/2));    f=f';
    X=abs(fft(x));
    X=X(1:floor(len/2));
	if (size(f,1)>size(f,2))
		f=f';
	end
	if (size(X,1)>size(X,2))
		X=X';
	end
    X=weightA(f).*X;
    awrms=sqrt(mean(X.^2)/len);
return

