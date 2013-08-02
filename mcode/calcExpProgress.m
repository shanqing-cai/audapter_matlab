function [rProgress, nTrialsPast, nTotTrials] = calcExpProgress(experiment,thisphase,thisrep,thisword,rProgress0)
	stages=experiment.allPhases;
    nReps=nan(1,length(stages));
    
    for k=1:length(stages)
        nReps(k)=experiment.script.(stages{k}).nReps;
    end
    nTrials=nan(1,sum(nReps));
    
    k=1;
    for n=1:length(stages)
        for m=1:nReps(n)
            nTrials(k)=length(experiment.script.(stages{n}).(['rep',num2str(m)]).trialOrder);
            k=k+1;
        end
    end
    
    idxstage=findStringInCell(stages,thisphase);
    if (isempty(idxstage))
        rProgress=rProgress0;
        return
    end
    
%     nPast=sum(nTrials(1:idxstage-1))*nWords;
    nRepsPast=sum(nReps(1:idxstage-1));   
    nRepsPast=nRepsPast+thisrep-1;       % The number of completed reps so fast
    
    nTrialsPast=sum(nTrials(1:nRepsPast))+thisword;
    
    nTotTrials = sum(nTrials);
    rProgress = nTrialsPast / nTotTrials;        
return