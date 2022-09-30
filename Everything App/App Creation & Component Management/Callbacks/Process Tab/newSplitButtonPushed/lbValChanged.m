function []=lbValChanged(src,rgblist)

fig=ancestor(src,'figure','toplevel');

handles=getappdata(fig,'handles');
color=handles.lb.Value;
colorIdx=ismember(handles.lb.Items,color);
rgb=rgblist(colorIdx,:);
patchObj=patch(handles.ax,[0 0 1 1],[0 1 1 0],rgb);
handles.patch=patchObj;
setappdata(fig,'handles',handles);

end