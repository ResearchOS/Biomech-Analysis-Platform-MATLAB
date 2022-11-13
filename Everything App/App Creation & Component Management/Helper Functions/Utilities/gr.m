function [S]=gr(manual)

%% PURPOSE: EMULATES THE FUNCTIONALITY FROM BIOMECHZOO "GRAB" FUNCTION, RETRIEVING ONE TRIAL'S DATA FROM A UIFILEPICKER

if exist('manual','var')
    manual=1; % Manually select which file to open
else
    manual=0;
end

fig=findall(0,'Name','pgui');

if ~isempty(fig)    
    defaultPath=[getappdata(fig,'dataPath') 'MAT Data Files'];
    projectName=getappdata(fig,'projectName');
    try
        if manual==1
            error; % Do this just to push things to the try-catch block.
        end
        subName=evalin('caller','subName;');
        trialName=evalin('caller','trialName;');
        slash=filesep;
        fullPath=[defaultPath slash subName slash trialName '_' subName '_' projectName '.mat'];
        [~,file]=fileparts(fullPath);
        saveName=['aaData_' file];
    catch
        [file,path]=uigetfile(defaultPath,'Select MAT file','MultiSelect','off');
        if isequal(file,0) || isequal(path,0)
            return;
        end
        fullPath=[path file];
        saveName=['aaData_' file(1:end-4)];
    end
else
    defaultPath=cd;
    [file,path]=uigetfile(defaultPath,'Select MAT file','MultiSelect','off');
    if isequal(file,0) || isequal(path,0)
        return;
    end
    fullPath=[path file];
    saveName=['aaData_' file(1:end-4)];
end

S=load(fullPath,'-mat');
varNames=fieldnames(S);
[~,varNamesIdx]=sort(upper(varNames));
varNames=varNames(varNamesIdx);
for i=1:length(varNames)
    newS.(varNames{i})=struct(varNames{i},[]);
end
S=orderfields(S,newS);

st=dbstack;
assignin('caller',saveName,S);
% evalin('caller',saveName);
if length(st)>1 % Not called from the base workspace.
    assignin('base',saveName,S);
end