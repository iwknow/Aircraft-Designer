classdef Wing
    %Wing Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        % inputs
        b;                      % span length
        cla;                    % 2D cl alpha
        c_mac;                  % 2D C_mac 
        s;                      % wing area
        e;                      % Oswald efficiency number
        W_to;                   % take-off weight
        Cdminw;                 % minimum drag coefficient of the airfoil, see drag paper[p18-top] for detail
        N = 6.6;                % ultimate load factor
        stallAngle;             % Stall Angle
        QuaChordSweep = 0       % Quarter Chord Sweep [rad]
        Taper = 1               % Taper Ratio
        Ve = 141;               % equivalent max airspeed
        tcRatio;                % maximum thickness of wing over chord (t/c)m 
        xcRatio;                % chordwise location of the airfoil maximum thickness point [Raymer 283]
        
        % Calculated Properties
        getChordRoot;           % root chord length [ft]
        getChord;               % get average chord length [ft]
        getAR;                  % get aspect ratio
        get2DCla;               % get 2D lift slope (same value as cla)
        get3DCla;               % get 3D lift slope
        getWeight;              % get wing weight [lbm]
        getSwet;                % get wetted area [ft^2]
        get3DCmac;              % get 3D Cmac (same as 2D value) [ft-lbf]
        getDownwashRate;        % get the downwash effect of the wing to the tail
    end
    
    methods 
        % Constructor
        function W = Wing(W_to,cla, c_mac,s, span,t , xcRatio,Taper,stallAngle,e)
            if nargin ~= 10
                error('Invailid Wing Constructor')
            end
            W.W_to = W_to;
            W.b = span;
            W.cla = cla;
            W.c_mac = c_mac;
            W.s = s;
            W.e = e;
            W.tcRatio = t;
            W.xcRatio = xcRatio;
            W.Taper = Taper;
            W.stallAngle = stallAngle;
        end
        
        % Getters
        function getAR = get.getAR(W)
           getAR = W.b/(W.s/W.b); 
        end
        
        function getChordRoot = get.getChordRoot(W)
           getChordRoot = 2*W.s/(W.b * (1+W.Taper)); 
        end
        function get2DCla = get.get2DCla(W)
           get2DCla = W.cla; 
        end
        
        function get3DCla = get.get3DCla(W)
           get3DCla = W.cla /(1 + W.cla/(pi*W.e*W.getAR)); 
        end
        
        function getWeight = get.getWeight(W)
           getWeight = 96.948 * ((W.W_to*W.N/100000)^.65...
                * (W.getAR/cos(W.QuaChordSweep))^.57...
                * (W.s/100)^0.61...
                * ((1+W.Taper)/(2*W.tcRatio))^0.36...
                * (1+W.Ve/500)^.5...
           )^0.993;
        end
        
        function getChord = get.getChord(W)
           getChord = (2/3)*W.getChordRoot*+(1+W.Taper-(W.Taper)/(1+W.Taper)); 
        end
        
        function getSwet = get.getSwet(W)
           getSwet = W.b * W.getChord *2*(1+0.5*W.tcRatio);
        end
        
        function getDownwashRate = get.getDownwashRate(W)
           getDownwashRate = 1.2/(pi*W.e*W.getAR)*W.cla;    % 2.35
        end
        
        function get3DCmac = get.get3DCmac(W)
           chordSQR = @(y) (W.getChordRoot .* (1- (1 - W.Taper).*(y./(W.b./2)))).^2;
           get3DCmac = 2./(W.s .* W.getChord)* (W.c_mac * integral(chordSQR,0,W.b/2));           % 2.28, assume distance between the section AC and wing AC is 0
        end
    end
    
end

