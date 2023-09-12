function [runInfo]=getRunInfo(absStruct, instStruct)

%% PURPOSE: COMPILE INFO THAT GETARG/SETARG NEED TO RUN THE SPECIFIED FUNCTION.
% 1. Data path
% 2. Map the names in code to the variable names.
% 3. getArg only:
%   - Subvariables
%   - IsHardCoded
%   - HardCodedValue

global conn;

%% 1. Data Path
runInfo.DataPath=getCurrent('Data_Path');
type = deText(instStruct.UUID);
runInfo.Type = type;

for inOut=1:2
    if inOut==1
        fldName = 'Input';
        tablename = 'VR_PR';
    elseif inOut==2
        fldName = 'Output';
        tablename = 'PR_VR';
    end

    runInfo.(fldName).AbsNamesInCode = absStruct.([fldName 'VariablesNamesInCode']);

    %% Inputs & Outputs
    if inOut==1
        sqlquery = ['SELECT VR_ID, NameInCode, Subvariable FROM ' tablename ' WHERE PR_ID = ''' instStruct.UUID ''';'];
    elseif inOut==2
        sqlquery = ['SELECT VR_ID, NameInCode FROM ' tablename ' WHERE PR_ID = ''' instStruct.UUID ''';'];
    end
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        t.VR_ID = {};
        t.NameInCode = {};
        if inOut==1
            t.Subvariable = {};
        end
    end
    if ~iscell(t.VR_ID)
        t.VR_ID = {t.VR_ID};
        t.NameInCode = {t.NameInCode};
        if inOut==1
            t.Subvariable = {t.Subvariable};
        end
    end

    runInfo.(fldName).VR_ID = t.VR_ID;
    runInfo.(fldName).NameInCode = t.NameInCode;

    if inOut==1
        if isempty(t.Subvariable)
            t.Subvariable = cell(size(t.VR_ID));
        end
        runInfo.(fldName).Subvariable = t.Subvariable;
    end        

    % Get abstract UUID's to see if hard coded
    [types, abstractIDs] = deText(t.VR_ID);
    abstractUUIDs = genUUID(types, abstractIDs);
    absStr = getCondStr(abstractUUIDs);
    sqlquery = ['SELECT UUID, IsHardCoded, Level FROM Variables_Abstract WHERE UUID IN ' absStr ';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        t.UUID = {};
        t.IsHardCoded = {};
        t.Level = {};
    end
    if ~iscell(t.UUID)
        t.UUID = {t.UUID};        
        t.Level = {t.Level};
    end

    % Handle multiple instances of one abstract, in which case there will be a mismatch between lengths of levels and VR UUID's.
    levels = cell(size(runInfo.(fldName).VR_ID));
    for i=1:length(t.UUID)
        idx = contains(runInfo.(fldName).VR_ID,t.UUID{i});
        levels(idx) = t.Level(i);
    end

    runInfo.(fldName).Level = levels;

    %% Inputs only
    if inOut==2
        continue;
    end

    isHardCodedIdx = t.IsHardCoded == 1;
    t.UUID(~isHardCodedIdx) = [];

    hardCodedVRidx = contains(runInfo.(fldName).VR_ID, t.UUID);
    runInfo.(fldName).IsHardCoded = hardCodedVRidx;

    % Get hard-coded values.
    hardCodedVals = repmat({''},length(runInfo.(fldName).VR_ID),1);
    if any(runInfo.(fldName).IsHardCoded)
        hardCodedStr = getCondStr(runInfo.(fldName).VR_ID(runInfo.(fldName).IsHardCoded));
        sqlquery = ['SELECT UUID, HardCodedValue FROM Variables_Instances WHERE UUID IN ' hardCodedStr ';'];
        t = fetch(conn, sqlquery);
        t = table2MyStruct(t);
        if isempty(fieldnames(t))
            t.UUID = {};
            t.HardCodedValue = {};
        end
        if ~iscell(t.UUID)
            t.UUID = {t.UUID};
            t.HardCodedValue = {t.HardCodedValue};
        end
        tmp = t.HardCodedValue;
        [~,k] = sort(runInfo.(fldName).VR_ID(hardCodedVRidx));
        tmp(k) = tmp;
        hardCodedVals(hardCodedVRidx) = tmp;
    end
    runInfo.(fldName).HardCodedValue = hardCodedVals;

end

if ~isequal(type,'Component')
    assignin('base','runInfo',runInfo);
end