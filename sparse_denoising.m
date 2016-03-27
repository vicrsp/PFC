function p_signal = sparse_denoising(D , signal, step_sz)

sz_atom = size(D,1);
% process each signal interval, given step_sz

N = length(signal);
X = zeros(sz_atom,(N/step_sz) - step_sz + 1);
idx_matrix = zeros(sz_atom,(N/step_sz) - step_sz + 1);

start_idx = 1;
end_idx = sz_atom;
iter = 1;

h1 = waitbar(0,'Sparse coding in progress...');
setappdata(h1,'canceling',0)

while end_idx <= N
    if getappdata(h1,'canceling')
        disp('Sparse coding cancelled');
        delete(h1);
        return;
    end
    X_i = wmpalg('OMP',signal(start_idx : end_idx)',D,'itermax',1);
    
    idx_matrix(:,iter) = (start_idx:1:end_idx)';
    X(:,iter) = X_i;
    
    
    start_idx = start_idx + step_sz;
    end_idx = start_idx + sz_atom - 1;
    iter = iter + 1;
    waitbar(iter/size(X,2),h1);
end
delete(h1);

disp('Finished sparse coding.');

h = waitbar(0,'Processing blocks. Please wait...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0)


p_signal = zeros(1,N);

tic
for idx = 1:N
    % Check for Cancel button press
    if getappdata(h,'canceling')
        disp('Blocks processing cancelled');
        delete(h);
        return;
    end
    
    %-- Como otimizar esse codigo? -- %
    i = idx_matrix == idx;
    
    p_signal(idx) = mean(X(i));
    %---------------------------------%
    waitbar(idx/N,h);
end

toc

delete(h);
plotDPsignal(signal,p_signal);

end