function [] = transferJSON_SQL()

%% PURPOSE: CONVERT THE JSON FILES TO THE SQL DATABASE.
% 1. Load the JSON files and convert the field names for the common field
% names in abstract & instance objects.
% 2. Ensure that the objects have their specific columns and no others. Map
% previously existing, initialize new ones.

commonPath = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath';
classNames = {'Project','Analysis','ProcessGroup','Process','Variable','SpecifyTrials','Logsheet'};

maps.General.DateCreated = 'Date_Created';
maps.General.DateModified = 'Date_Modified';
maps.General.Text = 'Name';
maps.General.CreatedBy = 'Created_By';
maps.General.Description = 'Description';
maps.General.OutOfDate = 'OutOfDate';
maps.General.UUID = 'UUID';
maps.General.LastModifiedBy = 'Last_Modified_By';
maps.Analysis.Instances.Tags = 'Tags';
maps.Logsheet.Abstract.NumHeaderRows = 'Num_Header_Rows';
maps.Logsheet.Abstract.SubjectCodenameHeader = 'Subject_Codename_Header';
maps.Logsheet.Abstract.TargetTrialIDHeader = 'Target_TrialID_Header';
maps.Logsheet.Abstract.Other = {'LogsheetVar_Params'};
maps.Process.Abstract.MFileName = 'ExecFileName';
maps.Process.Abstract.Level = 'Level';
maps.Process.Abstract.InputVariablesNamesInCode = 'InputVariablesNamesInCode';
maps.Process.Abstract.OutputVariablesNamesInCode = 'OutputVariablesNamesInCode';
maps.Process.Instances.DateLastRan = 'Date_Last_Ran';
maps.Process.Instances.Other = {'SpecifyTrials'};
maps.Project.Instances.DataPath = 'Data_Path';
maps.Project.Instances.ProjectPath = 'Project_Path';
maps.Project.Instances.Process_Queue = 'Process_Queue';
maps.Project.Instances.Current_Logsheet = 'Current_Logsheet';
maps.Project.Instances.Current_Analysis = 'Current_Analysis';
maps.SpecifyTrials.Abstract.Other = {'Logsheet_Parameters','Data_Parameters'};
maps.Variable.Abstract.Level = 'Level';
maps.Variable.Abstract.IsHardCoded = 'IsHardCoded';
maps.Variable.Instances.HardCodedValue = 'HardCodedValue';

for classNum = 1:length(classNames)
    className = classNames{classNum};
    classFolder = [commonPath filesep className];

    absListing = dir(classFolder);
    names = {absListing.name};

    jsonIdx = contains(names,'.json');
    names(~jsonIdx) = [];

    % Abstract objects
    for nameNum = 1:length(names)
        name = names{nameNum};
        path = [classFolder filesep name];

        % Load JSON files
        clear sql;
        fid=fopen(path);
        raw=fread(fid,inf);
        fclose(fid);
        jsonStr=char(raw');

        json=jsondecode(jsonStr);

        % Convert field names for common names
        generalFields = fieldnames(maps.General);
        for fldNum=1:length(generalFields)
            oldFld = generalFields{fldNum};
            newFld = maps.General.(oldFld);
            sql.(newFld) = json.(oldFld);
        end

        % Ensure that instance- & object-specific field names are
        % initialized.
        [type, abstractID] = deText(json.UUID);
        absTmpStruct = createNewObject(false, className, json.Text, abstractID, '', false);
        if isfield(maps,className) && isfield(maps.(className),'Abstract')
            fldNames = fieldnames(maps.(className).Abstract);
            fldNames(ismember(fldNames,'Other')) = [];
            for fldNum = 1:length(fldNames)
                oldName = fldNames{fldNum};
                newName = maps.(className).Abstract.(oldName);
                sql.(newName) = json.(oldName);
                if isfield(json,oldName)
                    sql.(newName) = json.(oldName);
                else
                    sql.(newName) = absTmpStruct.(newName);
                end
            end

            % Perform field-specific transformations
            if isfield(maps.(className).Abstract,'Other')
                otherNames = maps.(className).Abstract.Other;
            else
                otherNames = {};
            end
            for otherNum = 1:length(otherNames)
                otherName = otherNames{otherNum};
                if isequal(otherName,'LogsheetVar_Params')
                    for num = 1:length(json.Headers)
                        sql.LogsheetVar_Params(num).Header = json.Headers{num};
                        sql.LogsheetVar_Params(num).Level = json.Level{num};
                        sql.LogsheetVar_Params(num).Type = json.Type{num};
                        sql.LogsheetVar_Params(num).VR_ID = json.Variables{num};
                    end
                elseif isequal(otherName,'Logsheet_Parameters')
                    for num=1:length(json.Logsheet_Headers)
                        sql.Logsheet_Parameters(num).Headers = json.Logsheet_Headers{num};
                        sql.Logsheet_Parameters(num).Logic = json.Logsheet_Logic{num};
                        sql.Logsheet_Parameters(num).Value = json.Logsheet_Value{num};
                    end
                elseif isequal(otherName,'Data_Parameters')
                    sql.(otherName) = {};
                end
            end
        end

        try
            saveClass(sql);
        catch e
            if ~contains(e.message,'UNIQUE constraint failed')
                error(e);
            end
        end

    end

    % Instance objects
    instanceClassFolder = [classFolder filesep 'Instances'];

    instListing = dir(instanceClassFolder);
    names = {instListing.name};

    jsonIdx = contains(names,'.json');
    names(~jsonIdx) = [];
    
    for nameNum = 1:length(names)
        name = names{nameNum};
        path = [instanceClassFolder filesep name];

        % Load JSON files
        clear sql;
        fid=fopen(path);
        raw=fread(fid,inf);
        fclose(fid);
        jsonStr=char(raw');

        json=jsondecode(jsonStr);

        % Convert field names for common names
        generalFields = fieldnames(maps.General);
        for fldNum=1:length(generalFields)
            oldFld = generalFields{fldNum};
            newFld = maps.General.(oldFld);
            sql.(newFld) = json.(oldFld);
        end

        [type, abstractID, instanceID] = deText(sql.UUID);
        sql.Abstract_UUID = genUUID(type, abstractID);

        % Ensure that instance- & object-specific field names are
        % initialized.
        instTmpStruct = createNewObject(true, className, json.Text, abstractID, instanceID, false);
        if isfield(maps,className) && isfield(maps.(className),'Instances')
            fldNames = fieldnames(maps.(className).Instances);
            fldNames(ismember(fldNames,'Other')) = [];
            for fldNum = 1:length(fldNames)
                oldName = fldNames{fldNum};
                newName = maps.(className).Instances.(oldName);
                if isfield(json,oldName)
                    sql.(newName) = json.(oldName);
                else
                    sql.(newName) = instTmpStruct.(newName);
                end
            end

            % Perform field-specific transformations
            if isfield(maps.(className).Instances,'Other')
                otherNames = maps.(className).Instances.Other;
            else
                otherNames = {};
            end
            for otherNum = 1:length(otherNames)
                otherName = otherNames{otherNum};
                if isequal(otherName, 'SpecifyTrials')
                    sql.SpecifyTrials = {};
                end


            end            

        end

        try
            saveClass(sql);
        catch e
            if ~contains(e.message,'UNIQUE constraint failed')
                error(e);
            end
        end

    end

end