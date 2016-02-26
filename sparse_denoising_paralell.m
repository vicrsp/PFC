function p_signal = sparse_denoising_paralell(D , signal, step_sz)

sz_atom = size(D,1);
K = size(D,2);

idx_matrix = [];%zeros(sz_atom, length(signal)/step_sz);

% process each signal interval, given step_sz
X = [];
start_idx = 1;
end_idx = sz_atom;
N = length(signal);

while end_idx <= N
    
    X_i = wmpalg('OMP',signal(start_idx : end_idx)',D,'itermax',1);
    idx_matrix = [idx_matrix  (start_idx:1:end_idx)'];
    X = [X X_i];
    
    
    start_idx = start_idx + step_sz;
    end_idx = start_idx + sz_atom - 1;
end

disp('Finished sparse decompostion.');

p_signal = zeros(1,N);

matlabpool('open',4);
tic
disp('Started processing the blocks');
parfor idx = 1:N
    %-- Como otimizar esse codigo? -- %
    i = idx_matrix == idx;
    
    p_signal(idx) = mean(X(i));
    %---------------------------------%
%     waitbar(idx/N,h);
end

disp('Finished processing blocks');
toc
matlabpool close;

plotDPsignal(signal,p_signal);

end