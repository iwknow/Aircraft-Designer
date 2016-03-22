classdef FuelSystem
    % FuelSystem Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fuelWeight;         % current fuel weight
        fuelCapacity;       % fuel carrying capacity
        int = 1;            % percent of fuel tanks that are integral
        
        % computed properties
        getFuelVolume;      % get volume needed for fuel tank
        getWeight;          % get overall weigth of fuel system
    end
    
    methods
        function F = FuelSystem(fc,initFW)
            F.fuelCapacity = fc;
            F.fuelWeight = initFW;
        end
        
        function getFuelVolume = get.getFuelVolume(F)
           density = 6.073;         % [lb/ US gal]
           convertFactor = 0.13368;  % [US gal / ft^3]
           getFuelVolume = F.fuelCapacity / density * convertFactor;
        end
        
        function getWeight = get.getWeight(F)
           getWeight = 2.49 * (F.getFuelVolume^.6 ...
               * (1/(1+ F.int))^.3 ...
               * 2^.13 ...
               )^1.21 ...
               + F.fuelWeight; 
        end
    end
    
end
