function []=showVarButtonPushed(src,varName)

%% PURPOSE: SHOW THE CURRENTLY SELECTED VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% I don't think I really need to make a log of opening the variable.
if exist('varName','var')~=1
    runLog=true;
    varName=handles.Projects.showVarDropDown.Value;
else
    handles.Projects.showVarDropDown.Value=varName;
    runLog=false;
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

if isequal('NonFcnSettingsStruct',varName)
    load(projectSettingsMATPath,'NonFcnSettingsStruct');
    assignin('base',varName,NonFcnSettingsStruct);
    evalin('base',['openvar(''' varName ''');']);
    return;
end

% Organize the var data in table form, & display it
if isequal('VariableNamesList',varName)
    load(projectSettingsMATPath,'VariableNamesList');
    headers=fieldnames(VariableNamesList);
    for i=1:length(headers)
        array(:,i)=VariableNamesList.(headers{i});
    end  
    tableVar=array2table(array,'VariableNames',headers);
    assignin('base',varName,tableVar);
    evalin('base',['openvar(''' varName ''');']);
    return;
end 

if isequal('Digraph',varName)
    load(projectSettingsMATPath,'Digraph');
    newDigraph.Edges=Digraph.Edges;
    edgeHeaders=fieldnames(Digraph.Edges);
    edgeHeaders=edgeHeaders(~ismember(edgeHeaders,{'Properties','Row','Variables'}));
    nodeHeaders=fieldnames(Digraph.Nodes);
    nodeHeaders=nodeHeaders(~ismember(nodeHeaders,{'Properties','Row','Variables'}));
    edgeArray=cell(size(Digraph.Edges.(edgeHeaders{1}),1),length(edgeHeaders));
    nodeArray=cell(size(Digraph.Nodes.(nodeHeaders{1}),1),length(nodeHeaders));
    newDigraph.Edges=Digraph.Edges;
    newDigraph.Nodes=Digraph.Nodes;
    for i=1:length(edgeHeaders)
        edgeHeader=edgeHeaders{i};
        switch edgeHeader
            case 'FunctionNames' % 1xN cell array                
                for j=1:size(Digraph.Edges.(edgeHeader),1) % Each row
                    for k=1:2 % Each function
                        edgeArray{j,i}{1,k}=Digraph.Edges.(edgeHeader){j,k};
                    end
                end
            case {'EndNodes','NodeNumber','Color','RunOrder'} % 1xN arrays
                for j=1:size(Digraph.Edges.(edgeHeader),1)
%                     if iscell(Digraph.Edges.(edgeHeader))
%                         edgeArray{j,i}=Digraph.Edges.(edgeHeader){j,:};
%                     else
                    edgeArray{j,i}=Digraph.Edges.(edgeHeader)(j,:);
%                     end
                end
            case {'SplitCode'} % Scalars                
                edgeArray(:,i)=Digraph.Edges.(edgeHeader);
            otherwise
                disp('What edge column is this?');
                return;
        end        
    end
    for i=1:length(nodeHeaders)
        nodeHeader=nodeHeaders{i};
        switch nodeHeader
            case {'FunctionNames','Descriptions','Coordinates','NodeNumber','SpecifyTrials','IsImport'} % Scalars           
                if iscell(Digraph.Nodes.(nodeHeader))
                    nodeArray(:,i)=Digraph.Nodes.(nodeHeader);
                else
                    for j=1:size(Digraph.Nodes.(nodeHeader),1)
                        nodeArray{j,i}=Digraph.Nodes.(nodeHeader)(j,:);
                    end
                end
            case {'InputVariableNames','OutputVariableNames','InputVariableNamesInCode','OutputVariableNamesInCode'} % Cell arrays            
                for j=1:size(Digraph.Nodes.(nodeHeader),1)
                    if iscell(Digraph.Nodes.(nodeHeader))
                        nodeArray{j,i}=Digraph.Nodes.(nodeHeader){j};
                    else
                        nodeArray{j,i}=Digraph.Nodes.(nodeHeader)(j,:);
                    end
                end
            otherwise
                disp('What node column is this?');
                return;
        end        
    end
    newDigraph.Edges=cell2table(edgeArray,'VariableNames',edgeHeaders);
    newDigraph.Nodes=cell2table(nodeArray,'VariableNames',nodeHeaders);
    assignin('base',varName,newDigraph);
    evalin('base',['openvar(''' varName ''');']);
end