function out = vout_parcellation(job)
    out = cfg_dep;
    out.sname = 'Parcellation output file';
    out.src_output = substruct('.','timeseries_files');
    out.tgt_spec = struct('filter','mat','strtype','e');
end