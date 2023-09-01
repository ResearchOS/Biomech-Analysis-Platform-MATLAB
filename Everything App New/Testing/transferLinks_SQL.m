function [] = transferLinks_SQL()

%% PURPOSE: TRANSFER THE LINKAGE MATRIX FROM JSON TO SQL FORMAT.
% 1. Load the links.
% 2. For every row, get the object types
% 3. If ST, skip.
% 4. Get the corresponding table name.
% 5. Put the link in the corresponding table.

global conn;

% 1. Load & format linkage matrix from JSON.
path = '/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/PGUI_CommonPath/Linkages/Linkages.json';
fid=fopen(path);
raw=fread(fid,inf);
fclose(fid);
jsonStr=char(raw');

json=jsondecode(jsonStr);

out = cell(length(json),2);

for i=1:size(out,1)
    out(i,:) = json{i}';
end

tablenames = sqlfind(conn, '');
tablenames = tablenames.Table;

% 2. For every row:
for i=1:size(out,1)

    uuid1 = out{i,1};
    uuid2 = out{i,2};

    type1 = deText(uuid1);
    type2 = deText(uuid2);

    % Specify trials
    if isequal(type1,'ST') && isequal(type2,'PR')
        tablename = 'Process_Instances';
        currST = getST(uuid2); % Get current ST from the PR.        
        if ~iscell(currST)
            currST = {}; % Happens when there's a missing value.
        end
        st = jsonencode([{uuid1}; currST]);
        sqlquery = ['UPDATE ' tablename ' SET SpecifyTrials = ''' st ''' WHERE UUID = ''' uuid2 ''';'];
        execute(conn, sqlquery);
        continue;
    elseif isequal(type1,'ST')
        continue;
    end

    if ismember('LG',{type1, type2}) && ismember('VR',{type1, type2})
        continue; % Skip logsheet variables because there's currently no table for that.
    end

    tablename = [type1 '_' type2];    
    
    if ~ismember(tablename, tablenames)
        uuid1 = out{i,2}; % Switch UUID's
        uuid2 = out{i,1};
        tmpType1 = type1;
        tmpType2 = type2;
        type1 = tmpType2; % Switch types
        type2 = tmpType1;
        tablename = [type1 '_' type2]; % Switch table name.        
    end

    assert(ismember(tablename, tablenames));

    if isequal(type1,'PG') && isequal(type2,'PG')
        type1 = ['Parent_' type1];
        type2 = ['Child_' type2];
    end

    % Initialize rows
    if (contains(tablename,'VR') && contains(tablename,'PR'))              
        sqlquery = ['INSERT INTO ' tablename ' (' type1 '_ID, ' type2 '_ID, NameInCode) VALUES (''' uuid1 ''', ''' uuid2 ''', ''NULL'');'];        
    else
        sqlquery = ['INSERT INTO ' tablename ' (' type1 '_ID, ' type2 '_ID) VALUES (''' uuid1 ''', ''' uuid2 ''');'];
    end

    % Updating rows
    % sqlquery = ['UPDATE ' tablename ' SET NameInCode = ''NULL'';'];
    
    try
        execute(conn, sqlquery);
        count.([uuid1 '_' uuid2]) = 0;
    catch e
        % Inserting
        if ~contains(e.message, 'UNIQUE constraint failed')
            error(e);
        else
            count.([uuid1 '_' uuid2]) = count.([uuid1 '_' uuid2])+1;
            nullStr = ['NULL' num2str(count.([uuid1 '_' uuid2]))];
            sqlquery = ['INSERT INTO ' tablename ' (' type1 '_ID, ' type2 '_ID, NameInCode) VALUES (''' uuid1 ''', ''' uuid2 ''', ''' nullStr ''');'];
            execute(conn, sqlquery);
        end
        % Updating
        % if ~contains(e.message,'no such column: NameInCode')
        %     error(e);
        % end
    end

end