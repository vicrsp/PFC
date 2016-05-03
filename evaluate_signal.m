function res = evaluate_signal(ideal,processado,ruidoso)
    
    res.snr_final = 10*log10(sum(ideal.^2)/sum((ideal - processado).^2));
    %snr_final = 10*log10(mean(processado)/std(processado) );
    res.snr_inicial =  10*log10(sum(ideal.^2)/sum((ideal - ruidoso).^2));
    
    %res.snr_final  = SNR(ideal,processado);
    %res.snr_inicial  = SNR(ideal,ruidoso);
    
    
    %snr_inicial = real(20*log10(sum(ruidoso)/sum(ruidoso - ideal)));
    res.rxy_final = abs(corr2(ideal,processado));
    res.rxy_inicial = abs(corr2(ideal,ruidoso));
   
end
