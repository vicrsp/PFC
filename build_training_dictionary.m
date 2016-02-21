function [D_treino] = build_training_dictionary(params)

% arguments parsing
if(~isfield(params,'fs'))
    params.fs = 40e6;
end
if(~isfield(params,'sz_atom'))
    params.sz_atom = 128;
end
if(~isfield(params,'numPulsos'))
    params.numPulsos = 2^10;
end
if(~isfield(params,'Nsamples'))
    params.Nsamples = 1024;
end
if(~isfield(params,'ampDP'))
    params.ampDP = 1;
end

% Initialize variables
D_treino = [];

R0 = 2.7e3;
L0 = 6.7e-3;
C0 = 500e-12;

fs = params.fs;
sz_atom = params.sz_atom;
numPulsos = params.numPulsos;
n = 0:(params.Nsamples - 1);
ampDP = params.ampDP;


for i=1:numPulsos
    DP = [];
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
        
        zeta = alpha/omega0;
        
        %         s1 = -alpha + sqrt(alpha^2 - omega0^2);     % Raizes da
        %         equacao caracteristica s2 = -alpha - sqrt(alpha^2 -
        %         omega0^2);
        %
        %         A1 = -ampDP/(s1-s2) * (1/(R*C) + s2);  % Condicoes
        %         iniciais A2 = ampDP - A1;
        
        if(zeta < 1)
            DP = ampDP*(exp(-alpha * n/fs).*sin(omega0*sqrt(1 - zeta^2)*n/fs));
        else if (zeta > 1)
                alfa = real(alpha);
                beta = (1 + rand())*alfa;
                DP = 10*ampDP*(exp(-alfa*n/fs) - exp(-beta*n/fs));
            end
        end
        
        DP = DP + 0.0001 * max(DP) * randn(1 ,length(DP));
        
        for k=1:length(DP)/sz_atom
            D_treino = [D_treino  DP(1,sz_atom*(k-1)+1:(sz_atom*k))'];
        end
        
        
    end
    
end


end