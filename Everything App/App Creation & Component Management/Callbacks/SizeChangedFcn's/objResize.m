function []=objResize(obj,relPos,size)

%% PURPOSE: RESIZE THE SPECIFIED OBJECT
newFontSize=evalin('caller','newFontSize;');
figSize=evalin('caller','figSize;');

if size(2)>2
    pos=round([relPos.*figSize size(1)*figSize(1) size(2)]);
else
    pos=round([relPos.*figSize size.*figSize]);
end

obj.Position=pos;

obj.FontSize=newFontSize;