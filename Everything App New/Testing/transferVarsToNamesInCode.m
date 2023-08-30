function [] = transferVarsToNamesInCode()

%% PURPOSE: VAR NAMES IN CODE HAVE ALREADY BEEN ASSIGNED TO THE OBJECT TABLES. 
%% HERE, ASSIGNING ONE VAR NAME IN CODE AND ITS SUBVARIABLE TO THE VR_PR AND PR_VR TABLE.
% 1. Get the PR_VR (output) and VR_PR (input) tables.
% 2. Get each JSON file for the corresponding PR instance.
% 3. Load the PR abstract from Process_Abstract SQL table.
% 4. Map the names in code from #3 to the var UUID's in #2. Store them in
% the VR_PR/PR_VR table.
% 5. For the input table, also map the subvariables from #3 to the var
% UUID's in #2. Store them in the VR_PR table.

% Result of this function: 
%   1. Put char name in code into the VR_PR and PR_VR tables
%   2. Put char subvariable into the VR_PR table
%   3. Put name in code with abstract PR?

global conn;

% 1.
sqlquery = ['SELECT * FROM PR_VR'];
t = fetch(conn, sqlquery);
tOut = table2MyStruct(t);

sqlquery = ['SELECT * FROM VR_PR'];
t = fetch(conn, sqlquery);
tIn = table2MyStruct(t);

% Get all PR abstract objects.
sqlquery = ['SELECT * FROM Process_Abstract'];
t = fetch(conn, sqlquery);
tAbs = table2MyStruct(t);
fldNames = fieldnames(tAbs);

% 2.
folder = ['/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath/Process/Instances'];
for inOut=1:2
    if inOut==1
        sqlStruct = tIn;
    elseif inOut==2
        sqlStruct=tOut;
    end

    uuids = sqlStruct.PR_ID;
    for i=1:length(uuids)
        % Load JSON files.
        clear sql;

        path = [folder filesep uuids{i} '.json'];
        fid=fopen(path);
        raw=fread(fid,inf);
        fclose(fid);
        jsonStr=char(raw');

        json=jsondecode(jsonStr);

        % 3. Get the abstract struct.
        idx = ismember(tAbs.UUID,uuids{i});        
        for fldNum=1:length(fldNames)
            if ~iscell(tAbs.(fldNames{fldNum})(idx))
                currAbs.(fldNames{fldNum}) = tAbs.(fldNames{fldNum})(idx);
            else
                currAbs.(fldNames{fldNum}) = tAbs.(fldNames{fldNum}){idx};
            end
        end

        % 4.
        % currAbs = 

        % 5.
        if inOut==2
            continue;
        end

    end

end