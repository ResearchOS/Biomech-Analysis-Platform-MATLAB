function [trialStruct]=smooth_CSAPS(trialStruct)

marker_names=fieldnames(trialStruct.Data.Mocap.GapFilled.Cardinal);
for m=1:length(marker_names)
    markerName=upper(marker_names{m});
    if trialStruct.Info.Mocap.Markers.GapCounter.(markerName)==0 % Number of gaps=0
        trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)=trialStruct.Data.Mocap.Raw.Cardinal.(markerName);
    else
        if ~contains(markerName,'UNLABELED') % Don't smooth Unlabeled data.
            
            %CSAPS TO SMOOTH IF THERE WERE GAPS
            p = .2; %csaps threshold the larger the number, the more conservative the smoothing is...
            for xyz=1:3
                x=[1: length(trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz))].';
                y=double(trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz));
                if isempty(x) || isempty(y) || sum(y)==0
                    trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz)=y;
                else
                    out = csaps(x,y,p);
                    trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz)=fnval(x,out);
                end
            end
        end
    end
    % Check data matrix sizing for rotation. Don't double
    % rotate! The raw data should already be in the Cardinal frame.
%     if size(trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName),1)~=size(trialStruct.Info.Mocap.RotMatrix2Cardinal,1)
%         trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)=trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName);
%     else
%         trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)=trialStruct.Data.Mocap.GapFilled.Cardinal.(markerName)';
%     end
end

end