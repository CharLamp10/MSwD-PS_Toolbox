function [mean_idx,mean_C, K] = brain_state_estimation(tvps,K)

for i = 1:length(tvps)
    if i == 1
        TVPS = tvps{i};
    else
        TVPS = cat(1,TVPS,tvps{i});
    end
end

if isstring(K) && K == "estimate"
    E = evalclusters(squeeze(TVPS),'kmeans','silhouette','klist',[2:7]);
    K = E.OptimalK;
end

[~,C_init,~] = kmeans(squeeze(TVPS),K,'MaxIter',150,'Start','sample','Replicates',10); % replicates default 200, MaxIter 150, replicates 10
[mean_idx,mean_C] = kmeans(squeeze(TVPS),K,'MaxIter',500,'Start',C_init); %1000 default

end