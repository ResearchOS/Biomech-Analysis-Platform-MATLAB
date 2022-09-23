function []=changeViewButtonPushed(src,event)

%% PURPOSE: TOGGLE THE GRAPH BETWEEN 2D AND 3D VIEW

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Plotting=getappdata(fig,'Plotting');
% 
% selComp=handles.Plot.currCompUITree.SelectedNodes;
% 
% if isfield(Plotting.Plots.(plotName),selComp.Text)
% 
% % Find the current axes handle
% compParent=selComp;
% for i=1:3
% 
%     compParent=compParent.Parent;
% 
%     if all(ismember(compParent.Text,double('A'):double('Z')))
%         break;
%     end
% 
% end
% 
% axLetter=compParent.Text;

[az,el]=view(handles.Plot.plotPanel.Children(1));

if isequal(az,0)
    view(handles.Plot.plotPanel.Children(1),3);
else
    view(handles.Plot.plotPanel.Children(1),2);
end