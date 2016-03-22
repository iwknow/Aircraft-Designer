clear
clc
close all

mph = [100 160];          
rpm = [4500 5000];
bhp = [50 200];
rho = 0.0019;
rho0 = 0.00238;

Cs = (0.638.*mph.*(rho/rho0).^(1/5))./(bhp).^(1/5)./(rpm).^(2/5);

D = 3.9; %ft



