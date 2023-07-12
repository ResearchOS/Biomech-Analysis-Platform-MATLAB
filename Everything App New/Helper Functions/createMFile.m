function [fullPath] = createMFile(fileName, class)

%% PURPOSE: CREATE A NEW .M FILE WITH THE GIVEN FILE NAME.

if isequal(fileName(end-1:end),'.m')
    fileName=fileName(1:end-5);
elseif isequal(fileName(end-3:end),'json')
    fileName=fileName(1:end-4);
end

slash=filesep;

switch class
    case 'Process'
        classFolder='Process_Functions';
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
        classFolder=['Plots'];
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
        classFolder=['Components'];
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

rootPath=[getCommonPath slash 'Code' slash classFolder];
filePath=[rootPath slash fileName '.m'];

% Check one more time if the specified file already exists
if exist(filePath,'file')==2
    edit(filePath);
else
    % Generate the new file from the template
    templateName=[templateName '_' level];
    templatePath=which(templateName);
    folder=fileparts(filePath);
    if exist(folder,'dir')~=7
        mkdir(folder);
    end
    createFileFromTemplate(templatePath,filePath,fileName,args);
end