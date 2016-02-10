%% Gerar os sinas de treino
clear all; close all;clc;

sinal1 = load('sinalTeste1.mat');
sinal2 = load('sinalTeste2.mat');
sinal3 = load('sinalTeste3.mat');
sinalIdeal = load('sinalTesteSemRuido.mat');


ampDP = 1;              %Amplitude das descargas parciais
R = 2.7e3;
L = 6.7e-3;
C = 500e-12;
fs = 2e6;          %Frequï¿½ncia de amostragem
deltaT = 1/fs;
n = [0:511];
N = size(n,2);

alpha = 1/(2*R*C);
omega0 = 1/sqrt(L*C);

s1 = -alpha + sqrt(alpha^2 - omega0^2);     %Raï¿½zes da equaï¿½ï¿½o caracterï¿½stica
s2 = -alpha - sqrt(alpha^2 - omega0^2);

A1 = -ampDP/(s1-s2) * (1/(R*C) + s2);  %Condiï¿½ï¿½es iniciais
A2 = ampDP - A1;

DP = [zeros(1,50) ampDP * (A1 * exp(s1 * n/fs) + A2 * exp(s2 * n/fs))];

numPulsos = 2^10; 
txVariacao = 25;        %Taxa de variaï¿½ï¿½o da amplitude das DPs em %
sinalLimpo = zeros(1,numPulsos * 2*length(n));

rand('state',sum(100*clock));

%for i=0:numPulsos-1
for i=1:numPulsos-2 %Obs.: decidi remover 2 pulsos para garantir uma folga nas bordas do sinal
    temp1 = zeros(1, floor(N * rand()));  %Ajuste para garantir ausï¿½ncia de sobreposiï¿½ï¿½o
    temp2 = zeros(1, N-length(temp1));    %Idem
    DP = (1 + 2*(rand()-0.5) * txVariacao/100) * ampDP * (A1 * exp(s1 * n/fs) + A2 * exp(s2 * n/fs));
    sinalLimpo(1+(i*2*N):2*N*(i+1)) = [temp1 DP temp2];
end

%Adição de ruido de fundo com base na maior DP.
sinalTreino = sinalLimpo + 0.004 * max(sinalLimpo) * randn(1 ,length(sinalLimpo));
vetTempos = [0:length(sinalTreino)-1] * deltaT;

% sinalTreino = load('sinalTreino_10xmenosruido');
% sinalTreino = sinalTreino.sinalTreino;
% vetTempos = [0:length(sinalTreino)-1] * deltaT;

%plot(vetTempos,sinalTreino)
%% Obtem os sinais de DP para o treinamento do dicionario
% 17/01: inicialmente desconsiderando sobreposicaao dos sinais
D_treino = [];

% Nomalizar o sinal de treino antes de montar o dicionario inicial
% sinalTreino = sinalTreino*diag(1./sqrt(sum(sinalTreino.*sinalTreino)));
%sinalTreino = sinalTreino.*repmat(sign(sinalTreino(1,:)),size(sinalTreino,1),1);
%plot(vetTempos,sinalTreino)

for i=1:size(sinalTreino,2)/N
    D_treino = [D_treino  sinalTreino(1,N*(i-1)+1:(N*i))'];
end


%% Treinar o dicionário
disp('Started training dictionary');

param.K = size(D_treino,2);
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
X = [];
%r = [];
%sinal_norm = sinal*diag(1./sqrt(sum(sinal.*sinal)));
%sinal_norm = sinal_norm.*repmat(sign(sinal_norm(1,:)),size(sinal_norm,1),1);
sinalTeste = sinal3.sinal;

for i=1:size(sinalTeste,2)/N

%alfa = OMP(D_ksvd,sinalTeste(1+(i-1)*N : N*(i))',2);
X_i = wmpalg('BMP',sinalTeste(1+(i-1)*N : N*(i))',D_treino,'itermax',1);
%alfa = SolveBP(D_ksvd,sinalTeste(1+(i-1)*N : N*(i))',length(D_ksvd));
%r = [r corr2(D_ksvd , repmat((D_ksvd*alfa),1,1000))];
%X = [X ; D_ksvd*alfa];
X = [X;X_i];

end
%plot(dados(1:512*10));hold on
vetTempos = [0:length(sinalTeste)-1] * deltaT;

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
    dados_atual = dados_atual(1:8:end);
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
    plot(dados_atual - mean(dados_atual)); hold on;
    plot(X ,'r')
        
    i = i + 2;
    input('Digite uma tecla...');
end




