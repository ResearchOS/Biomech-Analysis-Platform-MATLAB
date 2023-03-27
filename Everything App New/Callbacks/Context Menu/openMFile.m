function []=openMFile(src,event)

%% PURPOSE: OPEN THE ASSOCIATED .M FILE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

[name,id,psid]=deText(text);

% Get the current UI tree
parent=getUITreeFromNode(selNode);

% if ismember(parent,[handles.Process.groupUITree,handles.Plot.plotUITree])
%     text=[name '_' id];
% end

structClass=getClassFromUITree(parent);

psStruct=struct;
if ~isempty(psid)
    piText=[name '_' id];
    psText=text;
    fullPathPS=getClassFilePath(psText, structClass);
    psStruct=loadJSON(fullPathPS);
end
if isempty(psid)
    piText=text;
end

% If PS, check if PI is the one with the MFileName.
% If PI, open the MFileName or throw errors.
fullPathPI=getClassFilePath(piText, structClass);
piStruct=loadJSON(fullPathPI);

if isfield(piStruct,'MFileName')
    assert(~isfield(psStruct,'MFileName'));
    fileName=piStruct.MFileName;
elseif isfield(psStruct,'MFileName')
    assert(~isfield(piStruct,'MFileName'));
    fileName=psStruct.MFileName;
end

if isfield(piStruct,'Level')
    level=piStruct.Level;
elseif isfield(psStruct,'Level')
    level=psStruct.Level;
end

try
    filePath=which(fileName);
    edit(filePath);
    return;
catch % The file does not exist.
end

%% Create new file
fileName=inputdlg('M file does not exist, create it?','Create new M file?',[1 50],{fileName});
if isempty(fileName)
    return;
end

fileName=fileName{1};

if isequal(fileName(end-1:end),'.m')
    fileName=fileName(1:end-5);
elseif isequal(fileName(end-3:end),'json')
    fileName=fileName(1:end-4);
end

slash=filesep;

switch structClass
    case 'Process'
        classFolder='New Process Functions';
        templateName='Template_Process';
        switch level
            case 'P'
                args={};
            case 'PST'
                args={'allTrialNames'};
            case 'S'
                args={'subName'};
            case 'ST'
                args={'subName','trialNames'};
            case 'T'
                args={'subName','trialName','repNum'};
        end
    case 'Plot'
        classFolder=['Plot' slash 'Plot Properties'];
        templateName='Template_Plot';
        switch level
            case {'P','PC'}
                args={'fig','handles'};
            case 'S'
                args={'fig','handles','subName'};
            case 'T'
                args={'fig','handles','subName','trialName','repNum'};
        end
    case 'Component'
        classFolder=['Plot' slash 'New Components'];
        templateName='Template_Component';
        switch level
            case {'P'}
                args={};
            case 'PC'
                args={'ax','allTrialNames','plotName'};
            case 'S'
                args={'subName'};
            case 'T'
                args={'subName','trialName, repNum'};
        end
end

rootPath=[getProjectPath slash classFolder];
filePath=[rootPath slash fileName '.m'];

% Generate the new file from the template
templateName=[templateName '_' level];
templatePath=which(templateName);
createFileFromTemplate(templatePath,filePath,fileName,args);
