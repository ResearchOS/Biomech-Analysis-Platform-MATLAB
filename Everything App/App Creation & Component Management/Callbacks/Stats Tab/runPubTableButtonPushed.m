function []=runPubTableButtonPushed(src,event)

%% PURPOSE: CREATE THE PUBLICATION TABLE AS SPECIFIED. BY DEFAULT THIS USES THE MOST RECENTLY CREATED VERSION OF THE STATS TABLES, BASED ON THE DATES IN THEIR NAMES.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

pubTableName=handles.Stats.pubTablesUITree.SelectedNodes.Text;

pubTable=Stats.PubTables.(pubTableName);

disp(['Creating table for publication: ' pubTableName]);

load(getappdata(fig,'logsheetPathMAT'),'logVar');

projectName=getappdata(fig,'projectName');
slash=filesep;
matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];

oldPath=cd(getappdata(fig,'codePath')); % To be sure of which specifyTrials are being used.
pubTableOut=cell(pubTable.Size.numRows,pubTable.Size.numCols);
numSigFigs=Stats.PubTables.(pubTableName).SigFigs;
for row=1:pubTable.Size.numRows

    for col=1:pubTable.Size.numCols

        currCell=pubTable.Cells(row,col);

        specifyTrials=currCell.SpecifyTrials;

        if isempty(specifyTrials)
            disp(['Row ' num2str(row) ' Column ' num2str(col) ' Missing SpecifyTrials!']);
            return;
        end

        inclStruct=feval(specifyTrials);
        allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]); % The list of trials' data to retrieve.
        tableName=currCell.tableName; % The Stats table to look for data in.
        varName=currCell.varName; % The variable in the Stats table to extract.
        summType=currCell.summMeasure;

        if isequal(tableName,'Literal')
            pubTableOut{row,col}=currCell.value;
            continue;
        end
        fileVarNames=whos('-file',[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat']);
        fileVarNames={fileVarNames.name}';
        fileVarNames=fileVarNames(contains(fileVarNames,tableName));

        % Get the name of the most recent table.
        dateTimes=cell(length(fileVarNames),1);
%         times=cell(length(varNames),1);
        for i=1:length(fileVarNames)
            underscoreIdx=strfind(fileVarNames{i},'_');
            dateTimes{i}=fileVarNames{i}(underscoreIdx(end-1)+1:end);
%             times{i}=varNames{i}(underscoreIdx(end)+1:end);            
        end

        % Get the largest date.
        dateTimes=datetime(dateTimes,'InputFormat','ddMMMyyyy_HHmmss');
        lastDate=char(max(dateTimes));
        lastDate=lastDate(~ismember(lastDate,'-'));
        lastDate=lastDate(~ismember(lastDate,':'));
        lastDate=[lastDate(1:9) '_' lastDate(11:end)];

        dateIdx=contains(fileVarNames,lastDate);

        assert(sum(dateIdx)==1);

        fileVarName=fileVarNames{dateIdx};

        var=load(matFilePath,fileVarName);
        var=var.(fileVarName);

        varColIdx=ismember(var(1,:),varName);

        assert(sum(varColIdx)==1);

        % Get the name of the multiple repetitions header variable   
        
        for i=1:length(Stats.Tables.(tableName).RepetitionColumns)
            if isempty(Stats.Tables.(tableName).RepetitionColumns(i).Mult)
                continue;
            end
            if ~ismember(varName,Stats.Tables.(tableName).RepetitionColumns(i).Mult.DataVars)
                continue;
            end
            repVarName=Stats.Tables.(tableName).RepetitionColumns(i).Name;
            repVarColIdx=ismember(var(1,:),repVarName);
            break;
        end

        repVarValue=Stats.PubTables.(pubTableName).Cells(row,col).repVar; % The repetition variable value for this cell.
        
        % Get the row numbers in the stats table.
        rowsIdx=[];
        subNames=fieldnames(allTrialNames);
        for subNum=1:length(subNames)   
            subName=subNames{subNum};
            currTrials=fieldnames(allTrialNames.(subName));
            for trialNum=1:length(allTrialNames.(subName))
                trialName=currTrials{trialNum};
                newRowIdx=find((ismember(var(:,1),trialName) & ismember(var(:,repVarColIdx),repVarValue))==1);

                assert(length(newRowIdx)==1);
                rowsIdx=[rowsIdx; newRowIdx];
            end
        end

        selData=cell2mat(var(rowsIdx,varColIdx));

        if isequal(summType,'Mean ± Stdev')
            varLoc=mean(selData,'omitnan');
            varSpread=std(selData,0,'omitnan');
        elseif isequal(summType,'Median ± IQR')
            varLoc=median(selData,'omitnan');
            varSpread=iqr(selData);
        end

        varLoc=str2double(num2str(varLoc,numSigFigs));
        varSpread=str2double(num2str(varSpread,numSigFigs));
        varChar=[num2str(varLoc) ' ± ' num2str(varSpread)];

        pubTableOut{row,col}=varChar;

    end

end
cd(oldPath); % Back to the original folder.

%% Save the compiled table.
currDate=char(datetime('now','TimeZone','America/New_York'));
currDate=currDate(~ismember(currDate,':'));
currDate=currDate(~ismember(currDate,'-'));
currDate=strrep(currDate,' ','_');
varName=['PubTable_' pubTableName '_' currDate];

eval([varName '= pubTableOut;']);

save(matFilePath,varName,'-append');

assignin('base',varName,pubTableOut);

disp(['Created table for publication: ' varName]);