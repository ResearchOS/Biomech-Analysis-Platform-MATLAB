function [struct]=newComputerProjectPaths(uuid)

%% PURPOSE: ENSURE THAT THERE ARE FIELDS FOR THE COMPUTER-SPECIFIC PATHS

computerID = getComputerID();
Current_User = getCurrent('Current_User');

struct = loadJSON(uuid);
type = deText(uuid);
tmpStruct = createNewObject(true,type,'Default','','',false);

doWrite = false;
if isequal(type,'PJ')    
    if ~isfield(struct,'Project_Path') || ~isfield(struct.Project_Path,computerID)
        doWrite = true;
        struct.Project_Path.(computerID) = tmpStruct.Project_Path.(computerID); % Assign default
    end

    if ~isfield(struct,'Data_Path') || ~isfield(struct.Data_Path,computerID)
        doWrite = true;
        struct.Data_Path.(computerID) = tmpStruct.Data_Path.(computerID); % Assign default
    end
elseif isequal(type,'AN')
    if ~isfield(struct,'Current_View') || ~isfield(struct.Current_View,Current_User)
        doWrite = true;
        if ~isstruct(struct.Current_View)
            struct = rmfield(struct,'Current_View');
        end
        struct.Current_View.(Current_User) = '';
    end

    if ~isfield(struct,'Current_Logsheet') || ~isfield(struct.Current_Logsheet,Current_User)
        doWrite = true;
        if ~isstruct(struct.Current_Logsheet)
            struct = rmfield(struct,'Current_Logsheet');
        end
        struct.Current_Logsheet.(Current_User) = '';
    end    
elseif isequal(type,'LG')
    if ~isfield(struct,'Logsheet_Path') || ~isfield(struct.Logsheet_Path,computerID)
        doWrite = true;
        if ~isstruct(struct.Logsheet_Path)
            struct = rmfield(struct,'Logsheet_Path');
        end
        struct.Logsheet_Path.(computerID) = '';
    end
end

if doWrite
    writeJSON(struct);
end