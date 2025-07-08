function cfg = spm12_tvps

input_files = cfg_files;
input_files.name = 'Input .mat file(s)';
input_files.tag = 'input_files';
input_files.filter = 'mat';     % Allow .mat and .nii files
input_files.num = [1 Inf];          % Allow one or more files
input_files.help = {'Select one or more .mat files containing the data or click the Dependency button if the "Run MSWD" module is in the current batch.'};

save_tvps = cfg_menu;
save_tvps.name = 'Save TVPS results?';
save_tvps.tag  = 'save_tvps';
save_tvps.labels = {'Yes', 'No'};
save_tvps.values = {'Yes', 'No'};
save_tvps.val = {'Yes'};  % default selection
save_tvps.help = {'Select whether to save TVPS results or not.'};

K = cfg_entry;
K.name = 'Number of states';
K.tag = 'K';
K.strtype = 'r';
K.num = [1 1];
K.help    = {'Number of brain states.'};

save_states = cfg_menu;
save_states.tag = 'save_states';
save_states.name = 'Save estimated brain states?';
save_states.labels = {'Yes', 'No'};
save_states.values = {'Yes', 'No'};
save_states.val = {'Yes'};  % default
save_states.help = {'Choose whether to save the estimated brain states to file.'};

specify_branch = cfg_branch;
specify_branch.tag = 'specify_branch';
specify_branch.name = 'Specify';
specify_branch.val = {K};
specify_branch.help = {'Number of states should be an integer (typically within [2,7]).'};

% ---- Option when user selects "No" ----
estimate_branch = cfg_branch;
estimate_branch.tag = 'no_branch';
estimate_branch.name = 'Estimate based on silhouette';
estimate_branch.val = {}; % No further options

% ---- Option when user selects "Yes" ----
k_param = cfg_choice;
k_param.tag = 'k_param';
k_param.name = 'Number of brain states';
k_param.values = {specify_branch, estimate_branch};
k_param.val = {estimate_branch};
k_param.help = {'Choose how to set the number of brain states. If "Specify" then you will be asked to manually select the number of states.'};

yes_branch = cfg_branch;
yes_branch.tag = 'yes_branch';
yes_branch.name = 'Yes';
yes_branch.val = {k_param, save_states};

% ---- Option when user selects "No" ----
no_branch = cfg_branch;
no_branch.tag = 'no_branch';
no_branch.name = 'No';
no_branch.val = {}; % No further options

% ---- Wrap the options in a cfg_choice ----
estimate_states = cfg_choice;
estimate_states.tag = 'estimate_states';
estimate_states.name = 'Estimate brain states?';
estimate_states.values = {yes_branch, no_branch};
estimate_states.val = {yes_branch};  % default selection
estimate_states.help = {'Choose whether to estimate brain states. Selecting "Yes" will prompt further options.'};


% Exbranch (executable part)
e = cfg_exbranch;
e.name = 'TVPS Analysis';
e.tag = 'tvps_analysis';
e.val  = {input_files, save_tvps, estimate_states};
e.prog = @run_TVPS_wrapper;
e.help = {'Performs TVPS using MSWD output.'};

cfg = e;

end
