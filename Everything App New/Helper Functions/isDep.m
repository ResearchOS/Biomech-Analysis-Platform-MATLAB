function [bool] = isDep(G,s,t)

%% PURPOSE: RETURN TRUE IF THE TARGET NODE IS A DEPENDENCY OF THE SOURCE NODE

bool = true;
path = shortestpath(G, s, t);
if isempty(path)
    bool = false;
end