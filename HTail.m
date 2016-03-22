classdef HTail
    %HTail Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        % inputs
        b;                      % tail span
        cla;                    % 2D cl alpha
        s;                      % wing area
        e;                      % Oswald efficiency number
        it;                     % incidence angle
        tau;                    % elevator area persentage 
        W_to;                   % take-off weight
        N = 6.6;                % ultimate load factor
        lt = 21;                % Distance from wing 1/4 MAC to tail 1/4 MAC
        QuaChordSweep = 0;      % Quarter Chord Sweep
        Taper = 1;              % Taper Ratio
        tcRatio;                % maximum thickness of wing over chord (t/c)m
        xcRatio;                % chordwise location of the airfoil maximum thickness point [Raymer 283]
        Ve = 200;               % equivalent max airspeed
        max_de;                 % max abs of elevator angle [rad] 
        
        % Computed Properties
        getAR;                  % get aspect ratio
        get2DCla;               % get 2D lift coefficient slope
        get3DCla;               % get 3D lift coefficient slope
        getWeight;              % get horizontal tail weight [lbm]
        getSwet;                % get horizontal tail wetted area [ft^2]
        getChordRoot;           % get root chord [ft]
        getChord;               % get average chord [ft]
    end
    
    properties 
        de;                     % initial elevator angle [rad], this property can be changed
    end
    
    methods
        function HT = HTail(W_to,b,cla,s,t, xcRatio,e,it,tau, de, max_de)
            if nargin ~= 11
                error('Invalid Fuselage Constructor.')
            end
            HT.W_to = W_to;
            HT.b = b;
            HT.cla = cla;
            HT.s = s;
            HT.e = e;
            HT.tcRatio = t;
            HT.xcRatio = xcRatio;
            HT.it = it;
            HT.tau = tau;
            HT.de = de;
            HT.max_de = max_de;
        end
        
        % Getters
        function getAR = get.getAR(HT)
           getAR = (HT.s/HT.getChord)/HT.getChord; 
        end
        
        function get2DCla = get.get2DCla(HT)
           get2DCla = HT.cla; 
        end
        
        function get3DCla = get.get3DCla(HT)
            if HT.getAR < 5
               get3DCla = HT.cla/(1+HT.cla/(pi*HT.e*HT.getAR)); 
            else
           get3DCla = HT.cla /(1 + HT.cla/(pi*HT.e*HT.getAR)); 
            end
        end
        
        function getWeight = get.getWeight(HT)
           getWeight = 127 * ((HT.W_to*HT.N/100000)^.87...
               * (HT.s/100)^1.2...
               * (HT.lt/10)^.483...
               * (HT.b/(HT.tcRatio * HT.getChord *12))^.5 ...
          )^0.458;
        end
        
        
        function getChordRoot = get.getChordRoot(HT)
           getChordRoot = 2*HT.s/(HT.b * (1+HT.Taper)); 
        end
        
        function getChord = get.getChord(HT)
           getChord = (2/3)*HT.getChordRoot*+(1+HT.Taper-(HT.Taper)/(1+HT.Taper)); 
        end
        
        function getSwet = get.getSwet(HT)
            getSwet = 2 *(1 + 0.5* HT.tcRatio) * HT.b * HT.getChord;
        end 
        
    end
    
end

