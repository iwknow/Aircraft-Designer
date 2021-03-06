function [ derivatives ] = getDev( ac,WorldConstants )
CZ0 = - ac.hTail.get3DCla*(ac.hTail.s/ac.wing.s)*ac.hTail.it;
CL_a = ac.wing.get3DCla + ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s)*(1 - ac.wing.getDownwashRate);
% CL_at = 
CZ_q = -2*ac.hTail.get3DCla*ac.getHv;
CZ_adot = -2 * ac.getHv * ac.hTail.get3DCla * ac.wing.getDownwashRate;
CL_de = ac.hTail.get3DCla * (ac.hTail.s/ac.wing.s) * ac.hTail.tau;

Cm0 = ac.wing.get3DCmac + ac.getHv * ac.hTail.get3DCla * ac.hTail.it;
Cm_a = ac.wing.get3DCla * (ac.get_hcg - ac.h_acw) - ac.getHv * ac.hTail.get3DCla * (1 - ac.wing.getDownwashRate);
Cm_adot = -2 * ac.hTail.get3DCla * ac.getHv * (ac.getLt/ac.wing.getChord) * ac.wing.getDownwashRate;
Cm_q = -2 * ac.hTail.get3DCla * ac.getHv * (ac.getLt/ac.wing.getChord);
Cm_de = -CL_de * (ac.getLt/ac.wing.getChord);

[CD0,CD_a,CD_de] = getCd(ac,WorldConstants,1);

CY_beta = -(ac.vTail.s/ac.wing.s)*ac.vTail.get3DCla*(1+ac.vTail.getSidewashRate);                                           % cornell 4.82
CY_dr = 1.2 * ac.vTail.s/ac.wing.s * ac.vTail.get3DCla * ac.vTail.tau;                                                      % McCormick 9.127 
CY_r = 2*ac.getVv*ac.vTail.get3DCla;                                                                                        % cornell 4.102
CY_p = -8/(3*pi)* (ac.vTail.s/ac.wing.s) * (ac.vTail.getChord/ac.wing.b) * ac.vTail.get3DCla;                               % cornell 4.118

Cl_beta = -(ac.vTail.getZ*ac.vTail.s/(ac.wing.b * ac.wing.s)) * ac.vTail.get3DCla * (1 + ac.vTail.getSidewashRate);         % cornell 4.97
Cl_r = CZ0/4 + 2 * ac.vTail.getZ/ac.wing.b * ac.getVv*ac.vTail.get3DCla;                                                    % cornell 4.105
Cl_p = -ac.wing.get3DCla/7;                                                                                                 % combined cornell 4.124 and 4.126
Cl_da = 2*(0.6) * (5) *   0.7 *  0.05;                                                                                      % raymar 16.45
% asuume  Kf    dCl/ddf   Yi/b   Si/Sw


V_fuselage = pi * ac.fuselage.D^2/4 * ac.fuselage.L;
Cn_beta = ac.getVv * ac.vTail.get3DCla * (1 + ac.vTail.getSidewashRate) - 2*V_fuselage/(ac.wing.s * ac.wing.b);             % cornell 4.87
Cn_r = -CD0/4 - 2*(ac.getLt/ac.wing.b)*ac.getVv*ac.vTail.get3DCla;                                                          % cornell 4.105
Cn_p = 8/(3*pi) * (ac.vTail.b/ac.wing.b) * ac.getVv * ac.vTail.get3DCla;                                                    % cornell 4.128
Cn_da = -0.2 * ac.getCl * Cl_da;                                                                                            % Raymar 16.46
Cn_dr = -CY_dr * ac.getLt/ac.wing.b;                                                                                        % rudder 4.6


derivatives = struct(...
  'CL0',-CZ0, ...
  'CL_a',CL_a, ...
  'CL_q',-CZ_q, ...
  'CL_adot', -CZ_adot, ...
  'CL_de', CL_de, ...
  'CD0',CD0, ...
  'CD_a',CD_a, ...
  'CD_de', CD_de, ...
  'Cm0', Cm0, ...
  'Cm_a', Cm_a, ...
  'Cm_adot', Cm_adot, ...
  'Cm_q',Cm_q, ...
  'Cm_de', Cm_de, ...
  'CY_beta', CY_beta, ...
  'CY_dr', CY_dr, ...
  'CY_r', CY_r, ...
  'CY_p',CY_p, ...
  'Cl_beta',Cl_beta, ...
  'Cl_r', Cl_r, ...
  'Cl_p', Cl_p, ...
  'Cl_dr', 0, ...too small
  'Cl_da', Cl_da, ...
  'Cn_beta',Cn_beta, ...
  'Cn_r', Cn_r, ...
  'Cn_p', Cn_p, ...
  'Cn_da', Cn_da, ...
  'Cn_dr', Cn_dr ...
);
end

