function []=c3do()

%% PURPOSE: OPEN A C3D FILE IN MOKKA

if ismac==1
    disp('Currently windows only!')
    return;
end

if ~isempty(findall(0,'Name','pgui'))
    fig=findall(0,'Name','pgui');
    defaultPath=[getappdata(fig,'dataPath') 'Raw Data Files'];
%     projectName=getappdata(fig,'projectName');
    try
        subName=evalin('caller','subName;');
        trialName=evalin('caller','trialName;');
        slash=filesep;
        fullPath=[defaultPath slash subName slash trialName '.c3d'];
        [~,file]=fileparts(fullPath);
%         saveName=['aaData_' file];
    catch
        [file,path]=uigetfile('*.c3d',defaultPath,'MultiSelect','off');
        if isequal(file,0) || isequal(path,0)
            return;
        end
        fullPath=[path file];
%         saveName=['aaData_' file(1:end-4)];
    end
else
    defaultPath=cd;
    [file,path]=uigetfile('*.c3d','Select c3d File',defaultPath,'MultiSelect','off');
    if isequal(file,0) || isequal(path,0)
        return;
    end
    fullPath=[path file];
%     saveName=['aaData_' file(1:end-4)];
end

if ispc==1
    winopen(fullPath);
end