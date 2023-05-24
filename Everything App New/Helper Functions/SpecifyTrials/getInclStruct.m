function [inclStruct]=getInclStruct(specifyTrials)

%% PURPOSE: RETURN THE INCLUSION CRITERIA FROM THE SPECIFY TRIALS.

slash=filesep;

commonPath=getCommonPath();

stFolder=[commonPath slash 'SpecifyTrials'];

oldPath=cd(stFolder);

inclStruct=struct();

if isempty(specifyTrials)
    return;
end

for i=1:length(specifyTrials)

    currST=specifyTrials{i};

    fullPath=getClassFilePath(currST, 'SpecifyTrials');
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