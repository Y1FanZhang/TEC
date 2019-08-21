%% Calculate temperatures of stacked DCMD module with TEHPs
%
% by Dr. GUAN, Guoqiang @ SCUT on 2019-08-19
%
%% Initialize
clear;
%  SInFeed - properties of feed-side influent
%           .Temp: temperature [K]
%           .MassFlow: mass flowrate [kg/s]
%           .Velocity: velocity [m/s]
%           .MassFraction: mass fraction of NaCl
%           .Density: density [kg/m3]
%           .Viscosity: dynamic viscosity [Pa-s]
%           .SpecHeat: specific heat [J/kg-K]
%           .ThermCond: thermal conductivity [W/m-K]
%           .Enthalpy: enthalpy [W]
SInFeed = struct('Temp', 323.15,     ...
                 'MassFlow', 0.015,  ...
                 'Velocity', 0.015*1e-3/(0.04*0.006),  ...
                 'MassFraction', 0,  ...
                 'Density', 1e3,     ...
                 'Viscosity', 1e-3,  ...
                 'SpecHeat', 4.18e3, ...
                 'ThermCond', 0.6,   ...
                 'Enthalpy', 0.015*4180*323.15);
SInPerm = struct('Temp', 303.15,     ...
                 'MassFlow', 0.015,  ...
                 'Velocity', 0.015*1e-3/(0.04*0.006),  ...
                 'MassFraction', 0,  ...
                 'Density', 1e3,     ...
                 'Viscosity', 1e-3,  ...
                 'SpecHeat', 4.18e3, ...
                 'ThermCond', 0.6,   ...
                 'Enthalpy', 0.015*4180*303.15);
%  MembrProps.TMH: hot-side temperature of membrane [K]
%            .TMC: cold-side temperature of membrane [K]
%            .Area: effective area of membrane [m2]
%            .Thickness: thickness of membrane [m]
%            .MDCoefficient: MD coefficient [kg/s-m2-Pa]
%            .ThermConductivity: thermal conductivity of membrane
MembrProps = struct('TMH', [], 'TMC', [], 'Area', 0.0016, ...
                    'Thickness', 1.5e-4, 'MDCoefficient', 3.2e-7, ...
                    'ThermConductivity', (0.18*0.3+0.025*0.7));
%  TEC.NumTC     : Number of thermocouples in TEC
%     .NumRatio  : ratio of thermocouples in the 1-stage TEC to those in
%                  the 2-stage TEC
%     .GeomFactor: geometry factor of thermcouples in TEC [m]
%     .HTCoefficient     : Overall heat transfer coefficient [W/m2-K]
%     .HTArea            : heat transfer area [m2]
%     .SeebeckCoefficient: Seebeck coefficient of 1 and 2 stage of TEC
%     .ElecConductance   : electrical conductance of 1 and 2 stage of TEC
%     .ThermConductance  : thermal conductance of 1 and 2 stage of TEC
%     .Voltage           : electrical voltage [V]
%     .Current           : electrical current [A]
TEC = struct('NumTC', 190, 'NumRatio', 0, 'GeomFactor', 3.8e-4, ...
             'HTCoefficient', 270, 'HTArea', 0.0016, ...
             'SeebeckCoefficient', [], 'ElecConductance', [], ...
             'ThermConductance', [], 'Voltage', 12, 'Current', 1);
TECs(1) = TEC; TECs(2) = TEC;
T0 = [322.1; 320.0; 303.6; 303.2];
TE = [298.15; 307.7307];
%% Solve temperatures
fun = @(T)DCMD_EqSys(T, TE, TECs, SInFeed, SInPerm, MembrProps);
[T, fvals, exitflag] = fsolve(fun, T0);
%% Calculate the energy efficiency
% COP of TECs
COP = zeros(size(TECs));
QH = zeros(size(TECs));
QC = zeros(size(TECs));
Q1 = TE_Heat(T(1), TE(1), TECs(1));
QH(1) = Q1(1); QC(1) = Q1(2);
COP(1) = QH(1)/(QH(1)-QC(1));
Q2 = TE_Heat(TE(2), T(4), TECs(2));
QH(2) = Q2(1); QC(2) = Q2(2);
COP(2) = QC(2)/(QH(2)-QC(2));
% Feed- and permeate-side effluents
[~, SOutFeed] = DCMD_EqF(T(2), T(3), T(1), TE(1), TECs(1), ...
                          SInFeed, SInPerm, MembrProps);
[~, SOutPerm] = DCMD_EqF(T(2), T(3), TE(2), T(4), TECs(2), ...
                          SInFeed, SInPerm, MembrProps);
% Water permeation
WF = SInFeed.MassFlow-SOutFeed.MassFlow;
% Specific energy consumption
SPC = (QH(1)-QC(1)+QH(2)-QC(2))/WF;