function result = windTunnel( ac,WorldConstants,Spec )
% Test the air craft. return the result of if the air craft meet the design
% spec

% get stall speed
Cla = ac.wing.get3DCla + ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s)*(1 - ac.wing.getDownwashRate);
Cl0 = - ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s) * ac.hTail.it;
Cma = ac.wing.get3DCla * (ac.get_hcg - ac.h_acw) - ac.getHv * ac.hTail.get3DCla * (1 - ac.wing.getDownwashRate);
Cm0 = ac.wing.get3DCmac + ac.getHv * ac.hTail.get3DCla * ac.hTail.it;
Clde = ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s) * ac.hTail.tau;
Cmde = - Clde * (ac.getLt/ac.wing.getChord);
Cl_max = (ac.hTail.max_de * (Cla*Cmde-Cma*Clde) - (Cm0*Cla)) / Cma;
AoA_req = (Cl_max - Cl0)/Cla;
if AoA_req < ac.wing.stallAngle
    v_stall = sqrt(2*ac.getWeight/(WorldConstants.AirDensity * ac.wing.s * Cl_max));
else
    ac.AoA = ac.wing.stallAngle;
    v_stall = sqrt(2*ac.getWeight/(WorldConstants.AirDensity * ac.wing.s * ac.getCl));
end

% Let the air craft cruise
[ac.v,ac.AoA,ac.hTail.de,ac.engine.throttle] = ac.cruise(WorldConstants, Spec);

% get Range
range = ac.getPropellerEfficiencyByRPM(ac.engine.getRPMByThrottle(ac.engine.throttle))/ac.engine.cp ...
    * (ac.getCl/getCd(ac,WorldConstants)) ...
    * log(ac.getWeight/(ac.getWeight - ac.fuelSys.fuelWeight));
% get Endurance
endurance = ac.getPropellerEfficiencyByRPM(ac.engine.getRPMByThrottle(ac.engine.throttle))/ac.engine.cp ...
    * ac.getCl^1.5/getCd(ac,WorldConstants) ...
    * sqrt(2*WorldConstants.AirDensity*ac.wing.s) ...
    * (1/sqrt(ac.getWeight - ac.fuelSys.fuelWeight) - 1/sqrt(ac.getWeight));
% get Rate of Climb
p_req = (.5*WorldConstants.AirDensity*(ac.v)^2*ac.wing.s*getCd(ac,WorldConstants)) * ac.v;
p_av = (ac.engine.maxPower * ac.engine.N) * ac.getPropellerEfficiencyByRPM(ac.engine.getRPMByThrottle(ac.engine.throttle));
p_ex = p_av - p_req;
rateOfClimb = p_ex/ac.getWeight;

% pickup moment test
moment = pickupTest(ac,WorldConstants);

% Return the result
result = struct( ...
    'StallSpeed',v_stall, ...               % ft/s
    'Range', range, ...                     % ft
    'Endurance', endurance, ...             % sec
    'Payload', 400, ...                     % lb
    'ClimbRate', rateOfClimb, ...           % ft/s
    'PickupMoment', moment, ...              % ft * lb
    'Weight',ac.getWeight ...
    );
end

