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
%   3. Put names in code with abstract PR.

global conn;

% 1.
sqlquery = ['SELECT * FROM PR_VR'];
% sqlquery = ['SELECT UUID FROM PR_VR'];
t = fetch(conn, sqlquery);
tOut = table2MyStruct(t);

sqlquery = ['SELECT * FROM VR_PR'];
t = fetch(conn, sqlquery);
tIn = table2MyStruct(t);

% Remove all records.
sqlquery = ['DELETE FROM VR_PR'];
execute(conn, sqlquery);
sqlquery = ['DELETE FROM PR_VR'];
execute(conn, sqlquery);

% 2.
instFolder = ['/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath/Process/Instances'];
absFolder = ['/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath/Process'];
for inOut=1:2
    if inOut==1
        sqlStruct = tIn;
        tablename = 'VR_PR';
        type1 = 'VR';
        type2 = 'PR';
    elseif inOut==2
        sqlStruct=tOut;
        tablename = 'PR_VR';
        type1 = 'PR';
        type2 = 'VR';
    end

    uuids = unique(sqlStruct.PR_ID,'stable');
    for i=1:length(uuids)
        % Load JSON files.
        clear sql;

        path = [instFolder filesep uuids{i} '.json'];
        fid=fopen(path);
        raw=fread(fid,inf);
        fclose(fid);
        jsonStr=char(raw');
        jsonInst=jsondecode(jsonStr);

        [type, abstractID] = deText(uuids{i});
        absUUID = genUUID(type, abstractID);
        path = [absFolder filesep absUUID '.json'];
        fid=fopen(path);
        raw=fread(fid,inf);
        fclose(fid);
        jsonStr=char(raw');
        jsonAbs=jsondecode(jsonStr);

        % 3. Put the names in code in the abstract SQL struct.
        if inOut==1
            namesInCodeJSON = jsonencode(jsonAbs.InputVariablesNamesInCode); % Abstract
            subVars = getVarNamesArray(jsonInst,'InputSubvariables');
            vars = getVarNamesArray(jsonInst,'InputVariables');
            colName = 'InputVariablesNamesInCode';
            namesInCode = getVarNamesArray(jsonAbs,colName);
        elseif inOut==2
            namesInCodeJSON = jsonencode(jsonAbs.OutputVariablesNamesInCode);            
            vars = getVarNamesArray(jsonInst,'OutputVariables');
            colName = 'OutputVariablesNamesInCode';
            namesInCode = getVarNamesArray(jsonAbs,colName);
        end

        % Set names in code
        % sqlquery = ['UPDATE Process_Abstract SET ' colName ' = ''' namesInCodeJSON ''' WHERE UUID = ''' absUUID ''';'];
        % execute(conn, sqlquery);

        % Get the indices of each variable in the PR_VR
        % [~, b, c] = intersect(vrID, vars,'stable');
        % Now 'b' idx represents the proper var UUID's and namesInCode
        % vars=vars(c);
        % namesInCode = namesInCode(c);                    

        for j = 1:length(vars)
            sqlquery = ['INSERT INTO ' tablename ' (VR_ID, PR_ID, NameInCode) VALUES (''' vars{j} ''', ''' uuids{i} ''', ''' namesInCode{j} ''');'];
            % sqlquery = ['UPDATE ' tablename ' SET NameInCode = ''' namesInCode{j} ''' WHERE PR_ID = ''' uuids{i} ''' AND VR_ID = ''' vars{j} ''';'];
            execute(conn, sqlquery);
        end   

        % 5.
        if inOut==2
            continue;
        end

        % Subvariables.
        for j=1:length(vars)
            sqlquery = ['UPDATE ' tablename ' SET Subvariable = ''' subVars{j} ''' WHERE PR_ID = ''' uuids{i} ''' AND VR_ID = ''' vars{j} ''' AND NameInCode = ''' namesInCode{j} ''';'];
            execute(conn, sqlquery);
        end

    end

end