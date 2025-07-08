function cfg = spm12_parcellate
% Define a batch module to run MSWD

input_files = cfg_files;
input_files.name = 'Input .nii file(s)';
input_files.tag = 'input_files';
input_files.filter = 'nii';     % Allow .mat and .nii files
input_files.num = [1 Inf];          % Allow one or more files
input_files.help = {'Select one or more .nii files containing 4D fMRI data.'};

atlas = cfg_files;
atlas.name = 'Input .nii atlas';
atlas.tag = 'atlas';
atlas.filter = 'nii';     % Allow .mat and .nii files
atlas.num = [1 1];          % Allow one or more files
atlas.help = {'Select an atlas (.nii) to parcellate the data and extract time-series.'};

% Output directory
outdir = cfg_files;
outdir.name = 'Output directory';
outdir.tag = 'outdir';
outdir.filter = 'dir';
outdir.num = [1 1];
outdir.help = {'Select a directory to save the results.'};

band = cfg_entry;
band.tag = 'band';
band.name = 'Frequency band for band-pass filtering';
band.strtype = 'r';
band.num = [1 2];
band.help    = {'Frequency limits for band-pass filtering'};

yes_branch = cfg_branch;
yes_branch.tag = 'yes_branch';
yes_branch.name = 'Yes';
yes_branch.val = {band};

% ---- Option when user selects "No" ----
no_branch = cfg_branch;
no_branch.tag = 'no_branch';
no_branch.name = 'No';
no_branch.val = {}; % No further options

% ---- Wrap the options in a cfg_choice ----
filtering = cfg_choice;
filtering.tag = 'filtering';
filtering.name = 'Band-pass filtering?';
filtering.values = {yes_branch, no_branch};
filtering.val = {yes_branch};  % default selection
filtering.help = {'Choose whether to apply band-pass filtering or not.'};


% Output file prefix
prefix = cfg_entry;
prefix.name = 'Filename prefix';
prefix.tag = 'prefix';
prefix.strtype = 's';  % string type
prefix.num = [1 Inf];  % 1 string (could be multiple words)
prefix.help    = {'Prefix to save results. Do not use underscores'};

% Main module branch
cfg = cfg_exbranch;
cfg.tag = 'parcellate_data';
cfg.name = 'Parcellate data';
cfg.val = {input_files, atlas, outdir, prefix, filtering};
cfg.prog = @run_parcellation_wrapper;
cfg.vout = @vout_parcellation;
cfg.help = {'Parcellate fMRI data.'};

end