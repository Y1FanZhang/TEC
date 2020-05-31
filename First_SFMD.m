function [FactorsOutcome] = First_SFMD(FactorsTable)
%% Calculate the unit energy consumption of each test from the full factors test table on 1-SFMD
%
% by Zhang Yifan on 2020-5-31
%
%%调用公用变量定义，其中包括DuctGeom（流道几何尺寸）、Stream（物料定义）、MembrProps（膜材料性质）
CommonDef
%%
factorstable = table2array(FactorsTable);
rank = zeros(2^8,1);
for i =1:2^8
% 对变量进行赋值
   Factors = factorstable(i,:);
    Tfi = Factors(1);  Tpi = Factors(2);
    qfi = Factors(3);  qpi = Factors(4);
    I1  = Factors(5);  I2  = Factors(6);
    Tc0 = Factors(7);  Th0 = Factors(8);
% 膜组件热侧进料初始化
    SInFeed = Stream;
    SInFeed.Temp = Tfi;
    SInFeed.MassFlow = qfi;
% calculate the rest properties of feed-side influent
    SInFeed = DCMD_PackStream(SInFeed);
% 膜组件冷侧进料初始化
   SInPerm = Stream;
   SInPerm.Temp = Tpi;
   SInPerm.MassFlow = qpi;
% calculate the rest properties of permeate-side influent
   SInPerm = DCMD_PackStream(SInPerm);
% 设定膜材料特性
   Membrane = MembrProps;  
% set properties for all TECs
   load('C:\Users\dell\Desktop\集成热泵多级DCMD\代码备份\G.Teacher\TEC-5.0\TEC_Params.mat') % 载入已有的TEC计算参数
   TECs(1:2) = TEC_Params.TEC(3,1); % 注意按opt=0计算TEC的吸放热量
   TECs(1).Current = I1;
   TECs(2).Current = I2;
% 设定单级膜组件中的内部温度分布（热侧TEC壁面温度、热侧主体温度、热侧膜面温度、冷侧膜面温度、冷侧主体温度、冷侧TEC壁面温度）
   T0(1:6) = [Tfi+1; Tfi; Tfi-1; Tpi+1; Tpi; Tpi-1];
% set temperature as the environmental temperature of both heat source and sink
   TEXs = [Tc0; Th0];
%%Solve temperatures
opts = optimoptions('fsolve', 'Display', 'Iter', 'MaxFunEvals', 15000, 'MaxIter', 1000);
fun = @(T)DCMD_EqSys(T, TEXs, TECs, SInFeed, SInPerm, Membrane);
[T, fvals, exitflag] = fsolve(fun, T0, opts);
[~, Q, QM, SM, SOutFeeds, SOutPerms] = fun(T);
%% Calculate the energy efficiency
% Energy consumption of TECs
EC = Q(:,1)-Q(:,2);
% Specific energy consumption (wh*kg)
WP_Sum = sum([SM.MassFlow]);
SEC = sum(EC)/WP_Sum/3600;
rank(i)=SEC;
end
output=[factorstable,rank];
FactorsOutcome_cell=num2cell(output);
FactorsOutcome=cell2table(FactorsOutcome_cell);
Namecolumns={'Tfi','Tpi','qfi','qpi','I1','I2','Tc0','Th0','SEC'};
FactorsOutcome.Properties.VariableNames=(Namecolumns);