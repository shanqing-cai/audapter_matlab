function sigcell = makecell(sig, block)
    sigcell = cell(1, floor(length(sig) / block));
    
    for n = 1 : length(sigcell)
        sigcell{n} = sig((n - 1) * block + 1 : n * block);
    end
return