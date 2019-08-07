function [I, Q] = TE_Current(Th, Tc, N, r, opt)
%% Calculate current according hot- and cold-side temperatures
%  notes of I/O arguments
%  Th - (i double scalar) hot-side temperature [K]
%  Tc - (i double scalar) cold-side temperature [K]
%  N  - (i double scalar) number of thermocouples in the first stage
%  r  - (i double scalar) number ratio of thermocouples in two stages
%  opt- (i optional integer scalar) running mode
%       0: (default) theoretical current to make E = I^2*R
%       1: minimal current to make Qc = 0
%  I  - (o double scalar) serial electric current flowing through the two
%                         stages [A]
%  Q  - (o double array(2)) heats flowing out/in the hot/cold side of TEC
%
%  by Dr. Guan Guoqiang @ SCUT on 2019-08-06
%
%% function body
% default argument of input opt
if nargin < 5
    opt = 0;
end
switch opt
    case 0
        % initialize
        I = 1;
        dI = 1;
        % �Բ�������
        while dI > 1e-5
            % ��������������
            [Q, ~, R, ~] = TE_Heat(Th, Tc, I, N, r);
            % ��������繦
            E = Q(1)-Q(2);
            % ������� 
            I_calc = sqrt(E/(R(1)*N+R(2)*N*r));
            dI = abs(I-I_calc);
            I = I_calc;
        end
    case 1
        syms I;
        % intialize
        Tm = (Th+Tc)/2.d0;
        dTm = 1e5;
        while dTm > 1e-5
            % �����ȵ�ż����
            % calculate a2 R2 K2
            [a2, R2, K2] = TE_MaterialProp((Tc+Tm)/2, 0.0015);
            % define heat balance equations
            eq4 = 0 == (I*a2*Tc-I^2*R2/2-K2*(Tm-Tc))*N;
            % �������
            current = eval(solve(eq4, I));
            dTm_vec = zeros(size(current));
            % ����Tm
            for i = 1:length(current)
                dTm_vec(i) = TE_Tm(Th, Tc, current(i), r)-Tm;       
            end
            [dTm, MinIdx] = min(abs(dTm_vec));
            Tm = Tm+dTm_vec(MinIdx);
        end
        % �����������
        I = current;
    otherwise
        fprintf('[ERROR] Invalid input argument!\n');
        return
end
%
end
