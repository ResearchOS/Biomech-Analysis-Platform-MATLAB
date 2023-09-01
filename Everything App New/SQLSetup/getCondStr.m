function [str] = getCondStr(vector)

%% PURPOSE: RETURN A STRING REPRESENTATION OF A CELL ARRAY (VECTOR) TO USE IN SQL

if ~iscell(vector)
    vector = {vector};
end

str = '(';
for i=1:length(vector)
    str = [str '''' vector{i} ''', '];
end
str = [str(1:end-2) ')'];