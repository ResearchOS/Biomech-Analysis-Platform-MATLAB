function [objStruct, absStruct] = createNewObject(instanceBool, class, name, abstractID, instanceID, saveObjBool, args)

%% PURPOSE: CREATE A NEW STRUCT OF ANY CLASS
% This function is only used when creating a new object.

% instanceBool: True: create an instance of an object, and abstract if not yet created. False: create an
% abstract object

% 1st output argument is the struct that was requested (instance or
% abstract). 2nd output argument is always the abstract. This is helpful
% when creating instance & abstract at the same time.

assert(islogical(instanceBool) && isscalar(instanceBool)); % Check that it's a boolean

if nargin==0
    objStruct=struct();
    return;
end

if exist('name','var')~=1 || isempty(name)
    name = 'Default';
end

% Check if creating an abstract object.
createAbstract = false;
if exist('abstractID','var')~=1
    abstractID = '';    
end

if isempty(abstractID) || ~instanceBool
    createAbstract=true;
end

if exist('instanceID','var')~=1
    instanceID = '';
end

if exist('saveObj','var')~=1
    saveObjBool = true;
end

if exist('args','var')~=1
    args = '';
end

% Initialize the fields common to all structures (abstract & instances, all
% object types).
if ischar(class) && length(class)==2
    class = className2Abbrev(class);
end

% If creating an abstract object AND an instance at the same time, need to run this twice.
% Once to create abstract object-specific fields and once to create
% instance object-specific fields.
if createAbstract
    if ~instanceBool
        name = promptName('Enter Object Name','Default');
        if isempty(name)
            objStruct = {};
            return;
        end
    end
    objStruct = initializeCommonStructFields(false, class, name, abstractID, instanceID);
    absStruct = feval(['create' class 'Struct'],false, objStruct, saveObjBool, args);
    if saveObjBool
        saveObj(absStruct);        
    end
    [type,abstractID] = deText(absStruct.UUID);    
end

if instanceBool
    objStruct = initializeCommonStructFields(true, class, name, abstractID, instanceID);
    instStruct = feval(['create' class 'Struct'],instanceBool, objStruct, saveObjBool, args);    
    if saveObjBool
        saveObj(instStruct);         
    end
end

if nargout==2 && exist('absStruct','var')~=1
    absStruct = loadJSON(getAbstractID(instStruct.UUID));
end

end

%% VARIABLE
function struct = createVariableStruct(instanceBool, struct, saveObj, args)

if instanceBool
    struct.HardCodedValue = [];
else
    struct.IsHardCoded = false;
    struct.Level = 'T';
end

end

%% PROJECT
function struct = createProjectStruct(instanceBool, struct, saveObj, args)

if instanceBool
    computerID=getComputerID();
    struct.Data_Path.(computerID)=''; % Where the Raw Data Files are located.
    struct.Project_Path.(computerID)=''; % Where the project's files are located.    
       
    Current_User = getCurrent('Current_User');
    struct.Current_Analysis.(Current_User) = args.Current_Analysis;
else
    
end

end

%% SPECIFY TRIALS
function struct = createSpecifyTrialsStruct(instanceBool, struct, saveObj, args)

if instanceBool

else
    struct.Logsheet_Parameters.Headers={};
    struct.Logsheet_Parameters.Logic={};
    struct.Logsheet_Parameters.Value={};
    struct.Logsheet_Parameters.Variables={};
    struct.Logsheet_Parameters.Logic={};
    struct.Logsheet_Parameters.Value={};
end

end

%% PROCESS
function struct = createProcessStruct(instanceBool, struct, saveObj, args)

if instanceBool
    struct.SpecifyTrials={};    
    struct.Date_Last_Ran='';
else
    struct.Level = 'T';
    struct.InputVariablesNamesInCode = {};  
    struct.OutputVariablesNamesInCode = {};
    struct.ExecFileName = '';
end

end

%% PROCESS GROUP
function struct = createProcessGroupStruct(instanceBool, struct, saveObj, args)

if instanceBool
    
else

end

end

%% LOGSHEET
function struct = createLogsheetStruct(instanceBool, struct, saveObj, args)

if instanceBool
    computerID=getComputerID();
    struct.Logsheet_Path.(computerID)='';
    struct.Num_Header_Rows=-1;
    struct.Subject_Codename_Header='';
    struct.Target_TrialID_Header='';

    struct.LogsheetVar_Params.Headers={}; % The headers for the current logsheet.
    struct.LogsheetVar_Params.Level={}; % Trial or subject
    struct.LogsheetVar_Params.Type={}; % Char or double
    struct.LogsheetVar_Params.Variables={}; % The variable struct text (file name)
else
    
end

end

%% ANALYSIS
function struct = createAnalysisStruct(instanceBool, struct, saveObj, args)

if instanceBool
    struct.Tags = {};   
    Current_User=getCurrent('Current_User');    

    struct.Current_View.(Current_User) = args.Current_View;    
    struct.Current_Logsheet.(Current_User) = args.Current_Logsheet;
    struct.Process_Queue.(Current_User) = {};
else
    
end

end

%% VIEW
function struct = createViewStruct(instanceBool, struct, saveObj, args)

if instanceBool
    struct.InclNodes = {};
else

end

end

%% PLOT
function struct = createPlotStruct(instanceBool, struct, saveObj, args)

if instanceBool

else

end

end

%% COMPONENT
function struct = createComponentStruct(instanceBool, struct, saveObj, args)

if instanceBool

else

end

end