function [CODEDIR, FORMDATDIR, STIMDIR, OUTDIR] = directorySetup()
%directorySetup creates global variables hold your filepaths

global  CODEDIR FORMDATDIR STIMDIR OUTDIR
    CODEDIR  = 'C:\Users\Brock Carlson\Documents\GitHub\BMC_AdaptdcosFigures\';
    FORMDATDIR   = 'C:\Users\Brock Carlson\Box\BRFS to iScience\FormattedDataOutputs\';
    STIMDIR  = 'D:\brfs_STIM_220827';
    OUTDIR   = 'C:\Users\Brock Carlson\Documents\MATLAB\PlotOutputs\';
end