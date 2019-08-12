function [ RMSE ] = TE_RMSE( x, TEC, ExpData )
%% calculate the RMSE between predicted and experimental results
%  notes of I/O arguments
%  x       - (i double array) [HTCoefficient GeomFactor] of thermocouples
%  TEC     - (i struction) initial parameters of thermocouples,
%                          ref. to "TE_ImportExpData.m"
%  ExpData - (i table) experimental results, ref. to "TE_ImportExpData.m"
%  RMSE    - (o double scalar) norm(exp-sim)
%
%  by Dr. Guan Guoqiang @ SCUT on 2019-08-09
%
%% function body
% initialize
QH  = zeros(size(ExpData.QH));
QC  = zeros(size(ExpData.QC));
COP = zeros(size(ExpData.QC));
% reset TEC according to the given x
switch length(x)
    case 1 % x = GeomFactor
        TEC.GeomFactor = x;
    case 2 % x = [NumRatio GeomFactor]
        TEC.HTCoefficient = x(1);
        TEC.GeomFactor    = x(2);
end
% calculate the number of thermocouples in the first stage of 2-stage TEC
N0 = TEC.NumTC/(TEC.NumRatio+1); 
%
% 计算理论吸、放热量
NumExpData = height(ExpData);
for i = 1: NumExpData
    % calculate the hot and cold junction temperatures
    T = TE_JunctionT(ExpData.TH(i), ExpData.TC(i), ExpData.I(i), TEC);
    Th = T(1); Tc = T(2);
    % 计算电流上下边界
    IBound = TE_Current(Th, Tc, TEC, 1);
    IMax = max(IBound);
    IMin = min(IBound);
    % 判定实验测得电流是否在理论范围
    if (ExpData.I(i) > IMax || ExpData.I(i) < IMin)
        fprintf('Given current %5.3f is out of range [%5.3f %5.3f]!\n', ...
                ExpData.I(i), IMin, IMax);
        return;
    end
    [Q, ~] = TE_Heat(Th, Tc, ExpData.I(i), TEC);
    QH(i) = Q(1);
    QC(i) = Q(2);
    COP(i) = QC(i)./(QH(i)-QC(i));
end
COP_exp = ExpData.QC./(ExpData.QH-ExpData.QC);
RMSE = norm(COP_exp-COP);
%
end

