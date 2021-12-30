function []=dataTypeCheckboxValueChanged(src)

fig=ancestor(src,'figure','toplevel');

currTag=src.Tag;

if ~isletter(currTag(end-1)) % 2 digits
    currNum=str2double(currTag(end-1:end));
else % 1 digit
    currNum=str2double(currTag(end));
end

% Find the other of the load & offload box objects
if contains(currTag,'Offload') % offload box was clicked
    currLoad=findobj(fig,'Type','uicheckbox','Tag',['ImportTabLoadBox' num2str(currNum)]);
    currOffload=src;
    loadClicked=0;
else % Load box was clicked
    currLoad=src;
    currOffload=findobj(fig,'Type','uicheckbox','Tag',['ImportTabOffloadBox' num2str(currNum)]);
    loadClicked=1;
end

if loadClicked==1
    if currOffload.Value==1
        currOffload.Value=0;
    end
else % Offload clicked
    if currLoad.Value==1
        currLoad.Value=0;
    end
end

if currLoad.Value==1
    data='Load';
elseif currOffload.Value==1
    data='Offload';
else
    data='None';
end

currLabel=findobj(fig,'Type','uilabel','Tag',['ImportTabDataLabel' num2str(currNum)]);
prefix=['Data Panel ' currLabel.Text ':'];

%% Store the data to the text file
text=readAllProjects(getappdata(fig,'everythingPath'));
text=addProjInfoToFile(text,getappdata(fig,'projectName'),prefix,data,0);

fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);