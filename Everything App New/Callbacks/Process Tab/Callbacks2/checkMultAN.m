function [isMult] = checkMultAN(objL, objR)

%% PURPOSE: CHECK IF THE UUID IS IN MULTIPLE ANALYSES. RETURNS TRUE IF IN MULTIPLE ANALYSES.

global globalG;

% Need to account for input/output var, object ordering, etc.

tmpG = addedge(globalG, objL, objR);
anList = getObjs({objsL; objsR}, {'AN'}, 'down', tmpG);

isMult = false;
Current_Analysis = getCurrent('Current_Analysis');
if ~isequal(anList,{Current_Analysis})
    isMult = true;
end