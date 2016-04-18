function plotDPsignal(measured, processed, saveFileName)
    
   % close all;
    fs = 25e6;%Hz
    
    deltaT = 1/fs;
    t = [0:length(processed)-1] * deltaT * 1000;
    
    fig_1 = figure;
    plot(t,measured,'b'); hold on;
    plot(t,processed,'r');
    axis([t(1) t(end) 1.1*min(measured) 1.1*max(measured)]);
    %title('\fontsize{14} Comparação entre sinal medido e processado');
    legend('Sinal medido','Sinal processado');
    xlabel('\fontsize{14} Tempo (ms)');ylabel('\fontsize{14} Amplitude (V)');
    set(gca,'fontsize',12)  
  %  grid on;
    
    fig_2 = figure;
    subplot(2,1,1)
    plot(t,measured,'b');
    %title('\fontsize{14} Sinal medido');
   % xlabel('\fontsize{14} Tempo (ms)');
    ylabel('\fontsize{14} Amplitude (V)');
    axis([t(1) t(end) 1.1*min(measured) 1.1*max(measured)]);
  %  grid on;
    set(gca,'fontsize',12)
    
    subplot(2,1,2)
    plot(t,processed,'r');
    axis([t(1) t(end) 1.1*min(processed) 1.1*max(processed)]);
   % title('\fontsize{14} Sinal processado');
    xlabel('\fontsize{14} Tempo (ms)');ylabel('\fontsize{14} Amplitude (V)');
%    grid on;
    set(gca,'fontsize',12)
    
%     fig_3 = figure;
%     plot(t,measured,'b');
%     %title('\fontsize{14} Sinal medido');
%     xlabel('\fontsize{14} Tempo (ms)');ylabel('\fontsize{14} Amplitude (V)');
%     axis([t(1) t(end) 1.1*min(measured) 1.1*max(measured)]);
%   %  grid on;
%     set(gca,'fontsize',12)
%     
%     fig_4 = figure;
%     plot(t,processed,'r');
%     axis([t(1) t(end) 1.1*min(processed) 1.1*max(processed)]);
%    % title('\fontsize{14} Sinal processado');
%     xlabel('\fontsize{14} Tempo (ms)');ylabel('\fontsize{14} Amplitude (V)');
% %    grid on;
%     set(gca,'fontsize',12)
%     
    if nargin > 2
       saveas(fig_1,sprintf('%s_%d',saveFileName, 1),'fig');
       saveas(fig_2,sprintf('%s_%d',saveFileName, 2),'fig');
       saveas(fig_1,sprintf('%s_%d',saveFileName, 1),'png');
       saveas(fig_2,sprintf('%s_%d',saveFileName, 2),'png');
%         saveas(fig_3,sprintf('%s_%d',saveFileName, 3),'fig');
%        saveas(fig_4,sprintf('%s_%d',saveFileName, 4),'fig');
%         saveas(fig_3,sprintf('%s_%d',saveFileName, 3),'jpeg');
%        saveas(fig_4,sprintf('%s_%d',saveFileName, 4),'jpeg');
       
    end
    
end