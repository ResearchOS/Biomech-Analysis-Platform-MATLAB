function [allTable]=collectData(metaVarNames,varNames,allTrialNames,multiVar)

%% PURPOSE: PULL THE DATA TOGETHER INTO A TABLE TO ANALYZE.

if exist('multiVar','var')~=1
    multiVar={''};
end

%% Get the number of rows in the table.
subNames=fieldnames(allTrialNames);
numRows=0;
tableTrialNames={};
trialSubNames={};
multiVarNames={};
nMulti=length(multiVar);
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName));
    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)

            for multNum=1:nMulti
                numRows=numRows+1;
                trialSubNames=[trialSubNames; subName];
                tableTrialNames=[tableTrialNames; trialName];
                multiVarNames=[multiVarNames; multiVar{multNum}];
            end
        end

    end

end

%% Put the variables into the table.
dataPath=getDataPath();
if ~isempty(multiVarNames)
    allTable=[trialSubNames tableTrialNames multiVarNames];
else
    allTable=[trialSubNames tableTrialNames];
    multiVarNames=cell(size(tableTrialNames));
end
startColNum=size(allTable,2);
rowNum=0;
for i=1:length(tableTrialNames)

    rowNum=rowNum+1;
    trialName=tableTrialNames{i};
    subName=trialSubNames{i};
    multiVarCurr=multiVarNames{i};

    for j=1:length(metaVarNames)
        try
            data=loadMAT(dataPath,metaVarNames{j},subName,trialName);
        catch
            data=loadMAT(dataPath,metaVarNames{j},subName);
        end

        if ~isempty(multiVarCurr) && isfield(data,multiVarCurr)
            allTable{rowNum,startColNum+j}=data.(multiVarCurr);
        else
            allTable{rowNum,startColNum+j}=data;
        end
    end

    for j=1:length(varNames)
        data=loadMAT(dataPath,varNames{j},subName,trialName);

        if ~isempty(multiVarCurr) && isfield(data,multiVarCurr)
            allTable{rowNum,startColNum+j+length(metaVarNames)}=data.(multiVarCurr);
        else
            allTable{rowNum,startColNum+j+length(metaVarNames)}=data;
        end
    end

end