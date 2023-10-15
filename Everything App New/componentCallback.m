function [] = componentCallback(src, event, args)

%% PURPOSE: SERVES AS THE TOP-LEVEL CONTROLLER.

currTab = getCurrent('Current_Tab_Title');

if exist('event','var')~=1
    event = '';
end

if exist('args','var')~=1
    args.Type = '';
end

switch currTab
    case 'Projects'
        projectsCallbacks(src, event, args);
    case 'Import'
        importCallbacks(src, event, args);
    case 'Process'
        processCallbacks(src, event, args);
    case 'Plot'
        plotCallbacks(src, event, args);
    case 'Stats'
        statsCallbacks(src, event, args);
    case 'Settings'
        settingsCallbacks(src, event, args);
end