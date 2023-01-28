function [varNames]=getVarNamesArray(struct)

%% PURPOSE: RETURN THE LIST OF INPUT VARIABLES FROM THE STRUCT

varNames={};

inputVars=struct.InputVariables;
for i=1:length(inputVars)

    currVars=inputVars{i};

    for j=2:length(currVars)

        varNames=[varNames; currVars(2:end)];

    end

end