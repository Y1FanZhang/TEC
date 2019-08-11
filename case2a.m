%% optimize geometry factor of thermocouple for 2-stage serial TEC
% 
% by Dr. Guan Guoqiang @ SCUT on 2019-08-11
%
clear;
% import data from text file "ExpData.txt"
fprintf('Import data from "ExpData.txt" ... \n');
tic
TE_ImportExpData
ExpData.TH = ExpData.TH+273.15;
ExpData.TC = ExpData.TC+273.15;
% initialize TEC parameters
TEC = struct('NumTC', 190, 'NumRatio', 1, 'GeomFactor', 8e-4);
% ��ʱ
toc
% ��ʹ������ӽ�ʵ�������ȵ�ż��������GF
fprintf('Calculating norm(COP(QC)_exp-COP(QC)_sim) ... \n');
[GF, RMSE, exitflag] = fminsearch(@(GF)TE_RMSE(GF, TEC, ExpData), ...
                                  TEC.GeomFactor);
TEC.GeomFactor = GF;
% ��ʱ
toc
% �������
clear N0;
% ���
TE_ShowDiff;