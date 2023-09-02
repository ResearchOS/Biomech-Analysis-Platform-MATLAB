function [plural] = makeClassPlural(class)

%% PURPOSE: CHANGE THE CLASS NAME AS PROVIDED BY className2Abbrev TO PLURAL

isChar = false;
if ~iscell(class)
    isChar = true;
    class = {class};
end

plurals = cell(size(class));
for i=1:length(class)
    currClass = class{i};

    plural = currClass; % The case 'Process' requires this.

    if ~isequal(currClass(end),'s')
        plural = [currClass 's'];
    end

    if isequal(currClass,'Analysis')
        plural = 'Analyses';
    end

    plurals{i} = plural;
end

if isChar
    plurals = plurals{1};
end

plural = plurals;