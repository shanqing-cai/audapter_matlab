function phaseScript = genRandScript(nBlocks, trialsPerBlock, trialsPerBlock_lower, trialsPerBlock_higher, words)
phaseScript = struct();
phaseScript.nReps = nBlocks;
phaseScript.nTrials = 0;


if trialsPerBlock < length(words) * 3
    error('trialsPerBlock should be at least 3 * length(words) = 3 * %d = %d', ...
          length(words), 3 * length(words));
end

for n=1 : nBlocks
    wordsUsed = {};
    while (length(wordsUsed) < trialsPerBlock)
        nToGo = trialsPerBlock - length(wordsUsed);
        if (nToGo >= length(words))
            wordsUsed = [wordsUsed, words(randperm(length(words)))];
        elseif (nToGo > 0)
            idx = randperm(length(words));
            wordsUsed = [wordsUsed, words(randperm(nToGo))];
        end
    end
    
%     wordsUsed = wordsUsed(randperm(length(wordsUsed)));
    bt = zeros(1, length(wordsUsed));
    
%     pseudoWordsUsed=pseudoWords(randperm(length(pseudoWords)));
%             testWordsUsed2=testWords(randperm(length(testWords)));            
    twCnt=1;
    bt=bt(randperm(length(bt)));
    oneRep=struct;
    oneRep.trialOrder=[];
    oneRep.word=cell(1,0);
    cntTW=1;
    for m=1:length(bt)
        if (bt(m)==0)					
            oneRep.trialOrder=[oneRep.trialOrder,1];
            oneRep.word{length(oneRep.word)+1}=wordsUsed{twCnt};
            twCnt=twCnt+1;
        elseif (bt(m)==1)
            oneRep.trialOrder=[oneRep.trialOrder,[5,4,4]];
            oneRep.word{length(oneRep.word)+1}=pseudoWordsUsed(cntTW+1);
            oneRep.word{length(oneRep.word)+1}=pseudoWordsUsed(cntTW);
            oneRep.word{length(oneRep.word)+1}=pseudoWordsUsed(cntTW+1);
            cntTW=cntTW+2;
        end
    end

%     if (isequal(stage,'pract1') || isequal(stage,'pract2'))
%         idx=find(oneRep.trialOrder<4);
%         oneRep.trialOrder=oneRep.trialOrder(idx);
%         oneRep.word=oneRep.word(idx);
%     end

%     if n==nReps
%         oneRep.trialOrder=[oneRep.trialOrder,4];    % Dummy trial at the end
%         oneRep.word{length(oneRep.word)+1}=pseudoWordsUsed(1);
%     end
    oneRep.pertType = zeros(1, numel(oneRep.trialOrder));
    phaseScript.(['rep',num2str(n)])=oneRep;
    phaseScript.nTrials=phaseScript.nTrials+length(oneRep.trialOrder);
end

pertVec = [];
while (length(pertVec) < nBlocks)
    nToGo = nBlocks - length(pertVec);
    if (nToGo >= length(words))
        pertVec = [pertVec, [1 : length(words)]];
    elseif (nToGo > 0)
        idx = randperm(length(words));
        pertVec = [pertVec, idx(1 : nToGo)];
    end
end
pertVec = pertVec(randperm(numel(pertVec)));

for i1 = 1 : nBlocks
    t_word = words(pertVec(i1));
    idx_word = fsic(phaseScript.(['rep',num2str(i1)]).word, t_word);
    if length(idx_word) < 2
        error('length(idx_word) should be at least 2.')
    end
    
    bOkay = 0;
    iterCnt = 0;
    while bOkay == 0
        idx_perts = idx_word(randperm(length(idx_word)));
        if abs(idx_perts(1) - idx_perts(2)) > 2
            bOkay = 1;
        else
            pause(0);
        end
        
        iterCnt = iterCnt + 1;
        if iterCnt >= 10
            pause(0);
        end
    end
    phaseScript.(['rep',num2str(i1)]).pertType(idx_perts(1)) = -1;   % Lower
    phaseScript.(['rep',num2str(i1)]).pertType(idx_perts(2)) = 1;   % Higher
    
    
%     phaseScript.(['rep',num2str(i1)]).
end
return