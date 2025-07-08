function imfs = run_MSWD_batch(input_file, Corr_th, StD_th)

data = load(input_file);
signal = data.time_series;
if size(signal,2) < size(signal,1)
    param_struct  = struct('Corr_th',   Corr_th,...
                           'StD_th',       StD_th, ...
                           'p_value',      1e-5);
    imfs = MSWD(signal, param_struct);
else
    error('Number of time points must be more than number of regions')
end

end