function [trialStruct]=gapFill(trialStruct,markerName)

% Inputs:
% trialStruct: Equivalent to importStruct.Subject(subNum).(strTrialName)

% Mocap data should all be stored as Nx3 matrices!!
A= trialStruct.Data.Mocap.Raw.Cardinal.(markerName);

% Initialize
trialStruct.Info.Mocap.Markers.GapCounter.(markerName)=0;
trialStruct.Info.Mocap.Markers.GapIndices.(markerName)(1:length(A))=logical(false(1,length(A)));

if any(isnan(A),'all') % if nans are there instead of zeros
    %% Gap Filling .. expecting NaN if no mkr data
    %                     A= importStruct.Subject(subNum).(trialName).Mocap.Raw.(markerName);
    %             markerName
    assert(isequal(sum(isnan(A(:,1))),sum(isnan(A(:,2))))); assert(isequal(sum(isnan(A(:,1))),sum(isnan(A(:,3))))); assert(isequal(sum(isnan(A(:,2))),sum(isnan(A(:,3)))));
    trialStruct.Info.Mocap.Markers.GapCounter.(markerName)=sum(isnan(A(:,1))); % scalar count
    
    if trialStruct.Info.Mocap.Markers.GapCounter.(markerName)>=.97*length(A) % If more than 97% of trial is NaNs, remove trial from processing.
        %                         A=zeros(size(A));
        if ~contains(markerName,{'UNLABELED','UNASSIGNED'})
            trialStruct.Info.Mocap.Markers.GapIndices.(markerName)(1:length(A))=logical(true(1,length(A)));
            trialStruct.Info.IsPerfect{1}=0;
            trialStruct.Info.NotPerfectBecause{1}='All Data NaN';
        end
        
    else %otherwise, if it's a small gap, fill it with its previous value
        for index=1:length(A)
            if isnan(A(index,1)) && index==1
                firstValueIndex=find(~isnan(A),1);
                A(index,1:3)=A(firstValueIndex,1:3);
                %                             A(index,1:3)=nanmean(A(:,1:3)); % don't use
                %                             this unless you want to fill prior nans with
                %                             mean data across whole trial!
                trialStruct.Info.Mocap.Markers.GapIndices.(markerName)(index)=logical(true);
            end
            if isnan(A(index,1))  && index>=2
                A(index,1:3)=A(index-1,1:3);
                trialStruct.Info.Mocap.Markers.GapIndices.(markerName)(index)=logical(true);
            end
        end
    end
    trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)=A;
else % no gap
    trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)=A;
    trialStruct.Info.Mocap.Markers.GapIndices.(markerName)(1:length(trialStruct.Data.Mocap.Raw.Cardinal.(markerName)))=false;
    
end

end