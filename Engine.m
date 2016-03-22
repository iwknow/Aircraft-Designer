classdef Engine
    %Engine Summary of this class goes here
    %   Rotax 914F
    
    properties 
        EngineWeight = 140.8;           % engine Weight
        susPower = 55000;               % sustained Power
        maxPower = 64250;               % max power
        maxRPM = 5600;                  % max RPM
        cp;                             % specific fuel consumption [lb/(lb*ft/s * s) = 1/ft]
        propD;                          % propeller Diameter [ft]
        N = 2;                          % number of engine
        throttle = 0.5                  % default throttle
        
        % computed properties
        getWeight;                      % get engine weight
        % digitized graphs
        powerVsRPM;                     % power Vs RPM data. [hp];[RPM]
        FVRVsRPM;                       % fuel Volume Rate Vs RMP data. [US gal/h];[RPM]
        propEffVsPropAoA;               % propeller efficiency vs propeller aoa
        bladeAngleVsPropAoA;            % blade angle vs propeller aoa

    end
    
    
    
    methods
        % Constructor
        function En = Engine(propD)
            En.powerVsRPM = csvread('assets/enginePowerVsRPM.csv');
            En.FVRVsRPM = csvread('assets/fuelConsumpVsRPM.csv');
            En.propEffVsPropAoA = csvread('assets/propEffVsPropAoA.csv');
            En.bladeAngleVsPropAoA = csvread('assets/bladeAngleVsPropAoA.csv');
            En.propD = propD;
        end
        
        % Getters
        function getWeight = get.getWeight(En)
            getWeight = 2.5758*(En.EngineWeight)^.922*2;
        end
        
        function cp = get.cp(En)
            gasolineDensity = 6.073;  % [lb/US Gal]
            fuelMassRate = En.getFuelVolumeRateByRPM(En.getRPMByThrottle(En.throttle))*gasolineDensity/3600; % [lb/s]
            cp = fuelMassRate/En.getPowerByRPM(En.getRPMByThrottle(En.throttle));
        end
        
        
        % Methods
        function RPM = getRPMbyPower(En,power) % power [lbf.ft/s]
            converter = 0.0018181817;       % [lbf.ft/s] to [hp]
            power = power*converter;
            RPM = interp1(En.powerVsRPM(:,2),En.powerVsRPM(:,1),power);
        end
        
        function power = getPowerByRPM(En,RPM) % power [lbf.ft/s]
            converter = 0.0018181817;       % [lbf.ft/s] to [hp]
            power = interp1(En.powerVsRPM(:,1),En.powerVsRPM(:,2),RPM);
            power = power/converter;
        end
        
        function throttle = getThrottleByRPM(En, rpm)
            throttle = rpm/En.maxRPM;
        end
        
        function rpm = getRPMByThrottle(En,throttle)
           rpm =  En.maxRPM* throttle;
        end
        
        function fvr = getFuelVolumeRateByRPM(En,rpm)
            fvr = interp1(En.FVRVsRPM(:,1),En.FVRVsRPM(:,2),rpm);
        end
        
    end
    
end

