function res = evaluate_signal(ideal,processado,ruidoso)
    
    %snr_final = real(20*log10(sum(processado)/sum(processado - ideal)));
    %snr_final = 10*log10(mean(processado)/std(processado));
    %snr_inicial =  10*log10(mean(ruidoso)/std(ruidoso));
    
    res.snr_final  = SNR(ideal,processado);
    res.snr_inicial  = SNR(ideal,ruidoso);
    
    
    %snr_inicial = real(20*log10(sum(ruidoso)/sum(ruidoso - ideal)));
    res.rxy_final = abs(corr2(ideal,processado));
    res.rxy_inicial = abs(corr2(ideal,ruidoso));
   
end
