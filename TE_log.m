%% ��־��¼
%  ����
%  1. �����������ǰ��־
%  2. ��ȫ�ֱ����TE_LogData�洢��־��¼
%
% by Dr. Guan Guoqiang @ SCUT on 2020-04-05
%
function TE_log(content, status, opt)
% �����������롢�������˵��
% content - (i string) ������־�����ֶ�
% status  - (i integer scalar) ��ѡ��ǰ����״̬����
%                             0 - ��ȱʡֵ��[INFO]
%                             1 - [ERROR]
%                             2 - [WARNING]
% opt     - (i integer scalar) ��ѡ�����������
%                             0 - (ȱʡֵ) ��ʾ��ǰ��¼����ӵ���־
%                             1 - ��ӵ�ǰ��¼����־����������ʾ

%% ��ʼ��
switch nargin
    case(1)
        status = 0;
        opt = 0;
    case(2)
        opt = 0;
    case(3)
        if opt ~= 0 && opt ~= 1
            TE_log('Unknown input argument in TE_log()', 1);
            return
        end
end
global TE_LogData

%% ������־��¼
% ��־ʱ��
log_str.datetime = datetime(now, 'ConvertFrom', 'datenum');
% ��־����
log_str.content = content;
% ����״̬
switch status
    case(0)
        log_str.status = '[INFO]';
    case(1)
        log_str.status = '[ERROR]';
    case(2)
        log_str.status = '[WARNING]';
    otherwise
        log_str.status = '[UNKNOWN]';
end
output = struct2table(log_str, 'AsArray', 1);

%% ���
switch opt
    case(0)
        % ��������ʾ��ǰ��־��¼
        fprintf('%s | %s %s\n', datestr(output.datetime, 31), output.status{:}, output.content{:})
    case(1)
end
% ת����־��¼Ϊ����ӵ�ȫ�ֱ����TE_LogData
if exist('TE_LogData', 'var') == 1
    TE_LogData = [TE_LogData; output];
else
    TE_LogData = output;
end

end