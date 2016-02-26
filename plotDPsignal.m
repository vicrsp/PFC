function plotDPsignal(measured, processed,text)
    
   % close all;
    fs = 20e6;%Hz
    
    deltaT = 1/fs;
    t = [0:length(processed)-1] * deltaT;
    
    figure;
    plot(t,measured,'b'); hold on;
    plot(t,processed,'r');
    axis([t(1) t(end) min(measured) max(measured)]);
    title('Comparação entre sinal medido e processado');
    legend('Medido','Processado');
    xlabel('Tempo (s)');ylabel('Amplitude (V)');

    grid on;
    
    figure;
    subplot(2,1,1)
    plot(t,measured,'b');
    title('Sinal medido');
    xlabel('Tempo (s)');ylabel('Amplitude (V)');
    axis([t(1) t(end) min(measured) max(measured)]);
    grid on;

    subplot(2,1,2)
    plot(t,processed,'r');
    axis([t(1) t(end) min(processed) max(processed)]);
    title('Sinal processado');
    xlabel('Tempo (s)');ylabel('Amplitude (V)');
    grid on;
    
    
end