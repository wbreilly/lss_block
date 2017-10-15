function [] = batch_lss_block

% Author: Walter Reilly 
% LSS estimation on blocks of consecutive trials
% Created 9_16_17


%====================================================================================
%			Specify Variables
%====================================================================================

%-- Directory Information
% Paths to relevant directories.
% dataDir   = path to the directory that houses the MRI data
% scriptdir = path to directory housing this script (and auxiliary scripts)
% QAdir     = Name of output QA directory

dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_10_8_17';
scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/lss_singletrial'; 


%-- Info for Subjects
% Subject-specific information.
% subjects  = cellstring containing the subject IDs
% runs      = cellstring containg the IDs for each BOLD time series
%
% Assumes that all files have unique filenames that can be identified with
% a combination of the cell strings above. For example, bold files NEED to
% look something like:
%   /dataDir/sub-001/func/sub-001_encoding_run-001_bold.nii
%   /dataDir/sub-001/func/sub-001_encoding_run-002_bold.nii
%   /dataDir/sub-001/func/sub-001_retrieval_run-001_bold.nii
%   /dataDir/sub-001/func/sub-001_retrieval_run-002_bold.nii
%
%  See BIDS format

subjects    =  {'s009'};%{'s002' 's003' 's004' 's007' 's008' 's010' 's011' 's009'};
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  

%-- Auto-accept
% Do you want to run all the way through without asking for user input?
% if 0: will prompt you to take action;
% if 1: skips realignment and ArtRepair if already run, overwrites output files

auto_accept = 0;

% flags


%====================================================================================
%			Routine (DO NOT EDIT BELOW THIS BOX!!)
%====================================================================================

%-- Clean up

clc
fprintf('Initializing and checking paths.\n')


%-- Check for required functions

% SPM
if exist('spm','file') == 0
    error('SPM must be on the path.')
end

fprintf('Running batch lss')

%--Loop over subjects
for i = 1:length(subjects)
    
    % Define variables for individual subjects - General
    b.curSubj   = subjects{i};
    b.runs      = runs;
    b.dataDir   = fullfile(dataDir, b.curSubj);
        
    % Define variables for individual subjects - QA General
    b.scriptdir   = scriptdir;
    b.auto_accept = auto_accept;
    b.messages    = sprintf('Messages for subject %s:\n', subjects{i});
    
    % Check whether first level has already been run for a subject
    
    % Initialize diary for saving output
    diaryname = fullfile(b.dataDir, 'batch_single_lss_diary_output.txt');
    diary(diaryname);
    
    %======================================================================
    % Run functions (at this point, this could all be in one
    % script/function, but where's the fun in that?
    %======================================================================
    
    % Run lss script
    fprintf('--LSSing--\n')
    [b] = lss_single(b);
    fprintf('------------------------------------------------------------\n')
    fprintf('\n')
    
end % i (subjects)

fprintf('LSS FTW!!\n')
diary off



end % end function