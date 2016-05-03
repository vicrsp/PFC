close all; clear all;clc;

% Construct a questdlg with three options
choice = questdlg('Would you like to load a dicitionary?', ...
    'Sparse Denoising', ...
    'Yes','No','Cancel','Cancel');
% Handle response
switch choice
    case 'Yes'
        [FILENAME, PATHNAME, FILTERINDEX] = uigetfile ('*.mat', 'Escolha o arquivo');
        
        if (~FILENAME)
            return;
        else
            cd(PATHNAME);
            load(FILENAME);
        end
        
        disp('Dictionary succesfully loaded!')
    case 'No'
        % Build the initial dictionary
        
        paramsI.numPulsos = 2^13;
        paramsI.sz_atom = 1024;
        paramsI.fs = 40e6; %Hz
        paramsI.Nsamples = 4*1024; % 1024 samples
        paramsI.ampDP = 2;
        
        D_treino = build_training_dictionary(paramsI);
        
        % Train the dictionary
        
        paramsT.errorFlag = 0;
        paramsT.L = 5;
        paramsT.numIteration = 1;
        paramsT.displayProgress = 1;
        paramsT.preserveDCAtom = 0;
        paramsT.InitializationMethod = 'GivenMatrix';
        paramsT.load = 1; % to load or not a previously saved dictionary
        
        D_ksvd = train_dictionary(D_treino, paramsT);
    case 'Cancel'
        disp('Cancelling...')
        return;
       
end
%% iterate thorugh all files and save the sparse denoise result in files
cd('C:\Users\Victor\Desktop\UFMG\PFC\BaseDeDados\Medidos\Processar')
files = dir('*.pdra');

outDir = 'C:\Users\Victor\Documents\PFC\Sinais Processados';
cd(outDir);


newDir = sprintf('%d-%d-%d_%d-%d-%d',fix(clock)); 
mkdir(newDir);
cd(newDir);

for file = files'
    process_pdra_file(D_ksvd,file);
end

% Save the dictionary, for future reference
save('Dictionary','D_ksvd');
disp('Dictionary saved!');

%% plot results
clear all;clc;
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile ('*.mat', 'Escolha o arquivo');

if (~FILENAME)
    return;
end

cd(PATHNAME);
load(FILENAME)

%plotDPsignal(dados_atual,X);

