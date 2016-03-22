classdef GraphTool
    %Graph 
    
    properties (Access = private)
        AirCraft;
        WorldConstants;
        Spec;
        v;
    end
    
    methods
        % constructor
        function gt = GraphTool(ac,wc,Spec,v)
           gt.AirCraft = ac;
           gt.WorldConstants = wc;
           gt.v = v;
           gt.Spec = Spec;
        end
        
        
        %graphing methods        
% ===> Draw Trim AoA/elevatorAngle vs. Speed <===
        function drawTrimVsVelocity (gt)
        aoa = [];
        eleAngle = [];
        for i = 1:length(gt.v)
            gt.AirCraft.v = gt.v(i);
            [aoa1_,eleAngle_]=gt.AirCraft.elevatorToTrim(gt.WorldConstants);
            aoa = [aoa, aoa1_];
            eleAngle = [eleAngle, eleAngle_];
        end
        figure;
        plot(gt.v, aoa/pi*180, gt.v, eleAngle/pi*180);
        axis([gt.v(1) gt.v(end) -inf inf])
        grid minor;
        title('Trim AoA/Elevator Angle Vs. Speed');
        xlabel('Trim speed [ft/s]');
        ylabel('Degree');
        legend('AoA', 'elevator')
        end
        
%           ===> Draw Drag force vs. speed <===        
        function drawDragVsVelocity (gt)
            cdps = [];
            cdis = [];
            drags = [];
            for i = 1:length(gt.v)
                gt.AirCraft.v = gt.v(i);
                [AoA,eleAngle]=gt.AirCraft.elevatorToTrim(gt.WorldConstants);
                gt.AirCraft.AoA = AoA;
                gt.AirCraft.hTail.de = eleAngle;
                [cdp,cdi,cd]=getCd(gt.AirCraft,gt.WorldConstants);
                cdps = [cdps, (1/2* gt.WorldConstants.AirDensity * gt.AirCraft.wing.s * cdp * gt.v(i)^2)];
                cdis = [cdis, (1/2* gt.WorldConstants.AirDensity * gt.AirCraft.wing.s * cdi * gt.v(i)^2)];
                drags = [drags, (1/2* gt.WorldConstants.AirDensity * gt.AirCraft.wing.s * cd * gt.v(i)^2)];
            end
            vStallx = [gt.Spec.StallSpeed-0.1,gt.Spec.StallSpeed];
            vCruisingx = [gt.Spec.CruisingSpeed-0.1,gt.Spec.CruisingSpeed];
            yRange = [min([cdps,cdis]),max(drags)];
            
            figure;
            plot (gt.v,cdps, gt.v,cdis, gt.v,drags)
            hold on
            plot (vStallx,yRange,'--');
            plot (vCruisingx,yRange,'--');
            hold off
            grid minor;
            title('Drag force vs. speed');
            xlabel('Velocity (ft/s)');
            ylabel('Drag (lbf)');
            axis([gt.v(1) gt.v(end) -inf inf]);
            legend('parasite drag', 'induced drag', 'total drag','Stall Speed Requirement','Cruising Speed')
        end
        
        function drawPowerVsVelocity(gt)
            % ===> Draw power required vs. speed <===
            drags = [];
            p_av = [];
            p_cruise = [];
            [~,~,~,cruiseThrottle] = gt.AirCraft.cruise(gt.WorldConstants, gt.Spec);
            cruiseRPM = gt.AirCraft.engine.getRPMByThrottle(cruiseThrottle);
            for i = 1:length(gt.v)
                gt.AirCraft.v = gt.v(i);
                [AoA,eleAngle]=gt.AirCraft.elevatorToTrim(gt.WorldConstants);
                gt.AirCraft.AoA = AoA;
                gt.AirCraft.hTail.de = eleAngle;
                [~,~,cd]=getCd(gt.AirCraft,gt.WorldConstants);
                drags = [drags, (1/2* gt.WorldConstants.AirDensity * gt.AirCraft.wing.s * cd * gt.v(i)^2)];
                p_av = [p_av, gt.AirCraft.engine.getPowerByRPM(5800) * gt.AirCraft.engine.N * gt.AirCraft.getPropellerEfficiencyByRPM(5800)];
            end
            p_req = drags .* gt.v;
            figure;
            convertFactor = .0018181818;
            plot (gt.v,p_req * convertFactor , gt.v, p_av * convertFactor, '--')
            axis([gt.v(1) gt.v(end) -inf inf]);
            grid minor;
            title('Power Required vs. Speed');
            xlabel('Velocity (ft/s)');
            ylabel('power (HP)');
            legend('power required ','power available')
        end
        
        function drawClVsCd(gt)
            % ===> Draw Cl/Cd <===
            clcd = [];
            aoa = [];
            for i = 1:length(gt.v)
                gt.AirCraft.v = gt.v(i);
                [AoA,eleAngle]=gt.AirCraft.elevatorToTrim(gt.WorldConstants);
                gt.AirCraft.AoA = AoA;
                gt.AirCraft.hTail.de = eleAngle;
                [~,~,Cd] = getCd(gt.AirCraft,gt.WorldConstants);
                aoa = [aoa, AoA];
                clcd = [clcd, gt.AirCraft.getCl/Cd];
            end
            aoa = aoa /pi * 180;
            figure
            plot (gt.v, clcd);
            grid minor;
            title('Cl/Cd Vs. Speed');
            xlabel('Velocity (ft/s)');
            ylabel('Cl/Cd');
            figure
            plot (aoa, clcd);
            grid minor;
            title('Cl/Cd Vs. Angle of attack');
            xlabel('Angle of attack [degree]');
            ylabel('Cl/Cd');
        end
    end
    
end

