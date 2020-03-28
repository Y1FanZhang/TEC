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
             'ThermConductance', [], 'Voltage', [], 'Current', []);
% �뵼������Ƭ�����ܲ���ʵ������
% ��ʵ�������ļ�ExpData.txt�е��룬ʵ�����ݴ��ڹ����ռ�ı����ExpData��
TE_ImportExpData
%
%% �Ż�
% ������ֵ
x0 = [TEC.NumRatio,TEC.GeomFactor];
% �����Ż�����
options = optimset('PlotFcns', @optimplotfval);
% ����Ŀ�꺯��
f = @(x)(TE_RMSE(x,TEC,ExpData));
% ����Ż�����
x = fminsearch(f, x0, options);
%% ������
output = f(x);
output.results