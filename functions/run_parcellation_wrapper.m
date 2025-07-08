function out = run_parcellation_wrapper(job)

input_files = job.input_files;
atlas = job.atlas;
V_atlas = spm_vol(atlas);
Y_atlas = spm_read_vols(V_atlas{1});
outdir = job.outdir{1};
prefix = job.prefix;
if isfield(job.filtering, "yes_branch")
    filtering = true;
    band = job.filtering.yes_branch.band;
end

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

for i = 1:length(input_files)
    % --- Load NIfTI volumes ---
    [~, name, ~] = fileparts(input_files{i});
    disp(['Starting parcellation of: ', name])
    V_fmri = spm_vol(input_files{i});
    TR = V_fmri(1).private.timing.tspace;
    
    % --- Read volumes ---
    Y_fmri = spm_read_vols(V_fmri);
    
    % --- Reshape fMRI to 2D: [voxels x time] ---
    [X, Y, Z, T] = size(Y_fmri);
    n_voxels = X * Y * Z;
    fmri_2d = reshape(Y_fmri, n_voxels, T);
    atlas_1d = reshape(Y_atlas, n_voxels, 1);
    
    % --- Find unique ROI labels ---
    roi_labels = unique(atlas_1d);
    roi_labels(roi_labels == 0) = [];
    n_rois = length(roi_labels);
    
    % --- Preallocate output ---
    time_series = zeros(T,n_rois);
    
    % --- Single loop over ROIs ---
    for r = 1:n_rois
        roi = roi_labels(r);
        mask = (atlas_1d == roi);
        time_series(:, r) = mean(fmri_2d(mask, :), 1);
    end
    if filtering
        time_series = bandpass(time_series,band,1/TR);
    end
    % Save output
    output_file = fullfile(outdir, [prefix '_' name '_time_series.mat']);
    save(output_file, 'time_series');

    % Store path in output struct (can be a cell array if multiple files)
    timeseries_files{i,1} = output_file;
    disp(['Finished parcellation of: ', name])
end
out.timeseries_files = timeseries_files;

end