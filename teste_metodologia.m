%% 1 - gerar os sinas de treino
close all;clc;

% Cria dicionario inicial 500x2000
K = 5000;
fs = 2e6;

R0 = 2.7e3;
L0 = 6.7e-3;
C0 = 500e-12;
n = [0:255];
N = 512;

D_inicial = [];

for i=1:K
    
    R = R0*(1 + sign(randn)*rand);
    L = L0*(1 + sign(randn)*rand);
    C = C0*(1 + sign(randn)*rand);
    
    if(L*C >= 4*(R^2)*(C^2))
        ampDP = (1 + 2*(rand()- 0.4)*25/100);              % Amplitude das descargas parciais

        alpha = 1/(2*R*C);
        omega0 = 1/sqrt(L*C);

        s1 = -alpha + sqrt(alpha^2 - omega0^2);     % Raizes da equacao caracteristica
        s2 = -alpha - sqrt(alpha^2 - omega0^2);

        A1 = -ampDP/(s1-s2) * (1/(R*C) + s2);  % Condicoes iniciais
        A2 = ampDP - A1;

        nzeros = ceil(255*rand);
        %Gera��o do pulso de descarga parcial (resposta ao impulso da rede RLC)
        % DP = awgn([zeros(1,nzeros) ampDP * (A1 * exp(s1 * n/fs) + A2 * exp(s2 * n/fs)) zeros(1, 25 - nzeros)],35,'measured');
        DP = [zeros(1,nzeros) ampDP * (A1 * exp(s1 * n/fs) + A2 * exp(s2 * n/fs))];
        
        D_inicial = [D_inicial DP(1:255)'];
    end
    
    

end


% ampDP = 1;              % Amplitude das descargas parciais
%     
% alpha = 1/(2*R*C);
% omega0 = 1/sqrt(L*C);
% 
% s1 = -alpha + sqrt(alpha^2 - omega0^2);     % Raizes da equacao caracteristica
% s2 = -alpha - sqrt(alpha^2 - omega0^2);
% 
% A1 = -ampDP/(s1-s2) * (1/(R*C) + s2);  % Condicoes iniciais
% A2 = ampDP - A1;
% 
% %Gera��o do pulso de descarga parcial (resposta ao impulso da rede RLC)
% DP = [zeros(1,50) ampDP * (A1 * exp(s1 * n/fs) + A2 * exp(s2 * n/fs))];
% 
% % plot(DP); figure;
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Geracao do trem de pulsos de DPs
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% numPulsos = 2^13; 
% txVariacao = 25;        %Taxa de variacao da amplitude das DPs em %
% sinalLimpo = zeros(1,numPulsos * 2*length(n));
% 
% rand('state',sum(100*clock));
% 
% for i=1:numPulsos-2 %Obs.: decidi remover 2 pulsos para garantir uma folga nas bordas do sinal
%     temp1 = zeros(1, floor(128 * rand()));  %Ajuste para garantir aus�ncia de sobreposi��o
%     temp2 = zeros(1, 128-length(temp1));    %Idem
%     DP = (1 + 2*(rand()-0.5) * txVariacao/100) * ampDP * (A1 * exp(s1 * n/fs) + A2 * exp(s2 * n/fs));
%     sinalLimpo(1+(i*256):256*(i+1)) = [temp2 DP temp1];
% end
%     
% plot(sinalLimpo);
% %Adi��o de ruido de fundo com base na maior DP.
% %sinalLimpo = sinalLimpo + 0.002 * max(sinalLimpo) * randn(1 ,length(sinalLimpo));
% 
% D_inicial = zeros(N,size(sinalLimpo,2)/N);
% j = 1;
% for i=1:N:size(sinalLimpo,2)
%     D_inicial(:,j) = sinalLimpo(i:N+i-1)';
%     j=j+1;
% end
  
%% Aprender o dicionario usando o K-SVD
param.K = 1000;
param.errorFlag = 0;
param.L = 10;
param.numIteration = 5;
param.displayProgress = 1;
%param.preserveDCAtom = 1;
param.InitializationMethod = 'DataElements';

%param.InitializationMethod = 'GivenMatrix';
%param.initialDictionary = wmpdictionary(255);
%param.initialDictionary = wmpdictionary(255,'lstcpt',{{'sym4',5},{'sym4',4}...
   % {'sym4',2},{'sym4',3},{'sym4',1}
   % });

%param.K = size(param.initialDictionary,2);
[D_ksvd out] = KSVD(D_inicial,param);
%[D_ksvd out] = MOD(D_inicial,param);

figure; plot(out.totalerr);

%% Calcular a codificacao esparsa de sinais de teste

X = [];
r = [];
%sinal_norm = sinal*diag(1./sqrt(sum(sinal.*sinal)));
%sinal_norm = sinal_norm.*repmat(sign(sinal_norm(1,:)),size(sinal_norm,1),1);
for i=1:1:32

alfa = OMP(D_ksvd,sinal(1+(i-1)*255 : 255*(i))',1);
%alfa = SolveBP(D_ksvd,sinal(1+(i-1)*255 : 255*(i))',1000);
%r = [r corr2(D_ksvd , repmat((D_ksvd*alfa),1,1000))];

X = [X ; D_ksvd*alfa];


end
%plot(dados(1:512*10));hold on
figure;
plot(sinalLimpo.sinal(1:32*255)); hold on;
plot(X,'r')

