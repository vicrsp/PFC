%% Declaracao de constantes
clear all; close all;clc;

sinal1 = load('sinalTeste1.mat');
sinal2 = load('sinalTeste2.mat');
sinal3 = load('sinalTeste3.mat');
sinalIdeal = load('sinalTesteSemRuido.mat');

K = 2000;
fs = 4*2e6;
deltaT = 1/fs;

R0 = 2.7e3;
L0 = 6.7e-3;
C0 = 500e-12;
n = [0:512];
N = length(n);

% tamanho do atomo
sz_atom = 16;

% D_inicial = [];
numPulsos = 2^10;
% sinalLimpo = [];
sinalLimpo = zeros(1,numPulsos * 2*length(n));

%% Gerar os sinas de treino

ampDP = 2;             % Amplitude das descargas parciais

for i=1:numPulsos
    
    R = R0;
    L = L0;
    C = C0;
    if(i>1)
        R = R0*(1 + randn);
        L = L0*(1 + randn);
        C = C0*(1 + randn);
    end  
    
    if(R > 0 && C > 0 && L > 0)

        alpha = 1/(2*R*C);
        omega0 = 1/sqrt(L*C);

        s1 = -alpha + sqrt(alpha^2 - omega0^2);     % Raizes da equacao caracteristica
        s2 = -alpha - sqrt(alpha^2 - omega0^2);

        A1 = -ampDP/(s1-s2) * (1/(R*C) + s2);  % Condicoes iniciais
        A2 = ampDP - A1;


        nzeros = ceil(N*rand);
       
        DP =  (1 + 2*(rand()- 0.5)*25/100)* ampDP * (A1 * exp(s1 * n/fs) + A2 * exp(s2 * n/fs));
        temp1 = zeros(1, floor(N * rand()));  %Ajuste para garantir ausï¿½ncia de sobreposiï¿½ï¿½o
        temp2 = zeros(1, N-length(temp1));    %Idem
        sinalLimpo(1+(i*2*N):2*N*(i+1)) = [temp1 real(DP) temp2];
%         sinalLimpo = [sinalLimpo temp1 real(DP) temp2];
    end
    sinalTreino = sinalLimpo + 0.0001 * max(sinalLimpo) * randn(1 ,length(sinalLimpo));

end
%% Obtem os sinais de DP para o treinamento do dicionario
D_treino = [];

N = sz_atom;
for i=1:size(sinalTreino,2)/N
    D_treino = [D_treino  sinalTreino(1,N*(i-1)+1:(N*i))'];
end


%% Treinar o dicionário
disp('Started training dictionary');

% param.K = size(D_treino,2);
param.K = 512 - 128;
param.errorFlag = 0;
param.L = 5;
param.numIteration = 5;
param.displayProgress = 1;
param.preserveDCAtom = 0;
param.InitializationMethod = 'DataElements';

% param.InitializationMethod = 'GivenMatrix';
% param.initialDictionary = wmpdictionary(256);
% param.initialDictionary = wmpdictionary(256,'lstcpt',{{'sym4',5},{'db4',4}...
%     {'db4',3},{'db4',2},{'db4',1},{'sym4',4},{'sym4',3}
%     });
% 
% param.K = size(param.initialDictionary,2);

[D_ksvd out] = KSVD(D_treino,param);
%[D_ksvd out] = MOD(D_inicial,param);
disp('Finished training dictionary');

%% Codificação esparsa
close all;
X = [];
%r = [];
%sinal_norm = sinal*diag(1./sqrt(sum(sinal.*sinal)));
%sinal_norm = sinal_norm.*repmat(sign(sinal_norm(1,:)),size(sinal_norm,1),1);
sinalTeste = sinal1.sinal;


for i=1:size(sinalTeste,2)/N

%alfa = OMP(D_ksvd,sinalTeste(1+(i-1)*N : N*(i))',2);
X_i = wmpalg('OMP',sinalTeste(1+(i-1)*N : N*(i))',D_treino,'itermax',1);
%alfa = SolveBP(D_ksvd,sinalTeste(1+(i-1)*N : N*(i))',length(D_ksvd));
%r = [r corr2(D_ksvd , repmat((D_ksvd*alfa),1,1000))];
%X = [X ; D_ksvd*alfa];
X = [X;X_i];

end
% plot(dados(1:N*10));hold on
vetTempos = [0:length(X)-1] * deltaT;

figure;
plot(vetTempos,sinalIdeal.sinal); hold on;
plot(vetTempos,X ,'r')

figure;
plot(vetTempos,sinalTeste); hold on;
plot(vetTempos,X,'r')

 err = mean((X - sinalIdeal.sinal').^2)
 err2 = mean((X - sinalTeste').^2)

 %% Teste com sinais reais de DP
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile ('*.pdra', 'Escolha o arquivo');

if (~FILENAME)
    return;
end

arq = fopen(FILENAME);

dados = fread(arq, inf, 'float32');


fclose (arq);
X = [];
h = 2^19;
i = 0;
X_i = 0;

while ((i * h + 1) < length(dados))
    dados_atual = dados((i+1) * h + 1 : (i+2) * h);
    %dados_atual = dados_atual(1:8:end);
    X = [];
    for k=1:length(dados_atual)/N
        %alfa = OMP(D_ksvd,sinalTeste(1+(i-1)*N : N*(i))',2);
        X_i = wmpalg('BMP',dados_atual(1+(k -1)*N : N*(k))',D_ksvd,'itermax',1);
        %alfa = SolveBP(D_ksvd,sinalTeste(1+(i-1)*N : N*(i))',length(D_ksvd));
        %r = [r corr2(D_ksvd , repmat((D_ksvd*alfa),1,1000))];
        %X = [X ; D_ksvd*alfa];
        X = [X;X_i];
    end
    
    t = [0:length(X_i)-1] * deltaT;
    %plot(dados_atual - mean(dados_atual)); hold on;
    plot(dados_atual); hold on;
    plot(X ,'r')
        
    i = i + 2;
    input('Digite uma tecla...');close all;
end




