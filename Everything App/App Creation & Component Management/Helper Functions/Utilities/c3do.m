function []=c3do()

%% PURPOSE: OPEN A C3D FILE IN MOKKA

if ismac==1
    disp('Currently windows only! Mokka is deprecated on Mac')
    return;
end

fig=findall(0,'Name','pgui');

if ~isempty(fig)
    defaultPath=[getappdata(fig,'dataPath') 'Raw Data Files'];
    try
        subName=evalin('caller','subName;');
        trialName=evalin('caller','trialName;');
        slash=filesep;
        fullPath=[defaultPath slash subName slash trialName '.c3d'];
    catch
        [file,path]=uigetfile('*.c3d','Select c3d File',defaultPath,'MultiSelect','off');
        if isequal(file,0) || isequal(path,0)
            return;
        end
        fullPath=[path file];
    end
else
    defaultPath=cd;
    [file,path]=uigetfile('*.c3d','Select c3d File',defaultPath,'MultiSelect','off');
    if isequal(file,0) || isequal(path,0)
        return;
    end
    fullPath=[path file];
end

if ispc==1
    winopen(fullPath);
end