function COSDELPHI = phase_sync_analysis(imf)

indx = nchoosek(1:size(imf,2),2);
COSDELPHI = nan(size(imf,1),size(indx,1));

pos_comp = 1;

for j = 1:size(indx,1)
    data = [imf(:,indx(j,1),pos_comp),imf(:,indx(j,2),pos_comp)];
    H = hilbert(data);
    sigphase = angle(H);
    DELPHI = sigphase(:,1)-sigphase(:,2);
    COSDELPHI(:,j) = cos(DELPHI);
end

end