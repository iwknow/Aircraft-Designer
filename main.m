% Project Nickel Squirrel

% ============== Design Spec ==============
Spec = struct( ...
    'StallSpeed',117, ...               % ft/s
    'Range', 1.32E6, ...                % ft
    'Endurance', 14400, ...             % sec
    'Payload', 400, ...                 % lb
    'ClimbRate', 30, ...                % ft/s
    'CruisingSpeed',234 ...             % ft/s 
    );
% ============== World Constants ==============
WorldConstants = struct(...
    'AirDensity',0.0019, ...                % Air density [slug/ft^3]
    'kinematicViscosity', 1.529e-4,...      % kinematic Viscosity [ft^2/s]    
    'airSpecificHeatRatio', 1.4,...         % airSpecificHeatRatio [Null]
    'airSpecificGasConstant', 1716,...      % airSpecificGasConstant [ft lb/slug oR]
    'airTemperature',527.67);               % airTemperature [R]

% Parameters;
W_to = 3000;                                % guess takeoff weight [lb]

% ============== build components ==============
% fuselage
L = 21.044283750055012;                     % fuselarge length [ft]
D = 5;                                      % fuselarge deepth [ft]
fuselage = Fuselage(W_to, L, D);
% wing
span = 30.188353302222050;                  % chord length
cla = 6.500000000000000;                    % 2D cl alpha [/rad]
c_mac = -0.028503342015906;                 % 2D moment coefficient C_m(1/4)
s = 1.23630648766614e+02;                   % wing area
e = 1/(1.05+0.007 * pi * span/(s/span));    % Oswald efficiency number
taper = 0.4;                                % Taper Ratio
t = 0.18;                                   % maximum thickness of wing over chord (t/c)m
stallAngle = 15/180*pi;                     % stall angle
xcRatio = 0.3;                              % chordwise location of the airfoil maximum thickness point (x/c)m [Raymer 283]
wing = Wing(W_to,cla,c_mac,s,span, t, xcRatio,taper , stallAngle,e);
% fuel system
fuelCapacity = 80;     % [lb]
initFuel = 70;         % [lb]
fuelSys = FuelSystem(fuelCapacity,initFuel);
% Horizontal Tail
b = 14.858803965044864;                     % tail span [ft]
cla = 6.693526429384460;                    % 2D cl alpha
s = 55;                                     % wing area
t = 0.12;                                   % maximum thickness of wing over chord (t/c)m
xcRatio = 0.3;                              % chordwise location of the airfoil maximum thickness point (x/c)m [Raymer 283]
e = 1;                                      % Oswald efficiency number
it = 1/180*pi;                              % incidence angle [/rad]
tau = 0.2;                                  % elevator area persentage
de = -0/180*pi;                             % initial elevator angle [rad]
max_de = 30/180*pi;                         % max abs of elevator angle [rad]    
htail = HTail(W_to,b,cla,s, t,xcRatio, e, it,tau, de, max_de);
% Vertical Tail
s = 15;                                     % area in ft^2
b = 5;                                      % span in ft
t = 0.12;                                   % maximum thickness of wing over chord (t/c)m
xcRatio = 0.3;                              % chordwise location of the airfoil maximum thickness point (x/c)m [Raymer 283]
vtail = VTail(W_to,s,b,t, xcRatio);
% Engine
propD = 3.9;                                % propeller diameter [ft]
engine = Engine(propD);

% ============== Aircraft State ==============
testUAV = AirCraft(W_to, fuselage,wing,fuelSys, htail,vtail,engine);
% Use the Following Flight Condition
testUAV.AoA = 2/180*pi;
testUAV.alt = 3300;
testUAV.v = 150;
testUAV.payloadWeight = 400;        % here the weight must be the payload the UAV is going to pickup
% ============== Aircraft Layout ==============

FuselageNosetoWingFrontRatio = 0.1;
TailtoFuselageFrontRatio = 0.91;
FueltoFuselageFrontRatio = 0.45;
PayloadtoFuselageFrontRatio = 0.22;
% Auto-Layout
fuselageToChord = testUAV.fuselage.L/testUAV.wing.getChord;
testUAV.h_acw = 1/4;
testUAV.h_fuselage = fuselageToChord * (1/2 - FuselageNosetoWingFrontRatio) ;
testUAV.h_act = testUAV.h_fuselage + fuselageToChord * (TailtoFuselageFrontRatio - 1/2);
testUAV.h_acvt = testUAV.h_fuselage + fuselageToChord * (TailtoFuselageFrontRatio - 1/2);
testUAV.h_engine = 1/4;
testUAV.h_fuelSys = testUAV.h_fuselage + fuselageToChord * (FueltoFuselageFrontRatio - 1/2);
testUAV.h_payload = testUAV.h_fuselage + fuselageToChord * (PayloadtoFuselageFrontRatio - 1/2);

% Automatically match weigt
while abs(testUAV.W_to - testUAV.getWeight) > 5
    testUAV.W_to = testUAV.getWeight;
    testUAV.fuselage.W_to = testUAV.getWeight;
    testUAV.wing.W_to = testUAV.getWeight;
    testUAV.hTail.W_to = testUAV.getWeight;
    testUAV.vTail.W_to = testUAV.getWeight;
end
