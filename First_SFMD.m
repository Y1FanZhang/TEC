function [FactorsOutcome] = First_SFMD(FactorsTable)
%% Calculate the unit energy consumption of each test from the full factors test table on 1-SFMD
%
% by Zhang Yifan on 2020-5-31
%
%%���ù��ñ������壬���а���DuctGeom���������γߴ磩��Stream�����϶��壩��MembrProps��Ĥ�������ʣ�
CommonDef
%%
factorstable = table2array(FactorsTable);
rank = zeros(2^8,1);
for i =1:2^8
% �Ա������и�ֵ
   Factors = factorstable(i,:);
    Tfi = Factors(1);  Tpi = Factors(2);
    qfi = Factors(3);  qpi = Factors(4);
    I1  = Factors(5);  I2  = Factors(6);
    Tc0 = Factors(7);  Th0 = Factors(8);
% Ĥ����Ȳ���ϳ�ʼ��
    SInFeed = Stream;
    SInFeed.Temp = Tfi;
    SInFeed.MassFlow = qfi;
% calculate the rest properties of feed-side influent
    SInFeed = DCMD_PackStream(SInFeed);
% Ĥ��������ϳ�ʼ��
   SInPerm = Stream;
   SInPerm.Temp = Tpi;
   SInPerm.MassFlow = qpi;
% calculate the rest properties of permeate-side influent
   SInPerm = DCMD_PackStream(SInPerm);
% �趨Ĥ��������
   Membrane = MembrProps;  
% set properties for all TECs
   load('C:\Users\dell\Desktop\�����ȱö༶DCMD\���뱸��\G.Teacher\TEC-5.0\TEC_Params.mat') % �������е�TEC�������
   TECs(1:2) = TEC_Params.TEC(3,1); % ע�ⰴopt=0����TEC����������
   TECs(1).Current = I1;
   TECs(2).Current = I2;
% �趨����Ĥ����е��ڲ��¶ȷֲ����Ȳ�TEC�����¶ȡ��Ȳ������¶ȡ��Ȳ�Ĥ���¶ȡ����Ĥ���¶ȡ���������¶ȡ����TEC�����¶ȣ�
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