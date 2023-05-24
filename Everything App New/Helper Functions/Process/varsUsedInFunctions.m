function [idx]=varsUsedInFunctions(currVars,allVars,type)

%% PURPOSE: FOR CHECKING DIFFERENT VERSIONS, DETERMINE IF THE CURRENT VARIABLES ARE USED IN ANY OF THE ALLVARS ELEMENTS

% Returns true if all of the current input variables are found across all of the previous output variables. Helpful for sorting.
if isequal(type,'all')
    allVarsCat={};
    for i=1:length(allVars)
        allVarsCat=[allVarsCat; allVars{i}];
    end
    if all(ismember(currVars,allVarsCat))
        idx=true; % All of the current variables are used in the functions' variables.
    else
        idx=false;
    end
    return;
end

% Returns true at the index where any of the output variables are used in another function. Helpful for removing unnecessary functions.
idx=false(size(allVars));

for i=1:length(allVars)

    if isequal(type,'any')
        if any(ismember(currVars,allVars{i}))
            idx(i)=true; % At least one of the current variables is used in the functions' variables.
        end
    end

end