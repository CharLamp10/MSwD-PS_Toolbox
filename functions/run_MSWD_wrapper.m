function out = run_MSWD_wrapper(job)

input_files = job.input_files;
Corr_th = job.Corr_th;
StD_th = job.StD_th;

[outdir, name, ~] = fileparts(input_files{1});
parts = split(name, '_');
prefix = parts{1};

for i = 1:length(input_files)
    input_file = input_files{i};
    [~, name, ~] = fileparts(input_file);
    parts = split(name, '_');
    parts = parts(2:end-2);
    name = strjoin(parts,'_');
    disp(['Starting decomposition of ', name])

    % --- Call the main MSWD function here ---
    imfs = run_MSWD_batch(input_file, Corr_th, StD_th);

    % Save output
    output_file = fullfile(outdir, [prefix '_' name '_imfs_CORRth', num2str(Corr_th), '_STDth', num2str(StD_th),'.mat']);
    save(output_file, 'imfs');

    % Store path in output struct (can be a cell array if multiple files)
    imfs_files{i,1} = output_file;
    disp(['Decomposition of ', name, ' completed, file saved'])
end

% Return the output file(s) for dependency linking
out.imfs_files = imfs_files;

end