classdef AirCraft
    %AirCraft Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Components
        W_to;                           % this property is solely for weight estimation
        fuselage;
        wing;
        fuelSys;
        engine;
        hTail;
        vTail;
        
        % state
        AoA ;                            % Angle of attack [degree]
        alt;                             % current altitude             
        v;                               % current airspeed
        payloadWeight;                   % current payload weight
        
        % Layout
        % choose the leading edge of wing as the reference point
        % every coefficient is the distance between the reference point and 
        % the CG or AC of the components. 
        h_acw;                  % AC&CG of wing
        h_act;                  % AC&CG of horizontal tail
        h_acvt;                 % AC&CG of vertical tail
        h_fuselage;             % CG of fuselage
        h_engine;               % CG of engine
        h_fuelSys;              % CG of fuelSys
        h_payload;              % CG of payload
        
        getWeight;              % get overall aircraft Weight
        getLw;                  % wing AC to CG
        getLt;                  % tail AC to CG
        get_hcg;                % get cg of the aircraft 
        get_hn                  % get neutral point
        get_hcgEmpty;           % get cg of the aircraft when 0 payload
        get_hnEmpty;            % get neutral point when 0 payload
        get_margin;             % get static margin
        get_hcgToNose;          % get the normalized distance from h_cg to nose
        get_hcgToTail;          % get the normalized distance from h_cg to tail
        getHv;                  % tail volume parameter
        getVv;                  % tail volume ratio
        getCl                   % get lift coefficient
        getBaldeAngle;          % get blade angle of propeller
        
    end
    
    methods
        % Constructor 
        function AC = AirCraft(W_to, fuselage, wing, fuelSys, hTail, vTail, engine)
            AC.W_to = W_to;
            AC.fuselage = fuselage;
            AC.wing = wing;
            AC.fuelSys = fuelSys;
            AC.hTail = hTail;
            AC.vTail = vTail;
            AC.engine = engine;
                
        end

        % method
        function weight = get.getWeight(thisAirCraft)
            weight = thisAirCraft.payloadWeight...
                + thisAirCraft.fuselage.getWeight...
                + thisAirCraft.wing.getWeight...
                + thisAirCraft.fuelSys.getWeight ...
                + thisAirCraft.hTail.getWeight...
                + thisAirCraft.vTail.getWeight...
                + thisAirCraft.engine.getWeight;
            weight = weight + 1.08*(thisAirCraft.W_to)^.7;
        end

        function Cl = get.getCl(ac)
            Clde = ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s) * ac.hTail.tau;
            Cl = (ac.wing.get3DCla + ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s)*(1 - ac.wing.getDownwashRate))*ac.AoA ...
                - ac.hTail.get3DCla*(ac.hTail.s/ac.wing.s)*ac.hTail.it ...
                + Clde * ac.hTail.de;
        end
        
        function Cmcg = getCmcg(ac)
            Clde = ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s) * ac.hTail.tau;
            Cmde = - Clde * (ac.getLt/ac.wing.getChord);
            Cmcg = (ac.wing.get3DCla * (ac.get_hcg - ac.h_acw) - ac.getHv * ac.hTail.get3DCla * (1 - ac.wing.getDownwashRate))*ac.AoA ...
                + ac.wing.get3DCmac ...
                + ac.getHv * ac.hTail.get3DCla * ac.hTail.it ...
                + Cmde * ac.hTail.de;
        end
        
        function getHv = get.getHv(ac)
           getHv = ac.getLt/ac.wing.getChord * ac.hTail.s/ac.wing.s; 
        end

        function getVv = get.getVv(ac)
           getVv = ac.getLt * ac.vTail.s/(ac.wing.s * (ac.wing.b+ac.fuselage.D)); 
        end
        function getLw = get.getLw(ac)
           getLw = (ac.get_hcg - ac.h_acw) * ac.wing.getChord;  
        end
        
        function getLt = get.getLt(ac)
           getLt = (ac.h_act - ac.get_hcg) * ac.wing.getChord; 
        end
        
        function h_cg = get.get_hcg(ac)
           h_cg = ...
                (ac.h_acw * ac.wing.getWeight ...
               + ac.h_act * ac.hTail.getWeight ...
               + ac.h_acvt * ac.vTail.getWeight ...
               + ac.h_fuselage * ac.fuselage.getWeight ...
               + ac.h_engine * ac.engine.getWeight ...
               + ac.h_fuelSys * ac.fuelSys.getWeight ...
               + ac.h_payload * ac.payloadWeight ...
               )/ac.getWeight;
        end
        
        function get_hcgEmpty = get.get_hcgEmpty(ac)
            ac.payloadWeight = 0;
            get_hcgEmpty = ...
                (ac.h_acw * ac.wing.getWeight ...
               + ac.h_act * ac.hTail.getWeight ...
               + ac.h_acvt * ac.vTail.getWeight ...
               + ac.h_fuselage * ac.fuselage.getWeight ...
               + ac.h_engine * ac.engine.getWeight ...
               + ac.h_fuelSys * ac.fuelSys.getWeight ...
               + ac.h_payload * ac.payloadWeight ...
               )/ac.getWeight;
        end
        
        function get_hnEmpty = get.get_hnEmpty(ac)
            ac.payloadWeight = 0;
            Cma = ac.wing.get3DCla * (ac.get_hcg - ac.h_acw) - ac.getHv * ac.hTail.get3DCla * (1 - ac.wing.getDownwashRate);
            Cla = ac.wing.get3DCla + ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s)*(1 - ac.wing.getDownwashRate);
            get_hnEmpty = ac.get_hcgEmpty - Cma/Cla;
        end
        
        function get_hn = get.get_hn(ac)
            Cma = ac.wing.get3DCla * (ac.get_hcg - ac.h_acw) - ac.getHv * ac.hTail.get3DCla * (1 - ac.wing.getDownwashRate);
            Cla = ac.wing.get3DCla + ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s)*(1 - ac.wing.getDownwashRate);
            get_hn = ac.get_hcg - Cma/Cla;
        end
        
        function get_margin = get.get_margin(ac)
           get_margin = ac.get_hn - ac.get_hcg; 
        end
        
        function get_hcgToNose = get.get_hcgToNose(ac)
           get_hcgToNose = 0.5 * ac.fuselage.L - (ac.h_fuselage - ac.get_hcg)*ac.wing.getChord;  
        end
        
        function get_hcgToTail = get.get_hcgToTail(ac)
           get_hcgToTail = (ac.h_act - ac.get_hcg)*ac.wing.getChord;  
        end
        
        function [AoA, eleAngle] = elevatorToTrim(ac,WorldConstants)
            Cl_req = 2*ac.getWeight/(WorldConstants.AirDensity * ac.v^2 * ac.wing.s);
            Cla = ac.wing.get3DCla + ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s)*(1 - ac.wing.getDownwashRate);
            Cl0 = - ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s) * ac.hTail.it;
            Cma = ac.wing.get3DCla * (ac.get_hcg - ac.h_acw) - ac.getHv * ac.hTail.get3DCla * (1 - ac.wing.getDownwashRate);
           Cm0 = ac.wing.get3DCmac + ac.getHv * ac.hTail.get3DCla * ac.hTail.it;
           Clde = ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s) * ac.hTail.tau;
           Cmde = - Clde * (ac.getLt/ac.wing.getChord);
           
            eleAngle = -(Cm0*Cla + Cma*Cl_req)/(Cla*Cmde - Cma*Clde);
           if (eleAngle > ac.hTail.max_de) || (eleAngle < (-ac.hTail.max_de))
              % error ('cannot trim because |eleAngle| > max_de') 
           end
            AoA = (Cl_req - Cl0 - Clde*eleAngle)/Cla;
        end
        
        function propEff = getPropellerEfficiencyByRPM(ac, rpm)
            aoa = ac.v/(rpm/60*ac.engine.propD);
            propEff = interp1(ac.engine.propEffVsPropAoA(:,1),ac.engine.propEffVsPropAoA(:,2),aoa);
        end
        
        function getBaldeAngle = get.getBaldeAngle(ac)
            aoa = ac.v/(ac.engine.getRPMByThrottle(ac.engine.throttle)/60*ac.engine.propD);
            getBaldeAngle = interp1(ac.engine.bladeAngleVsPropAoA(:,1),ac.engine.bladeAngleVsPropAoA(:,2),aoa);
        end
        
        function [v, AoA, eleAngle, throttle] = cruise(ac, WorldConstants, Spec)
            ac.v = Spec.CruisingSpeed;      % set aircraft speed = given cruising speed
            v = Spec.CruisingSpeed;
            % trim
            [AoA,eleAngle]=ac.elevatorToTrim(WorldConstants);
            ac.AoA = AoA;
            ac.hTail.de = eleAngle;
            
            Cd = getCd(ac,WorldConstants);
            drag = 1/2* WorldConstants.AirDensity * ac.wing.s * Cd * (ac.v)^2;
            power_req = drag * ac.v;
            
            propEff = 1;      % set tentative propeller efficiency 
            correctPropEff = 0.6;
            inum = 0;
            while (abs(propEff-correctPropEff)/correctPropEff > 0.05) && inum < 50
                propEff = correctPropEff;
                enginePower_req = power_req/propEff;
                engineRPM = ac.engine.getRPMbyPower(enginePower_req/ac.engine.N);
                correctPropEff = ac.getPropellerEfficiencyByRPM(engineRPM);
                inum = inum +1;
            end
            
            throttle = ac.engine.getThrottleByRPM(engineRPM);
        end
        
    end
    
end

