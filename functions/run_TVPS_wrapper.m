function out = run_TVPS_wrapper(job)

input_files = job.input_files;
save_tvps = job.save_tvps;
if isfield(job.estimate_states,"yes_branch")
    estimate_states = true;
    save_states = job.estimate_states.yes_branch.save_states;
    if isfield(job.estimate_states.yes_branch.k_param, "specify_branch")
        K = job.estimate_states.yes_branch.k_param.specify_branch.K;
    else
        K = "estimate";
    end

else
    estimate_states = false;
end

[outdir, name, ~] = fileparts(input_files{1});
parts = split(name, '_');
prefix = parts{1};

for i = 1:length(input_files)
    input_file = input_files{i};
    [~, name, ~] = fileparts(input_file);
    parts = split(name, '_');
    name = parts(2:end-3);
    if length(name) == 1
        name = name{1,1};
    else
        name = strjoin(name, '_');
    end
    names{i} = name;
    disp(['Starting TVPS of ', names{i}])
    parts = split(input_file, '_');
    for j = 1:length(parts)
        part = parts{j};
        if contains(part, "CORRth")
            Corr_th = part;
        elseif contains(part, "STDth")
            StD_th = part(1:end-4);
        end
    end
    data = load(input_file);
    cosdelphi = phase_sync_analysis(data.imfs);
    tvps{i} = cosdelphi;
    disp(['TVPS of ', names{i},' completed.']);
    % Save output
    output_file = fullfile(outdir, [prefix '_' name '_TVPS_', Corr_th, '_', StD_th, '.mat']);
    if save_tvps
        save(output_file, 'cosdelphi');
        tvps_files{i,1} = output_file;
    end
end

if estimate_states
    disp('Starting brain state estimation.')
    [state_succession,brain_states, K] = brain_state_estimation(tvps,K);
    disp('Brain state estimation completed')
end

if save_states == "Yes"
    output_file = fullfile(outdir, [prefix, '_brain_states_', Corr_th, '_', StD_th, '_K', num2str(K), '.mat']);
    save(output_file, 'brain_states','state_succession');
end

for i = 1:K
    figure;
    state = brain_states(i,:);
    state_new = eye(size(data.imfs,2), size(data.imfs,2));
    indx = nchoosek(1:size(data.imfs,2), 2);
    for n = 1:size(indx,1)
        state_new(indx(n,1), indx(n,2)) = state(n);
        state_new(indx(n,2), indx(n,1)) = state(n);
    end
    state_new = state_new(1:end-1, 1:end-1);
    state_new(1:size(state_new,1)+1:end) = 0;  % zero out diagonal

    gsplot(state_new);
    set(gca, 'XTick', [], 'YTick', [], 'CLim', [-1 1]);
    axis square;
    colorbar();
    output_file = fullfile(outdir, [prefix, '_brain_state', num2str(i),'_', Corr_th, '_', StD_th, '_K', num2str(K),'.png']);
    exportgraphics(gcf,output_file,'Resolution',600)
end

if exist("tvps_files")
    out.tvps = tvps_files;
else
    out.tvps = tvps;
end

end