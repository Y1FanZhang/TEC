%% 回归DCMD过程计算参数（膜蒸馏系数）
%
% 功能说明
% （1）载入实验数据
% （2）回归膜蒸馏系数
%  调用DCMD求解器（将TEC设为近似的绝热壁面）计算相应实验设定条件下的膜组件出口温度和产水率
%
% by Dr. Guan Guoqiang @ SCUT on 2020-05-02
%

%% 初始化
clear
% 回归变量初值
x0 = 3.2e-7;

%% 用实验数据回归计算膜蒸馏系数
% 导入实验数据
import_DCMD_ExpData
% 定义求解器参数
options = optimset('PlotFcns', @optimplotfval, 'MaxFunEvals', 1000*length(x0));
% 定义目标函数
fun = @(x)(DCMD_RMSE(x, ExpData));
% 获得优化参数
[x,fval,exitflag,optim_output] = fminsearch(fun, x0, options);

%% Output results
fprintf('Regressed MD coefficient is %.4e kg/m2-s-Pa\n', x)
format short g
[~,tabout] = DCMD_RMSE(x, ExpData);
disp(tabout)
fprintf('RMS of relative errors in TF, TP and WP are %f, %f and %f, respectively\n', ...
rms((tabout.TF_OUT-tabout.TH)./tabout.TF_OUT), ...
rms((tabout.TP_OUT-tabout.TC)./tabout.TP_OUT), ...
rms((tabout.WP-tabout.WP_Sim)./tabout.WP))
% 画出实验与模拟的偏差图（散点横坐标为实验结果而纵坐标为模拟值，散点与对角线的距离表征实验与模拟的偏差，偏差越小距离越近）
figure
WP_max = max([tabout.WP;tabout.WP_Sim]);
WP_min = min([tabout.WP;tabout.WP_Sim]);
plot(tabout.WP, tabout.WP_Sim, 'o', [WP_min,WP_max], [WP_min,WP_max], '--r')
ax1 = gca;
ax1.XLim = [WP_min,WP_max];
ax1.YLim = [WP_min,WP_max];
xlabel('WP_exp')
ylabel('WP_sim')

function [y,tabout] = DCMD_RMSE(x, ExpData)
    % 载入数据结构
    CommonDef
    % 设定集成TEC多级DCMD系统的级数
    NumStage = 1;
    % set properties for all TECs
    load('TEC_Params.mat') % 载入已有的TEC计算参数
    % 设定TEC输入电能为0、TEC导热系数为很小的值以此将TEC近似为绝热壁面
    TEC_Params.TEC(3,1).Voltage = 0;
    TEC_Params.TEC(3,1).Current = 0;
    TEC_Params.TEC(3,1).ThermConductance = 1e-8;
    TECs(1:(NumStage+1)) = TEC_Params.TEC(3,1); % 注意按opt=0计算TEC的吸放热量
    % 设定冷热侧TEC的环境温度分别均为298.15K
    TEXs = [298.15; 298.15];
    % 设定各级膜材料特性
    MembrProps.MDCoefficient = x;
    Membranes(1:NumStage) = MembrProps;    
    % 求解结果变量
    TSH = zeros(height(ExpData),1);
    TH = zeros(size(TSH));
    TMH = zeros(size(TSH));
    TMC = zeros(size(TSH));
    TC = zeros(size(TSH));
    TSC = zeros(size(TSH));
    WP_Sim = zeros(size(TSH));
    % 顺次求解各实验输入条件下的模组件出口温度和产水量
    for i = 1:height(ExpData)
        % 膜组件热侧进料初始化
        T1 = ExpData.TF_IN(i); T2 = ExpData.TP_IN(i);
        SInFeed = Stream;
        SInFeed.Temp = T1;
        SInFeed.MassFlow = ExpData.QF_IN(i)*1e-3; % 注意这里将料液密度近似为1e-3 kg/mL
        % calculate the rest properties of feed-side influent
        SInFeed = DCMD_PackStream(SInFeed);
        % 设定各级膜组件热侧进料
        SInFeeds(1:NumStage) = SInFeed;
        % 膜组件冷侧进料初始化
        SInPerm = Stream;
        SInPerm.Temp = T2;
        SInPerm.MassFlow = ExpData.QP_IN(i)*1e-3; % 注意这里将渗透液密度近似为1e-3 kg/mL
        % calculate the rest properties of permeate-side influent
        SInPerm = DCMD_PackStream(SInPerm);
        % 设定各级膜组件冷侧进料
        SInPerms(1:NumStage) = SInPerm;
        % 设定各级膜组件中的内部温度分布（热侧TEC壁面温度、热侧主体温度、热侧膜面温度、冷侧膜面温度、冷侧主体温度、冷侧TEC壁面温度）
        for j=1:NumStage
            T0((1+(j-1)*6):6*j) = [T1+1; T1; T1-1; T2+1; T2; T2-1];
        end
        % 求解满足能量平衡的模组件温度（热、冷侧的壁面温度、主体温度和膜面温度）
        opts = optimoptions('fsolve', 'Display', 'None', 'MaxFunEvals', 15000, 'MaxIter', 1000);
        fun = @(T)DCMD_EqSys(T, TEXs, TECs, SInFeeds, SInPerms, Membranes);
        [T, fvals, exitflag] = fsolve(fun, T0, opts);
        % 计算DCMD膜组件中的传热、传质量
        [~, Q, QM, SM, SOutFeeds, SOutPerms] = fun(T);
        % 整理温度向量
        TOut = reshape(T, [6,length(SM)]); % Temperature profiles of each stage
        TSH(i) = TOut(1,:)';
        TH(i)  = TOut(2,:)';
        TMH(i) = TOut(3,:)';
        TMC(i) = TOut(4,:)';
        TC(i)  = TOut(5,:)';
        TSC(i) = TOut(6,:)';
        % 计算产水量
        WP_Sim(i) = sum([SM.MassFlow]);
    end
    tabout = [ExpData(:,{'TF_OUT', 'TP_OUT', 'WP'}),table(TH, TC, WP_Sim)];
    rms_TF = rms((tabout.TF_OUT-tabout.TH)./tabout.TF_OUT);
    rms_TP = rms((tabout.TP_OUT-tabout.TC)./tabout.TP_OUT);
    rms_WP = rms((tabout.WP-tabout.WP_Sim)./tabout.WP);
    y = rms([rms_TF,rms_TP,rms_WP]);
end