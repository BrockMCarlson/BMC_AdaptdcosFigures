function [CODEDIR, FORMDATDIR, STIMDIR, OUTDIR] = directorySetup()
%directorySetup creates global variables hold your filepaths

global  CODEDIR FORMDATDIR STIMDIR OUTDIR
    CODEDIR  = 'C:\Users\Brock\Documents\MATLAB\GitHub\BMC_AdaptdcosFigures\';
    FORMDATDIR   = 'C:\Users\Brock\Documents\MATLAB\formattedDataOutputs\iScienceSubmission\';
    STIMDIR  = 'C:\Users\Brock\Documents\MATLAB\brfs_STIM_220827';
    OUTDIR   = 'C:\Users\Brock\Documents\MATLAB\plotOutputs\plot outputs for BRFS to iScience\';
end