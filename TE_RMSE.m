function [ RMSE ] = TE_RMSE( GF, TEC, ExpData )
%% calculate the RMSE between predicted and experimental results
%  notes of I/O arguments
%  GF      - (i double scalar) optimizing geometry factor of thermocouples
%  TEC     - (i struction) initial parameters of thermocouples,
%                          ref. to "TE_ImportExpData.m"
%  ExpData - (i table) experimental results, ref. to "TE_ImportExpData.m"
%  dQc     - (o double scalar) RMSE(QC-ExpData.QC)
%
%  by Dr. Guan Guoqiang @ SCUT on 2019-08-09
%
%% function body
% initialize
QC  = zeros(size(ExpData.QC));
%
TEC.GeomFactor = GF;
% calculate the number of thermocouples in the first stage of 2-stage TEC
N0 = TEC.NumTC/(TEC.NumRatio+1); 
% 计算理论吸、放热量
NumExpData = height(ExpData);
for i = 1: NumExpData
    % 计算电流上下边界
    IBound = TE_Current(ExpData.TH(i), ExpData.TH(i), N0, ...
                        TEC.NumRatio, TEC.GeomFactor, 1);
    IMax = max(IBound);
    IMin = min(IBound);
    % 判定实验测得电流是否在理论范围
    if (ExpData.I(i) > IMax || ExpData.I(i) < IMin)
        fprintf('Given current %5.3f is out of range [%5.3f %5.3f]!\n', ...
                ExpData.I(i), IMin, IMax);
        return;
    end
    [Q, ~, ~, ~] = TE_Heat(ExpData.TH(i), ExpData.TC(i), ExpData.I(i), ...
                           N0, TEC.NumRatio, TEC.GeomFactor);
    QC(i) = Q(2)/N0/(TEC.NumRatio+1);
end
RMSE = MVA_diff(ExpData.QC/N0/(TEC.NumRatio+1), QC, 'RMSE');
end

