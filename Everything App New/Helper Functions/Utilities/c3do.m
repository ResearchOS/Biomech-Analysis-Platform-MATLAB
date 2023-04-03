function []=c3do()

%% PURPOSE: OPEN A C3D FILE IN MOKKA

if ismac==1
    disp('Currently windows only! Mokka is deprecated on Mac')
    return;
end

if exist('manual','var')
    manual=1; % Manually select which file to open
else
    manual=0;
end

fig=findall(0,'Name','pgui');

slash=filesep;

if ~isempty(fig)
    defaultPath=[getDataPath slash 'Raw Data Files'];
    try
        if manual==1
            error; % To enter the try-catch block for manual selection.
        end
        subName=evalin('caller','subName;');
        trialName=evalin('caller','trialName;');        
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