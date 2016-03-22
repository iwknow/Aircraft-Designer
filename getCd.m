function [getCdp,getCdi,getCd] = getCd( AirCraft,WorldConstants, getDerivative )
    if (nargin == 3)
        getDerivative = 1;
    else 
        getDerivative = 0;
    end 
     % fuselage
    Sref = AirCraft.wing.s;
   
    Re = AirCraft.v * AirCraft.fuselage.L / WorldConstants.kinematicViscosity;
    M = AirCraft.v / (WorldConstants.airSpecificHeatRatio * WorldConstants.airSpecificGasConstant * WorldConstants.airTemperature)^.5;
    Cf = .455/((log10(Re))^2.58 * (1 + 0.144*M^2)^.65); %3.15a
    f = AirCraft.fuselage.L/AirCraft.fuselage.D;
    K = 1 + 60/(f)^3 + f/400;
    Q = 1.2;
    Cd_p_fuselage = K * Q * Cf *(AirCraft.fuselage.getSwet)/Sref;

    % wing
    Rew =  AirCraft.v * AirCraft.wing.getChord / WorldConstants.kinematicViscosity;
    Cfw = .455/((log10(Rew))^2.58 * (1 + 0.144*M^2)^.65);
    Kw = (1 + 0.6/AirCraft.wing.xcRatio * AirCraft.wing.tcRatio + 100 * AirCraft.wing.tcRatio^4) ...
        *(1.34 * M^0.18 * cos(AirCraft.wing.QuaChordSweep)^.28);
    Q = 1.2;
    Cd_p_wing = Kw * Q * Cfw *(AirCraft.wing.getSwet)/Sref;
   
    % Horizontal Tail
    Reh =  AirCraft.v * AirCraft.hTail.getChord / WorldConstants.kinematicViscosity;
    Cfh = .455/((log10(Reh))^2.58 * (1 + 0.144*M^2)^.65);
    Kh = (1 + 0.6/AirCraft.hTail.xcRatio * AirCraft.hTail.tcRatio + 100 * (AirCraft.hTail.tcRatio)^4) ...
        *(1.34*M^0.18*cos(0)^.28);
    Q = 1.2;
    Cd_p_hTail = Kh * Q * Cfh *(AirCraft.hTail.getSwet)/(Sref);
   
    % Vertical Tail
    Rev =  AirCraft.v * AirCraft.vTail.getChord / WorldConstants.kinematicViscosity;
    Cfv = .455/((log10(Rev))^2.58 * (1 + 0.144*M^2)^.65);
    Kv = (1 + 0.6/AirCraft.vTail.xcRatio * AirCraft.vTail.tcRatio + 100 * AirCraft.vTail.tcRatio^4) ...
        *(1.34*M^0.18*cos(0)^.28);
    Q = 1.2;
    Cd_p_vTail = Kv * Q * Cfv *(AirCraft.vTail.getSwet)/(Sref);
    
    % generate result
    Cd_para = Cd_p_fuselage + Cd_p_wing + Cd_p_hTail + Cd_p_vTail;
    getCdp = Cd_para;
    getCdi =  1/(pi*AirCraft.wing.getAR * AirCraft.wing.e)*(AirCraft.getCl)^2;
    getCd = getCdp + getCdi;
    if (getDerivative == 1)
        CL_a = (AirCraft.wing.get3DCla + AirCraft.hTail.get3DCla * (AirCraft.hTail.s/AirCraft.wing.s)*(1 - AirCraft.wing.getDownwashRate));
        CL_de = AirCraft.hTail.get3DCla * (AirCraft.hTail.s/AirCraft.wing.s) * AirCraft.hTail.tau;
        % CdO = Cd_para
        % Cd_a
        getCdi = 2/(pi*AirCraft.wing.getAR * AirCraft.wing.e) * AirCraft.getCl * CL_a; % 4.59
        % Cd_de
        getCd = 2/(pi*AirCraft.wing.getAR * AirCraft.wing.e) * AirCraft.getCl * CL_de;
    end
    
    
end


