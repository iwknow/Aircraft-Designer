function [ moment ] = pickupTest( ac, WorldConstants )
    payloadWeight = 450;        %lb
    accTime = 1.5;               % acceleration time [s]
    payloadMass = payloadWeight * 0.031081;
    noseMoment = (payloadMass * (ac.v/accTime + 32.17)) * ac.get_hcgToNose;
    
    ac.v = 135;
    ac.payloadWeight = 0;
    ac.hTail.it = 10/180*pi;
    ac.hTail.de = -30/180*pi;
    tailMoment = (0.5*WorldConstants.AirDensity*(ac.v)^2 * ac.wing.s * ac.wing.getChord) * ac.getCmcg();
    moment = tailMoment - noseMoment;

end

