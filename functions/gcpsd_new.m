function [S, f] = gcpsd_new(input,fs)
% -------------------------------------------------------------------------
%   GCPSD computes the Generalized Cross Power Spectral Density
% -------------------------------------------------------------------------

% Check for correct dimensions
if size(input, 1) < size(input, 2)
    input = input';
end

[len,NoC] = size(input);
fft_len = max(round(len/4 + 1), 2^7 + 1);
Px1 = pwelch(input,len,[],2*(fft_len-1) + 1);
Px2 = pwelch(input,round(len/2),[],2*(fft_len-1) + 1);
Px3 = pwelch(input,round(len/4),[],2*(fft_len-1) + 1);
Px4 = pwelch(input,round(len/6),[],2*(fft_len-1) + 1);
Px = Px1 + Px2 + Px3 + Px4;

for i = 1:size(Px,2)
    sigma(:,:,i) = Px(:,i).*Px;
end

sigma(:,eye(NoC)==1) = 1;
sigma = permute(sigma, [2 3 1]);
for i=1:fft_len
    lmax(i) = eigs(sigma(:, :, i), 1);
end
S = ((lmax - 1) ./ (NoC - 1)).^2;
f = linspace(0,fs/2,size(Px,1));
if size(S,1) < size(S,2)
    S = S';
end
end