function []=saveClass(class, classStruct, date)

%% PURPOSE: SAVE A CLASS INSTANCE TO A NEW ROW.
global conn;

uuid = classStruct.UUID;
[~,abstractID,instanceID]=deText(uuid);

if ~isempty(instanceID)
    suffix = 'Instances';
else
    suffix = 'Abstract';
end

class = makeClassPlural(class);
tablename = [class '_' suffix];

types = fetch(conn, ['PRAGMA table_info(' tablename ');']);

t = struct2table(classStruct,'AsArray',true);

% sqlquery = ['UPDATE ' class '_' suffix ' SET VariableValue = ''' Current_Tab_Title ''' WHERE VariableName = ''Current_Tab_Title'''];

sqlwrite(conn, tablename, t);
% slash=filesep;

% filename=classStruct.UUID;

% rootPath=getCommonPath();

% if ~isempty(instanceID)
%     rootPath=[rootPath slash class slash 'Instances'];
% else
%     rootPath=[rootPath slash class];
% end
% 
% filepath=[rootPath slash filename];
% 
% if nargin<3
%     date=datetime('now');
% end

% writeJSON(filepath,classStruct,date);