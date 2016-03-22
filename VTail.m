classdef VTail
    %VTail Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        s;                      % area in ft^2
        b;                      % span in ft
        e = 1;                  % Oswald efficiency number
        cla = 6.5;              % 2D lift coefficient slop
        tcRatio;                % maximum thickness of wing over chord (t/c)m
        W_to;                   % take-off weight
        N = 6.6;                % ultimate load factor
        Taper = 1;              % taper ratio
        xcRatio;                % chordwise location of the airfoil maximum thickness point [Raymer 283]
        tau = 0.3               % rudder area persentage
        
        % Computed Properties
        getWeight;              % get weight [lbm]
        getSwet;                % get wetted area [ft^2]
        getChordRoot;           % get root chord length [ft]
        getChord;               % get average chord length [ft]
        get3DCla;               % get 3D lift coefficient slop
        getAR;                  % get aspect ratio
        getSidewashRate;        % similar to downwash, estimated based on NACA TN 3356 pg29 
        getZ;                   % the distance of the vertical tail aerodynamic center above the vehicle center of mass [ft]
    end
    
    methods
        % Constructor
        function VT = VTail(W_to, s, b, t, xcRatio)
           VT.W_to = W_to;
           VT.s = s;
           VT.b = b;
           VT.xcRatio = xcRatio;
           VT.tcRatio = t;
        end
        
        function getZ = get.getZ(VT)
           getZ = 2.5 + VT.b/3; 
        end
        
        function getAR = get.getAR(VT)
           getAR = VT.b/(VT.s/VT.b); 
        end
        
        function get3DCla = get.get3DCla(VT)
           get3DCla = VT.cla /(1 + VT.cla/(pi*VT.e*VT.getAR)); 
        end
        
        function getSidewashRate = get.getSidewashRate(VT)
           getSidewashRate = 0.23 * VT.getAR;  % estimated from NACA TN 3356 pg29
        end
        
        function getWeight = get.getWeight(VT)
            getWeight = 98.5 * ((VT.W_to*VT.N/100000)^.87...
                * (VT.s/100)^1.2...
                * (VT.b/(VT.getChordRoot*12))^.5...
                )^.458;
        end
        
        function getChordRoot = get.getChordRoot(VT)
           getChordRoot = 2*VT.s/(VT.b * (1+VT.Taper)); 
        end
        
        function getChord = get.getChord(VT)
           getChord = (2/3)*VT.getChordRoot*+(1+VT.Taper-(VT.Taper)/(1+VT.Taper)); 
        end
        
        function getSwet = get.getSwet(VT)
           getSwet = 2 *(1 + 0.5* VT.tcRatio) * VT.b * VT.getChord; 
        end
        
    end
    
end

