%% TEC��������ʽ�Ƶ�
%
% by Dr. Guan Guoqiang @ SCUT on 2020-04-07
%
% �ο�����
% Chen L et al. Applied Energy, 2008, 85: 641-649 [doi:10.1016/j.apenergy.2007.10.005]
%
%% ��ʼ��
clear
syms QH QL k1 F1 T1 Th k2 F2 Tc T2
eq1 = QH == k1*F1*(T1-Th);
eq2 = QL == k2*F2*(Tc-T2);
syms Qm m n a I R K Tm
eq3 = QH == n*(a*I*T1+0.5*I^2*R-K*(T1-Tm));
eq4 = Qm == n*(a*I*Tm-0.5*I^2*R-K*(T1-Tm));
eq5 = Qm == m*(a*I*Tm+0.5*I^2*R-K*(Tm-T2));
eq6 = QL == m*(a*I*T2-0.5*I^2*R-K*(Tm-T2));
% ����ʽ(7)
eq7 = solve(rhs(eq4) == rhs(eq5), Tm);
% ʽ(8)��(9)
eq8 = rhs(eq1) == rhs(eq3);
eq9 = rhs(eq2) == rhs(eq6);
% ����ʽ(10)��(11)
[eq10,eq11] = solve([subs(eq8, Tm, eq7),subs(eq9, Tm, eq7)], [T1 T2]);
% ����ʽ(12)��(13)
eq12 = subs(eq1, T1, eq10);
eq13 = subs(eq2, T2, eq11);