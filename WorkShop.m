function [ ] = WorkShop( sample )
% Drow layout diagram
chord = sample.airCraft.wing.getChord;

% wing
x = -sample.airCraft.fuselage.D/2;
y = 0;
x = [x, -sample.airCraft.wing.b/2 - sample.airCraft.fuselage.D];
y = [y, -sample.airCraft.wing.getChordRoot*(1-sample.airCraft.wing.Taper)/2];
x = [x, -sample.airCraft.wing.b/2 - sample.airCraft.fuselage.D];
y = [y, -sample.airCraft.wing.getChordRoot*(1-sample.airCraft.wing.Taper)/2 - sample.airCraft.wing.getChordRoot*sample.airCraft.wing.Taper];
x = [x, -sample.airCraft.fuselage.D/2];
y = [y, -sample.airCraft.wing.getChordRoot];
x = [x, -fliplr(x)];
y = [y, fliplr(y)];
f = figure('Position', [100, 100, 800, 600]);
subplot(3,1,[1 2]);
fill(x,y,'b');
axis equal
hold on

% horizontal tail
y0 = -sample.airCraft.h_act * chord;

x = -sample.airCraft.fuselage.D/2;
y = y0 + 0.5*sample.airCraft.hTail.getChordRoot;
x = [x, -sample.airCraft.hTail.b/2 - sample.airCraft.fuselage.D];
y = [y, y0 + 0.5*sample.airCraft.hTail.getChordRoot - sample.airCraft.hTail.getChordRoot*(1-sample.airCraft.hTail.Taper)/2];
x = [x, -sample.airCraft.hTail.b/2 - sample.airCraft.fuselage.D];
y = [y, y0 + 0.5*sample.airCraft.hTail.getChordRoot - sample.airCraft.hTail.getChordRoot*(1-sample.airCraft.hTail.Taper)/2 - sample.airCraft.hTail.getChordRoot*sample.airCraft.hTail.Taper];
x = [x, -sample.airCraft.fuselage.D/2];
y = [y, y0-sample.airCraft.hTail.getChordRoot/2];
x = [x, -fliplr(x)];
y = [y, fliplr(y)];
fill(x,y,'b');

% fuselage
y0 = -sample.airCraft.h_fuselage * chord;
x = sample.airCraft.fuselage.D/2;
y = y0 + sample.airCraft.fuselage.L/2;
x = [x, -sample.airCraft.fuselage.D/2];
y = [y, y0 + sample.airCraft.fuselage.L/2];
x = [x, -sample.airCraft.fuselage.D/2];
y = [y, y0 - sample.airCraft.fuselage.L/2];
x = [x, sample.airCraft.fuselage.D/2];
y = [y, y0 - sample.airCraft.fuselage.L/2];
fill(x,y,'b');

% vertical Tail
y0 = -sample.airCraft.h_acvt * chord;
x = -sample.airCraft.vTail.getChord * sample.airCraft.vTail.tcRatio/2;
y = y0 + 0.5*sample.airCraft.vTail.getChordRoot;
x = [x, -sample.airCraft.vTail.getChord * sample.airCraft.vTail.tcRatio/2];
y = [y, y0 - 0.5*sample.airCraft.vTail.getChordRoot];

x = [x, -fliplr(x)];
y = [y, fliplr(y)];
fill(x,y,'r');

% cabin
width = sample.airCraft.fuselage.D - 1;
length = 8;
y0 = -sample.airCraft.h_payload * chord;
x = -width/2;
y = y0 + length/2;
x = [x, - width/2];
y = [y, y0 - length/2];
x = [x, -fliplr(x)];
y = [y, fliplr(y)];
fill(x,y,'g');

% Fuel System
y0 = -sample.airCraft.h_fuelSys * chord;
dia = sample.airCraft.fuselage.D - 2;
length = sample.airCraft.fuelSys.getFuelVolume/(pi*dia^2/4);
x = -dia/2;
y = y0 + length/2;
x = [x, -dia/2];
y = [y, y0 - length/2];
x = [x, -fliplr(x)];
y = [y, fliplr(y)];
fill(x,y,'y');
legend('Wing','Fuselage','Horizontal Tail','Vertical Tail','Cabin','Fuel Tank');


% ==================== Table ====================
% create the data
d = [...
    round(sample.result.StallSpeed*0.686818,2);...
    round(sample.result.Range*0.000189394,2);...
    round(sample.result.Endurance/3600,2);...
    round(sample.result.ClimbRate,2);...
    round(sample.result.PickupMoment,2);...
    round(sample.result.Weight,2)...
    ];
% Create the column and row names in cell arrays 
cnames = {'Value'};
rnames = {'StallSpeed[MPH]','Range[Mile]','Endurance[h]','ClimbRate[ft/s]','PickupMoment[lbf*ft]','Weight[lbm]'};
% Create the uitable
t = uitable(f,'Data',d,...
            'ColumnName',cnames,... 
            'RowName',rnames);
% Set width and height
t.Position(1) = 75;
t.Position(2) = 10;
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);

d = [...
    round(sample.airCraft.wing.s);...
    round(sample.airCraft.fuselage.L);...
    round(sample.airCraft.hTail.s);...
    ];
% Create the column and row names in cell arrays 
cnames = {'Value'};
rnames = {'Wing Area[ft^2]','fuselage Length[ft]','HTail Area[ft^2]'};
% Create the uitable
t2 = uitable(f,'Data',d,...
            'ColumnName',cnames,... 
            'RowName',rnames);
% Set width and height
t2.Position(1) = 400;
t2.Position(2) = 10;
t2.Position(3) = t2.Extent(3);
t2.Position(4) = t2.Extent(4);
hold off
end

