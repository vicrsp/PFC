%% Filtro analógico passa-baixas
% Butterworth
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile ('*.mat', 'Escolha o sinal');

if (~FILENAME)
    return;
else
    cd(PATHNAME);
    load(FILENAME);
end

fs = 25e6;
order = 3;
fc = (0.5/pi);
[b,a] = butter(order,fc,'low');
sinal_filt = filter(b,a,dados_atual);

plotDPsignal(dados_atual,sinal_filt);
%% FFT
clear all; close all; clc
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile ('*.mat', 'Escolha o sinal');

if (~FILENAME)
    return;
else
    cd(PATHNAME);
    load(FILENAME);
end
fs = 25e6;
ft = fftshift((fft(dados_atual)));
w = [(-length(ft)/2):1:(length(ft)/2)-1]*(fs)/length(ft);
plot(w,abs(ft))

% usar a media para eliminar os coeficientes
m = mean(ft);
ft(ft < m) = 0;
hold on
plot(w,abs(ft),'r')

% calcular a ft inversa
sinal_filt = fftshift(ifft(ft));

plotDPsignal(dados_atual,sinal_filt);
