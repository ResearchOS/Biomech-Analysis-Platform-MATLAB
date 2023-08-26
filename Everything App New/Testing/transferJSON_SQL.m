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
maps.Process.Abstract.ExecFileName = 'MFileName';
maps.Process.Abstract.DateLastRan = 'Date_Last_Ran';
maps.Process.Abstract.Other = {'SpecifyTrials'};
maps.Project.Abstract.DataPath = 'Data_Path';
maps.Project.Abstract.ProjectPath = 'ProjectPath';
maps.Project.Abstract.Process_Queue = 'Process_Queue';
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

    tablename = getTableName(className, false);

    % Abstract objects
    for nameNum = 1:length(names)
        name = names{nameNum};
        path = [classFolder filesep name];

        % Load JSON files
        clear sql;

        % Convert field names for common names
        generalFields = fieldnames(maps.General);
        for fldNum=1:length(generalFields)
            sql.(newFld) = maps.General.(generalFields{fldNum});
        end

        writeJSON(sql);

    end

    instanceClassFolder = [classFolder filesep 'Instances'];

    tablename = getTableName(className, true);

    instListing = dir(classFolder);
    names = {instListing.name};
    
    jsonIdx = contains(names,'.json');
    names(~jsonIdx) = [];

    % Instance objects
    for nameNum = 1:length(names)
        name = names{nameNum};
        path = [instanceClassFolder filesep name];

        % Load JSON files
        clear sql;

        % Convert field names for common names
        generalFields = fieldnames(maps.General);
        for fldNum=1:length(generalFields)
            sql.(newFld) = maps.General.(generalFields{fldNum});
        end

        [type, abstractID] = deText(sql.UUID);
        sql.Abstract_UUID = genUUID(type, abstractID);

        % Ensure that instance- & object-specific field names are
        % initialized.

    end

end