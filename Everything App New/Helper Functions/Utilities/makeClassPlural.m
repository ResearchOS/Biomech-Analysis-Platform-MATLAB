function [plural] = makeClassPlural(class)

%% PURPOSE: CHANGE THE CLASS NAME AS PROVIDED BY className2Abbrev TO PLURAL

if ~isequal(class(end),'s')
    plural = [class 's'];
end

if isequal(class,'Analysis')
    plural = 'Analyses';
end