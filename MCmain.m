% Project Nickel Squirrel

% ============== Design Spec ==============
Spec = struct( ...
    'StallSpeed',117, ...               % ft/s
    'Range', 1.32E6, ...                % ft
    'Endurance', 14400, ...             % sec
    'Payload', 400, ...                 % lb
    'ClimbRate', 30, ...                % ft/s
    'CruisingSpeed',176 ...             % ft/s 
    );
% ============== World Constants ==============
WorldConstants = struct(...
    'AirDensity',0.0019, ...                % Air density [slug/ft^3]
    'kinematicViscosity', 1.529e-4,...      % kinematic Viscosity [ft^2/s]    
    'airSpecificHeatRatio', 1.4,...         % airSpecificHeatRatio [Null]
    'airSpecificGasConstant', 1716,...      % airSpecificGasConstant [ft lb/slug oR]
    'airTemperature',527.67);               % airTemperature [R]

% Parameters;
W_to = 2000;                             %takeoff weight [lb]
iterationN = 3000;                       % number of total iterations
good = [];                               % collection of good air craft
failed = [];                             % collection of failed air craft
% ============== build components ==============
parfor i = 1:iterationN
% fuselage
    L = MCrandom(30);             % fuselarge length [ft]
    D = 5;                        % fuselarge deepth [ft]
    fuselage = Fuselage(W_to, L, D);
    % wing
    span = MCrandom(45);          % chord length
    cla = 6.5;                    % 2D cl alpha [/rad]
    c_mac = -0.1;                 % 2D moment coefficient C_m(1/4)
    s = MCrandom(150,0.4);        % wing area
    e = 1/(1.05+0.007 * pi * span/(s/span));            % Oswald efficiency number
    taper = 0.4;                                        % Taper Ratio
    t = 0.18;                                           % maximum thickness of wing over chord (t/c)m
    stallAngle = 15/180*pi;                             % stall angle
    xcRatio = 0.3;                                      % chordwise location of the airfoil maximum thickness point (x/c)m [Raymer 283]
    wing = Wing(W_to,cla,c_mac,s,span, t, xcRatio,taper ,stallAngle,e);
    % fuel system
    fuelCapacity = MCrandom(160);     % [lb]
    initFuel = MCrandom(140);         % [lb]
    fuelSys = FuelSystem(fuelCapacity,initFuel);
    % Horizontal Tail
    b = MCrandom(20);                      % tail span [ft]
    cla = 6.2;                             % 2D cl alpha
    s = MCrandom(55);                      % wing area
    t = 0.12;                              % maximum thickness of wing over chord (t/c)m
    xcRatio = 0.3;                         % chordwise location of the airfoil maximum thickness point (x/c)m [Raymer 283]
    e = 1/(1.05+0.007 * pi * b/(s/b));     % Oswald efficiency number
    it = 1/180*pi;                         % incidence angle [/rad]
    tau = 0.2;                             % elevator area persentage
    de = -0/180*pi;                        % initial elevator angle [rad]
    max_de = 30/180*pi;                    % max abs of elevator angle [rad]
    htail = HTail(W_to,b,cla,s, t,xcRatio, e, it,tau, de, max_de);
    % Vertical Tail
    s = MCrandom(25);                        % area in ft^2
    b = MCrandom(6);                         % span in ft
    t = 0.12;                                % maximum thickness of wing over chord (t/c)m
    xcRatio = 0.3;                           % chordwise location of the airfoil maximum thickness point (x/c)m [Raymer 283]
    vtail = VTail(W_to,s,b,t, xcRatio);
    % Engine
    propD = 5;                               % propeller diameter [ft]
    engine = Engine(propD);
    
    % ============== init Aircraft ==============
    testUAV = AirCraft(W_to, fuselage,wing,fuelSys, htail,vtail,engine);
    % Use the Following Flight Condition
    testUAV.AoA = 2/180*pi;
    testUAV.alt = 3300;
    testUAV.v = 150;
    testUAV.payloadWeight = 400;        % here the weight must be the payload the UAV is going to pickup
    % Use the Following Layout
    % Easy-Layout
    FuselageNosetoWingFrontRatio = MCrandom(0.3);
    TailtoFuselageFrontRatio = 0.92;
    FueltoFuselageFrontRatio = MCrandom(0.35);
    PayloadtoFuselageFrontRatio = MCrandom(0.16);
    
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
    
    % ============== test Aircraft ==============
    
    % Fail Reason code list
    % 0. All meet
    % 1. v_stall not meet
    % 2. range not meet
    % 3. endurance not meet
    % 4. climb rate not meet
    % 5. pickup moment not meet
    
    result = windTunnel(testUAV,WorldConstants,Spec);
    
    if (result.StallSpeed >= Spec.StallSpeed)
        Record = struct( ...
            'airCraft', testUAV, ...
            'result', result, ...
            'failReason', 1 ...
            );
        failed = [failed, Record];
    elseif (result.Range < Spec.Range * 2)
        Record = struct( ...
            'airCraft', testUAV, ...
            'result', result, ...
            'failReason', 2 ...
            );
        failed = [failed, Record];
    elseif (result.Endurance < Spec.Endurance * 2)
        Record = struct( ...
            'airCraft', testUAV, ...
            'result', result, ...
            'failReason', 3 ...
            );
        failed = [failed, Record];
    elseif (result.ClimbRate < Spec.ClimbRate)
        Record = struct( ...
            'airCraft', testUAV, ...
            'result', result, ...
            'failReason', 4 ...
            );
        failed = [failed, Record];
    elseif (result.PickupMoment < 0)
        Record = struct( ...
            'airCraft', testUAV, ...
            'result', result, ...
            'failReason', 5 ...
            );
        failed = [failed, Record];
    else
        Record = struct( ...
            'airCraft', testUAV, ...
            'result', result, ...
            'failReason', 0 ...
            );
        good = [good, Record];
    end
    
    
    
end
% clean Workspace
clearvars -except good failed iterationN WorldConstants Spec

