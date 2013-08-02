function [i1,i2,f1,f2,iv1,iv2,bPossibleMultiProd]=getFmtPlotBounds(fmt1,fmt2)
    istart=[];  iend=[];
    state=0;
    for n=1:length(fmt1)
        if (state==0)
            if (fmt1(n)>0)
                state=1;
                istart=[istart,n];
            end
        else    % state==1
            if (fmt1(n)==0)
                state=0;
                iend=[iend,n];
            end
        end
    end
    
    iend=iend-1;
    nseg=min([length(istart),length(iend)]);
    istart=istart(1:nseg);
    iend=iend(1:nseg);
    lengths=iend-istart;
    [dur,imax]=max(lengths);
    
    i1=max([istart(imax)-round(dur*0.1),1]);
    i2=min([iend(imax)+round(dur*0.1),length(fmt1)]);
    
    iv1=istart(imax);
    iv2=iend(imax);
    
    f1=fmt1(istart(imax):iend(imax));
    f2=fmt2(istart(imax):iend(imax));
    
    bPossibleMultiProd = 0;
    if numel(lengths) >= 2
        lengths = sort(lengths);
        if lengths(end - 1) > 0.5 * lengths(end) && lengths(end) > 0
            bPossibleMultiProd = 1;
        end        
    end
return