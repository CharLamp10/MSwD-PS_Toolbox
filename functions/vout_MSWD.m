function out = vout_MSWD(job)
    out = cfg_dep;
    out.sname = 'MSWD output file';
    out.src_output = substruct('.','imfs_files');
    out.tgt_spec = struct('filter','mat','strtype','e');
end