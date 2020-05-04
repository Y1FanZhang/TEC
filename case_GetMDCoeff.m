%% �ع�DCMD���̼��������Ĥ����ϵ����
%
% ����˵��
% ��1������ʵ������
% ��2���ع�Ĥ����ϵ��
%  ����DCMD���������TEC��Ϊ���Ƶľ��ȱ��棩������Ӧʵ���趨�����µ�Ĥ��������¶ȺͲ�ˮ��
%
% by Dr. Guan Guoqiang @ SCUT on 2020-05-02
%

%% ��ʼ��
% �������ݽṹ
CommonDef
% ����DCMDʵ������
import_DCMD_ExpData
ExpData = ExpData_raw(1:11,[9 10 11 12 13 15 17 19 21 23]);
% ��ʵ�������е��¶ȵ�λת��ΪK
ExpData.TF_IN = ExpData.TF_IN+273.15;
ExpData.TP_IN = ExpData.TP_IN+273.15;
ExpData.TF_OUT = ExpData.TF_OUT+273.15;
ExpData.TP_OUT = ExpData.TP_OUT+273.15;
% ��ʵ�������еĲ�ˮ�ʵ�λת��Ϊkg/s
ExpData.WP = ExpData.WP/1000;
% �趨����TEC�༶DCMDϵͳ�ļ���
NumStage = 1;
% set properties for all TECs
load('TEC_Params.mat') % �������е�TEC�������
% �趨TEC�������Ϊ0��TEC����ϵ��Ϊ��С��ֵ�Դ˽�TEC����Ϊ���ȱ���
TEC_Params.TEC(3,1).Voltage = 0;
TEC_Params.TEC(3,1).Current = 0;
TEC_Params.TEC(3,1).ThermConductance = 1e-8;
TECs(1:(NumStage+1)) = TEC_Params.TEC(3,1); % ע�ⰴopt=0����TEC����������
% �趨���Ȳ�TEC�Ļ����¶ȷֱ��Ϊ298.15K
TEXs = [298.15; 298.15];
% ���������
TSH = zeros(height(ExpData),1);
TH = zeros(size(TSH));
TMH = zeros(size(TSH));
TMC = zeros(size(TSH));
TC = zeros(size(TSH));
TSC = zeros(size(TSH));
WP_Sim = zeros(size(TSH));

%% ˳������ʵ�����������µ�ģ��������¶ȺͲ�ˮ��
for i = 1:height(ExpData)
    % Ĥ����Ȳ���ϳ�ʼ��
    T1 = ExpData.TF_IN(i); T2 = ExpData.TP_IN(i);
    SInFeed = Stream;
    SInFeed.Temp = T1;
    SInFeed.MassFlow = ExpData.QF_IN(i)*1e-3; % ע�����ｫ��Һ�ܶȽ���Ϊ1e-3 kg/mL
    % calculate the rest properties of feed-side influent
    SInFeed = DCMD_PackStream(SInFeed);
    % �趨����Ĥ����Ȳ����
    SInFeeds(1:NumStage) = SInFeed;
    % Ĥ��������ϳ�ʼ��
    SInPerm = Stream;
    SInPerm.Temp = T2;
    SInPerm.MassFlow = ExpData.QP_IN(i)*1e-3; % ע�����ｫ��͸Һ�ܶȽ���Ϊ1e-3 kg/mL
    % calculate the rest properties of permeate-side influent
    SInPerm = DCMD_PackStream(SInPerm);
    % �趨����Ĥ���������
    SInPerms(1:NumStage) = SInPerm;
    % �趨����Ĥ��������
    Membranes(1:NumStage) = MembrProps;
    % �趨����Ĥ����е��ڲ��¶ȷֲ����Ȳ�TEC�����¶ȡ��Ȳ������¶ȡ��Ȳ�Ĥ���¶ȡ����Ĥ���¶ȡ���������¶ȡ����TEC�����¶ȣ�
    for j=1:NumStage
        T0((1+(j-1)*6):6*j) = [T1+1; T1; T1-1; T2+1; T2; T2-1];
    end
    % �����������ƽ���ģ����¶ȣ��ȡ����ı����¶ȡ������¶Ⱥ�Ĥ���¶ȣ�
    opts = optimoptions('fsolve', 'Display', 'None', 'MaxFunEvals', 15000, 'MaxIter', 1000);
    fun = @(T)DCMD_EqSys(T, TEXs, TECs, SInFeeds, SInPerms, Membranes);
    [T, fvals, exitflag] = fsolve(fun, T0, opts);
    % ����DCMDĤ����еĴ��ȡ�������
    [~, Q, QM, SM, SOutFeeds, SOutPerms] = fun(T);
    % �����¶�����
    TOut = reshape(T, [6,length(SM)]); % Temperature profiles of each stage
    TSH(i) = TOut(1,:)';
    TH(i)  = TOut(2,:)';
    TMH(i) = TOut(3,:)';
    TMC(i) = TOut(4,:)';
    TC(i)  = TOut(5,:)';
    TSC(i) = TOut(6,:)';
    % �����ˮ��
    WP_Sim(i) = sum([SM.MassFlow]);
end

%% Output results
format short g
tabout = [ExpData(:,{'TF_OUT', 'TP_OUT', 'WP'}),table(TH, TC, WP_Sim)];
disp(tabout)
fprintf('RMS of relative errors in TF, TP and WP are %f, %f and %f, respectively\n', ...
rms((tabout.TF_OUT-tabout.TH)./tabout.TF_OUT), ...
rms((tabout.TP_OUT-tabout.TC)./tabout.TP_OUT), ...
rms((tabout.WP-tabout.WP_Sim)./tabout.WP))
% ����ʵ����ģ���ƫ��ͼ��ɢ�������Ϊʵ������������Ϊģ��ֵ��ɢ����Խ��ߵľ������ʵ����ģ���ƫ�ƫ��ԽС����Խ����
figure
WP_max = max([tabout.WP;tabout.WP_Sim]);
WP_min = min([tabout.WP;tabout.WP_Sim]);
plot(tabout.WP, tabout.WP_Sim, 'o', [WP_min,WP_max], [WP_min,WP_max], '--r')
ax1 = gca;
ax1.XLim = [WP_min,WP_max];
ax1.YLim = [WP_min,WP_max];