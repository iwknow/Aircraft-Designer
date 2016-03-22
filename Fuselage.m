classdef Fuselage
    %Fuselage Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        W_to;       % take-off weight [lbm]
        N = 6.6;    % ultimate load factor
        L;          % length (ft)
        D;          % max diameter (ft)
        Ve = 200;   % equivalent max airspeed [mph]
        getWeight;  % get fuselage weight [lbm]
        getLength;  % get fuselage length [ft]
        getRadius;  % get fuselage radius [ft]
        getSwet;    % get wetted area [ft^2]
    end
    
    methods
        % Constructor
        function F = Fuselage(W_to,L,D)
            if nargin ~= 3
                error('Invailid Fuselarge Constructor. Consult page 32')
            end
            F.W_to = W_to;
            F.L = L;
            F.D = D;
        end
        
        % Getters
        function getWeight = get.getWeight(F)
            getWeight = 200*((F.W_to*F.N/100000)^.286 * (F.L/10)^.857 * (F.D + F.D)/10 * (F.Ve/100)^.338)^1.1;
        end
        
        function getLength = get.getLength(F)
           getLength = F.L; 
        end
        
        function getRadius = get.getRadius(F)
           getRadius = F.D / 2; 
        end
        
        function getSwet = get.getSwet(F)
           getSwet = 3.4 * (F.L*F.D);
        end
    end
    
end

