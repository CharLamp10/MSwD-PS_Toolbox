function out = run_reconstruction_wrapper(job)

input_files = job.input_files;
lambda = job.lambda;

[outdir, name, ~] = fileparts(input_files{1});
parts = split(name, '_');
prefix = parts{1};

for i = 1:length(input_files)
    input_file = input_files{i};
    parts = split(input_file, '_');
    for j = 1:length(parts)
        part = parts{j};
        if contains(part, "CORRth")
            Corr_th = part;
        elseif contains(part, "STDth")
            StD_th = part(1:end-4);
        end
    end
    [~, name, ~] = fileparts(input_file);
    parts = split(name, '_');
    parts = parts(2:end-3);
    name = strjoin(parts,'_');
    data = load(input_file);
    imfs = data.imfs;
    disp(['Starting reconstruction of ', name])
    glob = sum(imfs(:,:,1:end-1),3);
    local = imfs(:,:,end);
    rec = glob.*lambda + local;
    corr = corrcoef(rec);
    output_file = fullfile(outdir, [prefix '_' name '_rec_', Corr_th, '_', StD_th, '_lambda', num2str(lambda), '.mat']);
    save(output_file, 'corr','rec');
    rec_files{i,1} = output_file;
    disp(['Reconstruction of ', name, ' completed and output saved'])
end
out.rec_files = rec_files;

end