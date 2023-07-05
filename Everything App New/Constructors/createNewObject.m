function [objStruct] = createNewObject(instanceBool, class, name, abstractID, instanceID, saveObj)

%% PURPOSE: CREATE A NEW STRUCT OF ANY CLASS
% This function is only used when creating a *new* project. Not when
% copying from an existing object.

% instanceBool: True: create an instance of an object, and abstract if not yet created. False: create an
% abstract object

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
if isempty(abstractID)
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
objStruct = initializeCommonStructFields(instanceBool, class, name, abstractID, instanceID);

% If creating an abstract object AND an instance at the same time, need to run this twice.
% Once to create abstract object-specific fields and once to create
% instance object-specific fields.
if createAbstract && instanceBool
    objStruct = feval(['create' class 'Struct'],false, objStruct, saveObj);
end

objStruct = feval(['create' class 'Struct'],instanceBool, objStruct, saveObj);

if saveObj
    saveClass(class,objStruct);
end

end

%% VARIABLE
function struct = createVariableStruct(instanceBool, struct, saveObj)

if instanceBool
    struct.HardCodedValue = [];
else
    struct.IsHardCoded = false;
    struct.Level = 'T';
    struct.OutOfDate = true;

end

end

%% PROJECT
function struct = createProjectStruct(instanceBool, struct, saveObj)

if instanceBool

else
    computerID=getComputerID();
    struct.DataPath.(computerID)=''; % Where the Raw Data Files are located.
    struct.ProjectPath.(computerID)=''; % Where the project's files are located.
    struct.Process_Queue = {};
    struct.Current_Logsheet = '';  
    struct.Current_Analysis = '';
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
    struct.InputVariables={};
    struct.InputSubvariables={};
    struct.OutputVariables={};
else
    struct.Level = 'T';
    struct.InputVariablesNamesInCode = {};
    struct.OutputVariablesNamesInCode = {};
end

end

%% PROCESS GROUP
function struct = createProcessGroupStruct(instanceBool, struct, saveObj)

if instanceBool
    struct.RunList={};  
else

end

end

%% LOGSHEET
function struct = createLogsheetStruct(instanceBool, struct, saveObj)

if instanceBool

else
    computerID=getComputerID();
    struct.LogsheetPath.(computerID)='';
    struct.NumHeaderRows=-1;
    struct.SubjectCodenameHeader='';
    struct.TargetTrialIDHeader='';

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
    struct.RunList = {}; % The list of functions & groups to run, in order.

%     if saveObj
%         rootSettingsFile = getRootSettingsFile();
%         load(rootSettingsFile, 'Current_Project_Name');
%         projectStruct = loadJSON(Current_Project_Name);
%         linkObjs(struct, projectStruct);       
%     end

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