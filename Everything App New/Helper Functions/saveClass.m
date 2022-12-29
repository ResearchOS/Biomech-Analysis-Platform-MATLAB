function []=saveClass(src,class,classStruct)

%% PURPOSE: SAVE A CLASS INSTANCE TO FILE.

slash=filesep;

fig=ancestor(src,'figure','toplevel');

filename=[class '_' classStruct.Text];

commonPath=getCommonPath(fig);

classFolder=[commonPath slash class];

filepath=[classFolder slash filename];

json=jsonencode(classStruct,'PrettyPrint',true);

fid=fopen([filepath '.json'],'w');
fprintf(fid,'%s',json);
fclose(fid);

% save(filepath,'struct','-v6');