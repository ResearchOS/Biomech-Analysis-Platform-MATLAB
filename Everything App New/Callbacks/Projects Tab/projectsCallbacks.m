function [] = projectsCallbacks(src, event, args)

%% PURPOSE: CONTROLLER FOR THE PROJECTS TAB.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
allHandles = handles;

handles = handles.Projects;

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

        abs_node = getNode(handles.Process.allProjectsUITree, pj_abs.UUID);
        if isempty(abs_node)
            abs_node = addNewNode(handles.Process.allProjectsUITree, pj_abs.UUID, pj_abs.Name);
        end
        addNewNode(abs_node, pj.UUID, pj.Name);

        % 4. Select the project in the UI tree.
        selectNode(handles.allProjectsUITree, pj.UUID);

        % 5. Show the current project's settings in the projects tab of the GUI.
        projectsCallbacks(handles.allProjectsUITree);

        % 6. Show the project's settings in the rest of the GUI.
        projectsCallbacks(handles.currentProjectButton);

    case handles.removeProjectButton

    case handles.sortProjectsDropDown

    case handles.allProjectsUITree

    case handles.currentProjectButton

    case handles.projectPathButton

    case handles.dataPathButton



end