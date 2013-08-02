function saveExperiment(dirname)
load(fullfile(dirname,'expt.mat'));
save(fullfile(dirname,'expt.mat'),'expt');