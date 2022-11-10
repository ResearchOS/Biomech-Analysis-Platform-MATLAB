function []=axesLimDeleteFcn(src,pguiFig)

%% PURPOSE: STORE THE SETTINGS BACK TO THE PGUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');
plotName=getappdata(fig,'plotName');
axLetter=getappdata(fig,'axLetter');

Plotting=getappdata(pguiFig,'Plotting');

for dim=['X','Y','Z']
    if axLims.(dim).IsHardCoded==1
        axLims.(dim).Level='P';
    end
end

Plotting.Plots.(plotName).Axes.(axLetter).AxLims=axLims;

setappdata(pguiFig,'Plotting',Plotting);
