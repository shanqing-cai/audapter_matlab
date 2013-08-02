% function phaseScript = genPhaseScript(stage, nReps, preWords, trainWords, testWords, varargin)
function phaseScript = genPhaseScript(stage, nReps, words, varargin)
phaseScript=struct();


if ~isempty(fsic(varargin, 'noiseRepsRatio'))
    noiseRepsRatio = varargin{fsic(varargin, 'noiseRepsRatio') + 1};
    if mod(nReps * noiseRepsRatio, 1.0) ~= 0.0
        error('%s: nReps * noiseRepsRatio = %f is not an integer', ...
              stage, nReps * noiseRepsRatio);
    end
    if mod(1 / noiseRepsRatio, 1) ~= 0.0
        error('%s: 1 / noiseRepsRatio = %f is not an integer', ...
               stage, 1 / noiseRepsRatio);
    end
    
    isRepNoise = repmat([zeros(1, 1 / noiseRepsRatio), 1], 1, nReps * noiseRepsRatio);    
    nReps = nReps + nReps * noiseRepsRatio;
else
    isRepNoise = zeros(1, nReps);
end

phaseScript.nReps=nReps;
phaseScript.nTrials=0;

for n = 1 : nReps
%     bt=[zeros(1,length(trainWords)),ones(1,round(length(trainWords)/2))];
%     if isequal(stage,'natural')
%         wordsUsed=varargin{1};
%         bt=[zeros(1,length(preWords))];
%     if isequal(stage,'pre')
%         wordsUsed=preWords(randperm(length(preWords)));
%         bt=[zeros(1,length(preWords))];
%     elseif isequal(stage,'test1') || isequal(stage,'test2')
%         wordsUsed=testWords(randperm(length(testWords)));
%         bt=[zeros(1,length(testWords))];
%     else
%         wordsUsed=trainWords(randperm(length(trainWords)));
%         bt=[zeros(1,length(trainWords))];
%     end
    wordsUsed = words(randperm(length(words)));
    bt = zeros(1, length(words));
    
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
            if ~isRepNoise(n)
                oneRep.trialOrder=[oneRep.trialOrder, 1];
            else
                oneRep.trialOrder=[oneRep.trialOrder, 2];
            end
                
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

    if (isequal(stage,'pract1') || isequal(stage,'pract2'))
        idx = find(oneRep.trialOrder<4);
        oneRep.trialOrder = oneRep.trialOrder(idx);
        oneRep.word = oneRep.word(idx);
    end

%     if n==nReps
%         oneRep.trialOrder=[oneRep.trialOrder,4];    % Dummy trial at the end
%         oneRep.word{length(oneRep.word)+1}=pseudoWordsUsed(1);
%     end
    phaseScript.(['rep',num2str(n)])=oneRep;
    phaseScript.nTrials=phaseScript.nTrials+length(oneRep.trialOrder);
end
return