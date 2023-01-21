function [inclStruct]=getInclStruct(src,specifyTrials)

%% PURPOSE: RETURN THE INCLUSION CRITERIA FROM THE SPECIFY TRIALS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

commonPath=getCommonPath(fig);

stFolder=[commonPath slash 'SpecifyTrials'];

oldPath=cd(stFolder);

inclStruct=struct();

for i=1:length(specifyTrials)

    currST=specifyTrials{i};

    fullPath=getClassFilePath(currST, 'SpecifyTrials', fig);
    stStruct=loadJSON(fullPath);

    inclStruct.Include.Condition(i).Name=currST;

    logHeaders=stStruct.Logsheet_Headers;
    logLogic=stStruct.Logsheet_Logic;
    logValue=stStruct.Logsheet_Value;

    for j=1:length(logHeaders)
        inclStruct.Include.Condition(i).Logsheet(j).Name=logHeaders{j};
        inclStruct.Include.Condition(i).Logsheet(j).Logic=logLogic{j};
        inclStruct.Include.Condition(i).Logsheet(j).Value=logValue{j};
    end

end

cd(oldPath);