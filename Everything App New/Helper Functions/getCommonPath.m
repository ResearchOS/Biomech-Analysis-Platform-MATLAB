function [commonPath]=getCommonPath()

%% PURPOSE: RETURN THE PATH TO THE DIRECTORY WHERE THE PGUI SETTINGS FILES ARE STORED.

h = @memoizedGetCommonPath;
memFcn = memoize(h);

commonPath = memFcn();

end

function [commonPath] = memoizedGetCommonPath()
sqlquery = ['SELECT VariableValue FROM Settings WHERE VariableName = ''commonPath'''];
var = fetch(conn, sqlquery);
commonPath = var.VariableValue;

if ~isequal(commonPath,'NULL')
    return;
end

setCommonPath();
commonPath = getCommonPath();

end


% rootSettingsFile=getRootSettingsFile();
% 
% %% Root settings simply contains the path to where all of the Settings variables are stored.
% try
%     load(rootSettingsFile,'commonPath');
% catch e
%     if ~isequal(e.identifier,'MATLAB:load:couldNotReadFile') % If the file does not exist.
%         error(e); % Some other error occurred.
%     end
% 
%     setCommonPath();
%     commonPath = getCommonPath;    
% end
% 
% end