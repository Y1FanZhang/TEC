%% optimize geometry factor of thermocouple for 2-stage serial TEC
% 
% by Dr. Guan Guoqiang @ SCUT on 2019-08-06
%
clear;
% import data from text file "ExpData.txt"
fprintf('Import data from "ExpData.txt" ... \n');
tic
TE_ImportExpData
ExpData.TH = ExpData.TH+273.15;
ExpData.TC = ExpData.TC+273.15;
% initialize TEC parameters
TEC = struct('NumTC', 190, 'NumRatio', 1, 'GeomFactor', 3.8e-4);
% ��ʱ
toc
% calculate the RMSE of QC
fprintf('Calculating RMSE of dQH(exp-sim) ... \n');
% ��ʹ����QC��ӽ�ʵ�������ȵ�ż��������GF
[GF, RMSE, exitflag] = fminsearch(@(GF)TE_RMSE(GF, TEC, ExpData), 3.8e-4);
TEC.GeomFactor = GF;
% ��ʱ
toc
% �������
clear N0;
% ���
fprintf('RMSE of Qc = %5.3f\n', RMSE);
TE_ShowDiff;