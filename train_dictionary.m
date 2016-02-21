function [D_ksvd, out] = train_dictionary(D_treino, params)

if (strcmp(params.InitializationMethod,'GivenMatrix'))
    params.initialDictionary = wmpdictionary(sz_atom,'lstcpt',{{'db4',4}...
        {'db4',3},{'db4',2},{'db4',1},...
        {'db6',1},{'db6',2},{'db6',3}...
        %     {'db2',1},{'db2',2},{'db2',3},... {'sym1',1},... {'sym2',1}...
        });
else
    params.initialDictionary = D_treino;
end

params.K = size(params.initialDictionary,2);

% Train the dictionary using K-SVD algorithm
disp('Started training dictionary');
[D_ksvd, out] = KSVD(D_treino,params);
disp('Finished training dictionary');


end