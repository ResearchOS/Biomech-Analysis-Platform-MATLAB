function []=axesLimDeleteFcn(src,pguiFig)

%% PURPOSE: STORE THE SETTINGS BACK TO THE PGUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');
plotName=getappdata(fig,'plotName');
axLetter=getappdata(fig,'axLetter');

Plotting=getappdata(pguiFig,'Plotting');
VariableNamesList=getappdata(pguiFig,'VariableNamesList');

for dim=['X','Y','Z']
    if axLims.(dim).IsHardCoded==1
        axLims.(dim).Level='P';
    end

    varNames=axLims.(dim).VariableNames;

    cutVarNames=cell(length(varNames),1);
    splitCodes=cell(length(varNames),1);
    for i=1:length(cutVarNames)
        spaceIdx=strfind(varNames{i},' ');
        cutVarNames{i}=varNames{i}(1:spaceIdx-1);
        splitCodes{i}=varNames{i}(spaceIdx+2:end-1);
    end

    % 2. Get the corresponding save names
    [~,a,~]=intersect(VariableNamesList.GUINames,cutVarNames,'stable');
    saveNames=VariableNamesList.SaveNames(a);

    % 3. Append the split codes to them
    for i=1:length(saveNames)
        saveNames{i}=[saveNames{i} '_' splitCodes{i}];
    end

    axLims.(dim).SaveNames=saveNames;
end

Plotting.Plots.(plotName).Axes.(axLetter).AxLims=axLims;

setappdata(pguiFig,'Plotting',Plotting);
