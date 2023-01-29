function [varNames]=getVarNamesArray(struct,fldName)

%% PURPOSE: RETURN THE LIST OF INPUT VARIABLES FROM THE STRUCT

% fldName is either 'InputVariables' or 'OutputVariables'

varNames={};

vars=struct.(fldName);
for i=1:length(vars)

    currVars=vars{i};

    for j=2:length(currVars)

        varNames=[varNames; currVars(2:end)];

    end

end