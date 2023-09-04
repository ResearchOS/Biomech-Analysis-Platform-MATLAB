function [objStruct, absStruct] = createNewObject(instanceBool, class, name, abstractID, instanceID, saveObj)

%% PURPOSE: CREATE A NEW STRUCT OF ANY CLASS
% This function is only used when creating a *new* project. Not when
% copying from an existing object.

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
    saveObj = true;
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
    objStruct = initializeCommonStructFields(false, class, name, abstractID, instanceID);
    absStruct = feval(['create' class 'Struct'],false, objStruct, saveObj);
    if saveObj
        saveClass(absStruct);
    end
    [type,abstractID] = deText(absStruct.UUID);
    objStruct = absStruct;    
end

if instanceBool
    objStruct = initializeCommonStructFields(true, class, name, abstractID, instanceID);
    instStruct = feval(['create' class 'Struct'],instanceBool, objStruct, saveObj);    
    if saveObj
        saveClass(instStruct);
    end
    objStruct = instStruct;
end

if ~saveObj || ~instanceBool
    return;
end

%% Link objects. If any getCurrent returns empty, linking fails.
% Is there ever a reason for these classes not to link to current? If so,
% add another flag.
if isequal(class,'Project')
    try
        linkObjs(instStruct.UUID, instStruct.Current_Analysis); % PJ_AN
    catch e
        if ~contains(e.message,'UNIQUE constraint failed')
            error(e);
        end
    end
end

if isequal(class,'Analysis')
    computerID = getCurrent('Computer_ID');
    try
        linkObjs(instStruct.UUID, instStruct.Current_View.(computerID)); % AN_VW
    catch e
        if ~contains(e.message,'UNIQUE constraint failed')
            error(e);
        end
    end
    linkObjs(instStruct.UUID, getCurrent('Current_Project')); % PJ_AN
end

if isequal(class,'View')
    linkObjs(instStruct.UUID, getCurrent('Current_Analysis')); % AN_VW
end

end

%% VARIABLE
function struct = createVariableStruct(instanceBool, struct, saveObj)

if instanceBool
    struct.HardCodedValue = [];
else
    struct.IsHardCoded = false;
    struct.Level = 'T';
end

end

%% PROJECT
function struct = createProjectStruct(instanceBool, struct, saveObj)

if instanceBool
    computerID=getCurrent('Computer_ID');
    struct.Data_Path.(computerID)=''; % Where the Raw Data Files are located.
    struct.Project_Path.(computerID)=''; % Where the project's files are located.
    struct.Process_Queue = {};
    struct.Current_Logsheet = '';      

    % Create new analysis and assign it to the project.
    anStruct = createNewObject(true, 'Analysis', 'Default','','', saveObj);
    struct.Current_Analysis = anStruct.UUID;
else
    
end

end

%% SPECIFY TRIALS
function struct = createSpecifyTrialsStruct(instanceBool, struct, saveObj)

if instanceBool

else
    struct.Logsheet_Headers={};
    struct.Logsheet_Logic={};
    struct.Logsheet_Value={};
    struct.Data_Variables={};
    struct.Data_Logic={};
    struct.Data_Value={};
end

end

%% PROCESS
function struct = createProcessStruct(instanceBool, struct, saveObj)

if instanceBool
    struct.SpecifyTrials={};    
    struct.Date_Last_Ran='';
else
    struct.Level = 'T';
    struct.NamesInCode = {};    
    struct.ExecFileName = '';
end

end

%% PROCESS GROUP
function struct = createProcessGroupStruct(instanceBool, struct, saveObj)

if instanceBool
    
else

end

end

%% LOGSHEET
function struct = createLogsheetStruct(instanceBool, struct, saveObj)

if instanceBool

else
    computerID=getComputerID();
    struct.Logsheet_Path.(computerID)='';
    struct.Num_Header_Rows=-1;
    struct.Subject_Codename_Header='';
    struct.Target_TrialID_Header='';

    struct.Headers={}; % The headers for the current logsheet.
    struct.Level={}; % Trial or subject
    struct.Type={}; % Char or double
    struct.Variables={}; % The variable struct text (file name)
end

end

%% ANALYSIS
function struct = createAnalysisStruct(instanceBool, struct, saveObj)

if instanceBool
    struct.Tags = {};   
    computerID=getComputerID();    

    % Create new view and assign it. Handle attempts at redundantly
    % creating abstract object.
    try
        vwAbsStruct = createNewObject(false, 'View', 'ALL','000000','', saveObj);
    catch e
        if ~contains(e.message,'UNIQUE constraint failed')
            error(e);
        end
    end
    vwStruct = createNewObject(true, 'View','ALL','000000', '', saveObj);
    struct.Current_View.(computerID) = vwStruct.UUID;
else
    
end

end

%% VIEW
function struct = createViewStruct(instanceBool, struct, saveObj)

if instanceBool
    struct.InclNodes = {};
else

end

end

%% PLOT
function struct = createPlotStruct(instanceBool, struct, saveObj)

if instanceBool

else

end

end

%% COMPONENT
function struct = createComponentStruct(instanceBool, struct, saveObj)

if instanceBool

else

end

end