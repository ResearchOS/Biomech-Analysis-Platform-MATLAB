function [objStruct] = createNewObject(instanceBool, class, name, abstractID, instanceID)

%% PURPOSE: CREATE A NEW STRUCT OF ANY CLASS

% instanceBool: True: create an instance of an object, and abstract if not yet created. False: create an
% abstract object

assert(isequal(class(instanceBool),'logical') && isscalar(instanceBool)); % Check that it's a boolean

if nargin==0
    objStruct=struct();
    return;
end

if exist('name','var')~=1
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

% Initialize the fields common to all structures (abstract & instances, all
% object types).
objStruct = initializeCommonStructFields(instanceBool, class, name, abstractID, instanceID);

% If creating an abstract object AND an instance at the same time, need to run this twice.
% Once to create abstract object-specific fields and once to create
% instance object-specific fields.
if createAbstract && instanceBool
    objStruct = feval(['create' class 'Struct'],false, objStruct);
end

objStruct = feval(['create' class 'Struct'],instanceBool, objStruct);

saveClass(class,objStruct);

end

%% VARIABLE
function struct = createVariableStruct(instanceBool, struct)

if instanceBool
    struct.HardCodedValue = [];
end
    struct.IsHardCoded = false;
    struct.Level = 'T';
    struct.OutOfDate = true;

end

%% PROJECT
function struct = createProjectStruct(instanceBool, struct)

if instanceBool

else
    computerID=getComputerID();
    struct.DataPath.(computerID)=''; % Where the Raw Data Files are located.
    struct.ProjectPath.(computerID)=''; % Where the project's files are located.
end

end

%% SPECIFY TRIALS
function struct = createSpecifyTrialsStruct(instanceBool, struct)

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
function struct = createProcessStruct(instanceBool, struct)

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
function struct = createProcessGroupStruct(instanceBool, struct)

if instanceBool
    struct.ExecutionListNames={};
    struct.ExecutionListTypes={};
else

end

end

%% LOGSHEET
function struct = createLogsheetStruct(instanceBool, struct)

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
function struct = createAnalysisStruct(instanceBool, struct)

if instanceBool
    struct.Tags = {};
    struct.RunList = {}; % The list of functions & groups to run, in order.
else
    
end

end