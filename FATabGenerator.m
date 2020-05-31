function [FactorsTable] = FATabGenerator(numstage,factor,value)
% Used to generate full factor test design table
%
% by Zhang Yifan on 2020-5-29
%
% input arguments
% numstage -  the stage of i-SFMD
% factor   -  (char)operation conditions
% value    -  double level corresponding to operation conditions 
% output argument 
% FactorTable - all factors test design 

 %% Check the dimension size of input arguments
 % Get the number of DCMD stack  
 NumStack = numstage;
if (length(factor) == NumStack+7) && (length(value) == NumStack+7)
    InputOK = 1;
else
    InputOK = 0;
    fprintf('Error of input arguments in DCMD_FATabGenerator()! \n');
    return;
end
%% main part
factors = cellstr(factor);
% Conduct factorial test design
m=zeros(1,NumStack+7);
for i=1:NumStack+7
    m(1,i) =2;
end
design = fullfact(m);
for column=1:NumStack+7
for rank = 1:2^(NumStack+7)
    if design(rank,column)==1
         design(rank,column)=value(column,1);
    else 
        design(rank,column)=value(column,2);
    end
end
end
Middlecell=num2cell(design);
FactorsTable=cell2table(Middlecell);
FactorsTable.Properties.VariableNames=(factors');
