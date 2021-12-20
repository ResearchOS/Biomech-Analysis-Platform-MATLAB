function [mocapHelper]=mocapImportMetadataA_Spr21TWWBiomechanics()

%% PURPOSE: THIS IS ALL METADATA RELATED TO IMPORTING MOTION CAPTURE DATA

%% MANDATORY METADATA. DO NOT CHANGE VARIABLE NAMES OR TYPES, ONLY THEIR VALUES. THESE ARE REQUIRED FOR 100% OF PROJECTS.
collectionSite='Zaferiou Lab'; % The physical location/site where the data was collected.

% If any rigid bodies (that are not part of a body segment), specify them
% here:
mocapHelper.RigidBodies.NorthTripod={'NorthTripod1','NorthTripod2','NorthTripod3','NorthTripod4'};
mocapHelper.RigidBodies.SouthTripod={'SouthTripod1','SouthTripod2','SouthTripod3','SouthTripod4'};

% Need to specify which markers are associated with which segments and for what purpose? Or should this be done in a different location?
% These markers are eligible to be "best tracking markers" for their
% respective segments. Therefore, this list does not include any
% anatomic-only markers
mocapHelper.Segments.HEAD={'LAH','RAH','LPH','RPH'};
mocapHelper.Segments.TORSO=0;
mocapHelper.Segments.LUA=0;
mocapHelper.Segments.RUA=0;
mocapHelper.Segments.LFARM=0;
mocapHelper.Segments.RFARM=0;
mocapHelper.Segments.LHAND={'LWA','LWB','LFIN','LHAND_4'};
mocapHelper.Segments.RHAND={'RWA','RWB','RFIN','RHAND_4'};
mocapHelper.Segments.PELVIS=0;
mocapHelper.Segments.LTHIGH=0;
mocapHelper.Segments.RTHIGH=0;
mocapHelper.Segments.LSHANK=0;
mocapHelper.Segments.RSHANK=0;
mocapHelper.Segments.LFOOT={'LFCC','LFM1','LFM5','LDP1'};
mocapHelper.Segments.RFOOT={'RFCC','RFM1','RFM5','RDP1'};

% Need to specify EITHER the orientations of the mocap and cardinal coordinate system using cardinal directions ('N', 'E', 'S', 'W') OR allow the
% user to directly specify a rotation matrix from one to the other.

% To specify the two reference frames individually
mocapHelper.RefFrame.Cardinal.PosX='E';
mocapHelper.RefFrame.Cardinal.PosY='N';
mocapHelper.RefFrame.Cardinal.PosZ='Up';
mocapHelper.RefFrame.Mocap.PosX='W';
mocapHelper.RefFrame.Mocap.PosY='Up';
mocapHelper.RefFrame.Mocap.PosZ='N';

mocapRefFrameRotMatrix=ref2cardFrameRotMatrix(mocapHelper.Axes.Cardinal,mocapHelper.Axes.Mocap);

% To specify the rotation matrix directly
mocapRefFrameRotMatrix=[-1 0 0; 0 0 1; 0 1 0];

ProjHelper.Info.Mocap.RotMatrix2Cardinal=mocapRefFrameRotMatrix;
    
end