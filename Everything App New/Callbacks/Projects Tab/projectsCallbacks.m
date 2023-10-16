function [] = projectsCallbacks(src, event, args)

%% PURPOSE: CONTROLLER FOR THE PROJECTS TAB.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
allHandles = handles;

handles = handles.Projects;

if exist('event','var')~=1
    event = '';
end
if exist('args','var')~=1
    args = '';
end

if isfield(args,'UUID')
    uuid = args.UUID;
else
    uuid = getSelUUID(handles.allProjectsUITree);
end
if iscell(uuid)
    uuid = uuid{1}; % Shouldn't really happen, but just in case due to changes in getSelUUID
end

switch src
    case handles.addProjectButton

        % 1. Create all of the objects (AN & PJ with arguments)
        lg = createNewObject(true, 'Logsheet', '', '', '', true);        
        vw = createNewObject(true, 'View', 'ALL', '000000', '', true);
        
        an_args.Current_View = vw.UUID;
        an_args.Current_Logsheet = lg.UUID;        
        an = createNewObject(true, 'Analysis', '', '', '',  true, an_args);

        pj_args.Current_Analysis = an.UUID;
        [pj, pj_abs] = createNewObject(true, 'Project', '', '', '', true, pj_args);

        % 2. Set the current objects.
        setCurrent(pj.UUID, 'Current_Project_Name');
        setCurrent(an.UUID, 'Current_Analysis');
        setCurrent(vw.UUID, 'Current_View');
        setCurrent(lg.UUID, 'Current_Logsheet');

        % 3. Set the linkages for all of these objects.
        linkObjs(an, pj); 
        linkObjs(vw, an);
        linkObjs(lg, an);

        abs_node = getNode(handles.allProjectsUITree, pj_abs.UUID);
        if isempty(abs_node)
            abs_node = addNewNode(handles.allProjectsUITree, pj_abs.UUID, pj_abs.Name);
        end
        addNewNode(abs_node, pj.UUID, pj.Name);

        % 4. Select the project in the UI tree.
        selectNode(handles.allProjectsUITree, pj.UUID);

        % 5. Show the current project's settings in the projects tab of the GUI.
        projectsCallbacks(handles.allProjectsUITree);

        % 6. Show the project's settings in the rest of the GUI.
        projectsCallbacks(handles.currentProjectButton);

    case handles.removeProjectButton
        node = getNode(handles.allProjectsUITree, uuid);
        if isequal(node.NodeData.UUID, getCurrent('Current_Project_Name'))
            disp('Cannot delete active project!');
            return;
        end
        confirmAndDeleteObject(uuid, node);
        figure(fig);

    case handles.sortProjectsDropDown

    case handles.allProjectsUITree        
        computerID = getComputerID();
        struct = loadJSON(uuid);

        % Put the data and project path for this project into the text fields.
        if ~isInstance(uuid)
            dataPath = '';
            projectPath = '';
        else
            dataPath = struct.Data_Path.(computerID);
            projectPath = struct.Project_Path.(computerID);
        end
        handles.projectPathField.Value = projectPath;
        handles.dataPathField.Value = dataPath;    
        
        if isInstance(uuid)
            projectsCallbacks(handles.projectPathField);
            projectsCallbacks(handles.dataPathField);
        end

    case handles.currentProjectButton    
        disp('Switching to new project!');
        setCurrent(uuid, 'Current_Project_Name');
        fillAllUITrees(fig);
        Current_Analysis = getCurrent('Current_Analysis');
        selectNode(allHandles.Process.allAnalysesUITree, Current_Analysis);
        args.Type = 'All_AN';
        args.UUID = Current_Analysis;
        processCallbacks(allHandles.Process.selectAnalysisButton, '', args);
        handles.projectsLabel.Text = [getName(uuid) ' ' uuid];        

    case {handles.openProjectPathButton, handles.openDataPathButton}
        path = src.Value;
        openPathWithDefaultApp(path);

    case {handles.projectPathButton, handles.dataPathButton}
        path = getPathFromPicker(getCurrent(args));
        if exist(path,'dir')~=7
            return;
        end
        src.Value = path;
        projectsCallbacks(handles.projectPathField);

    case {handles.projectPathField, handles.dataPathField}        
        path = src.Value;
        prevPath = getCurrent(args, false, uuid);
        if exist(path,'dir')~=7
            path = prevPath;
        end
        src.Value = path;
        setCurrent(path, args);
end