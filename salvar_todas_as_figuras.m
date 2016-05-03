load('processadoHarmonico.mat')
plotDPsignal(sinal,X,'sinalSimuladoRuidoHarmonico');
pause(5);
load('processadoGaussiano.mat')
plotDPsignal(sinal,X,'sinalSimuladoRuidoGaussiano');
pause(5);
load('processadoPulsante.mat')
plotDPsignal(sinal,X,'sinalSimuladoRuidoPulsante');
pause(5);
load('dados14_DPsEmSolido_RuidoCentelhador.pdra_part3.mat')
plotDPsignal(dados_atual,X,'dados14_DPsEmSolido_RuidoCentelhador');
pause(5);
load('dados12_DPsEmAr_RuidoAM_tipo2.pdra_part1.mat')
plotDPsignal(dados_atual,X,'dados12_DPsEmAr_RuidoAM_tipo2');
pause(5);
load('dados06_DPsEmSolido_RuidoAM_tipo1.pdra_part1.mat')
plotDPsignal(dados_atual,X,'dados06_DPsEmSolido_RuidoAM_tipo1');
pause(5);

close all