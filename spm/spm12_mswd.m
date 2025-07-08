function cfg = spm12_mswd
% Define a batch module to run MSWD

input_files = cfg_files;
input_files.name = 'Input .mat file(s)';
input_files.tag = 'input_files';
input_files.filter = 'mat';     % Allow .mat and .nii files
input_files.num = [1 Inf];          % Allow one or more files
input_files.help = {'Select one or more .mat files containing the data or click the Dependency button if the "Parcellate data" module is in the current batch.'};

Corr_th = cfg_entry;
Corr_th.name = 'Correlation threshold';
Corr_th.tag = 'Corr_th';
Corr_th.strtype = 'r';
Corr_th.num = [1 1];
Corr_th.help    = {'Threshold to terminate the algorithm (default: 0.02).'};

StD_th = cfg_entry;
StD_th.name = 'Component standard deviation';
StD_th.tag = 'StD_th';
StD_th.strtype = 'r';
StD_th.num = [1 1];
StD_th.help    = {'Component std value (default: 0.05).'};


% Main module branch
cfg = cfg_exbranch;
cfg.tag = 'run_MSWD';
cfg.name = 'Run MSWD';
cfg.val = {input_files, Corr_th, StD_th};
cfg.prog = @run_MSWD_wrapper;
cfg.vout = @vout_MSWD;
cfg.help = {'Run Multivariate Swarm Decomposition.'};

end