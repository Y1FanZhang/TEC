%% �Ӱ뵼������Ƭ�����ܲ���ʵ���������TEC����
%
% by Dr. GUAN Guoqiang @ SCUT on 2020-03-27
%
%  References
%  [1] Xuan X C, et al. Cryogenics, 2002, 42: 273-278.
%  [2] Huang B J, et al. International Journal of Refrigeration 2000, 23(3): 208-218.
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
% ������������Ҫִ�е��Ż�����
opt = input(' 0 - Optimize (r g) values according to https://doi.org/10.1016/S0011-2275(02)00035-8\n 1 - Optimize (a R K) values according to https://doi.org/10.1016/S0140-7007(99)00046-8\n Input 0 or 1 to select corresponding method to get the TEC parameters: ');
% �趨�Ż������ĳ�ֵ
switch opt
    case(0) % �Ż�r��gֵ�����ο�����[1]
        opt1a = input('Input type of TEC (1) one-stage or (2) two-stage: ');
        switch opt1a
            case(1)
                TE_log('Given TEC type is one stage');
                TEC.NumRatio = 0;
                x0 = TEC.GeomFactor;
            case(2)
                TE_log('Given TEC type is two stages');
                x0 = [TEC.NumRatio,TEC.GeomFactor];
            otherwise
                TE_log('Given TEC type is unknown', 1);
                return
        end
    case(1) % �Ż�(a R K)ֵ�����ο�����[2]
        opt2a = input('Input polynomial order to correlate the (a R K) values: ');
        x0 = ones(3, opt2a+1);
        x0(:,2:(opt2a+1)) = 0;
    otherwise
        prompt = sprintf('Unknown running mode of %d in case_GetTECParams.m', opt);
        TE_log(prompt, 1);
        return
end
% �����Ż�����
options = optimset('PlotFcns', @optimplotfval);
% ����Ŀ�꺯��
fun = @(x)(TE_RMSE(x, TEC, ExpData, opt));
% ����Ż�����
x = fminsearch(fun, x0, options);
%
%% ������
[~,output] = fun(x);
% ����TEC������
output.pid = input('Input TEC part no.: ', 's');
% �����Ż�����
output.opt = opt;
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