%% �Ӱ뵼������Ƭ�����ܲ���ʵ���������TEC����
%
% by Dr. GUAN Guoqiang @ SCUT on 2020-03-27
%
%% ��ʼ��
clear;
% ���ݽṹ����
TEC = struct('NumTC', 190, 'NumRatio', 0.9, 'GeomFactor', 0.7e-3, ...
             'HTCoefficient', 270, 'HTArea', 0.0016, ...
             'SeebeckCoefficient', [], 'ElecConductance', [], ...
             'ThermConductance', [], 'Voltage', [], 'Current', [], ...
             'Parameters', []);
% �뵼������Ƭ�����ܲ���ʵ������
% ��ʵ�������ļ�ExpData.txt�е��룬ʵ�����ݴ��ڹ����ռ�ı����ExpData��
TE_ImportExpData
%
%% �Ż�
% ������ֵ
x0 = [TEC.NumRatio,TEC.GeomFactor];
x1 = [1,1,1;1,1,1;1,1,1];
% �����Ż�����
options = optimset('PlotFcns', @optimplotfval);
% ����Ŀ�꺯��
f0 = @(x)(TE_RMSE(x, TEC, ExpData, 0));
f1 = @(x)(TE_RMSE(x, TEC, ExpData, 1));
% ����Ż�����
x = fminsearch(f1, x1, options);
%% ������
[~,output] = f1(x);
% ����TEC������
output.pid = input('Input TEC part no.: ', 's');
% �����
current_tab = struct2table(output, 'AsArray', 1);
% ��ǰĿ¼����TEC�����ļ�ʱ�����TEC_Params
if exist('TEC_Params.mat', 'file') == 2
    load('TEC_Params.mat')
    TEC_Params = [TEC_Params;current_tab];
else
    TEC_Params = current_tab;
end
% �������
save('TEC_Params.mat', 'TEC_Params')