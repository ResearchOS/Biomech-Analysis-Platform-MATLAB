function []=axesLimDeleteFcn(src,pguiFig)

%% PURPOSE: STORE THE SETTINGS BACK TO THE PGUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');
plotName=getappdata(fig,'plotName');
axLetter=getappdata(fig,'axLetter');
isMovie=getappdata(fig,'isMovie');

Plotting=getappdata(pguiFig,'Plotting');
VariableNamesList=getappdata(pguiFig,'VariableNamesList');

trialName=Plotting.Plots.(plotName).ExTrial.Trial;
subName=Plotting.Plots.(plotName).ExTrial.Subject;
projectName=getappdata(pguiFig,'projectName');

slash=filesep;

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
    matFilePathTrial=[getappdata(pguiFig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
    movieAxLimsVar.(dim)=[];
    if isMovie==1 && ~isempty(saveNames)
        load(matFilePathTrial,saveNames{1});
        movieAxLimsVar.(dim)=eval(saveNames{1});
    end
end

Plotting.Plots.(plotName).Axes.(axLetter).AxLims=axLims;
Plotting.Plots.(plotName).Axes.(axLetter).MovieAxLimsVar=movieAxLimsVar;

setappdata(pguiFig,'Plotting',Plotting);
