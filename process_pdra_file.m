function process_pdra_file(D_ksvd,file)

disp(strcat('Processing: ',file.name));

arq = fopen(file.name);

dados = fread(arq, inf, 'float32');

fclose (arq);
X = [];
h = 2^19;
i = 0;
X_i = [];
N = size(D_ksvd,1);
counter = 1;


while ((i * h + 1) < length(dados))
    dados_atual = dados((i+1) * h + 1 : (i+2) * h);

    X = [];
    for k=1:length(dados_atual)/N
        X_i = wmpalg('OMP',dados_atual(1+(k -1)*N : N*(k))',D_ksvd,'itermax',1);
        X = [X;X_i];
    end
    saveFile = strcat(file.name,sprintf('_part%d.mat',counter));

    save(saveFile,'X','dados_atual');
    disp(strcat('Saved file: ',saveFile));
    
    counter = counter + 1;
    i = i + 2;
end

end