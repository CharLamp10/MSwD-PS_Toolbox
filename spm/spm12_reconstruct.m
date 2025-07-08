function cfg = spm12_reconstruct

input_files = cfg_files;
input_files.name = 'Input .mat file(s)';
input_files.tag = 'input_files';
input_files.filter = 'mat';     % Allow .mat and .nii files
input_files.num = [1 Inf];          % Allow one or more files
input_files.help = {'Select one or more .mat files containing the data or click the Dependency button if the "Run MSWD" module is in the current batch.'};

lambda = cfg_entry;
lambda.name = 'Reconstruction factor';
lambda.tag  = 'lambda';
lambda.strtype = 'r';
lambda.num = [1 1];
lambda.help = {'Weight of global components for reconstruction of the fMRI time-series (default: 0.5).'};

% Exbranch (executable part)
e = cfg_exbranch;
e.name = 'Reconstruction';
e.tag = 'reconstruction';
e.val  = {input_files, lambda};
e.prog = @run_reconstruction_wrapper;
e.help = {'Performs reconstruction of the fMRI data using different weigths for the local and global components of MSWD.'};

cfg = e;

end
