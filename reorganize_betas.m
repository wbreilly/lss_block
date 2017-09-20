% reorganize betas
% Author: Walter Reilly
% Created: 9_19_17

% Takes output from LSS and reorganizes and renames betas to be compatible
% with RSA toolbox in the sms_scan paradigm


dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_9_16_17';
scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/seq_block_rsa/lss_block'; 

subjects    = {'s002' 's003' 's004' 's007' 's008'};
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  


%-- Clean up

clc
fprintf('Initializing and checking paths.\n')


%-- Check for required functions

% SPM
if exist('spm','file') == 0
    error('SPM must be on the path.')
end

fprintf('You beta reorganize!!')

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
    diaryname = fullfile(b.dataDir, 'batch_block_lss_diary_output.txt');
    diary(diaryname);
    
    %%
    % do the stuff
    
    % make a new directory in which to place curSubj's organized betas
    b.betaDir = fullfile(b.dataDir, b.curSubj, 'beta_4_rsa');
    makedr(char(b,betaDir));
    
    % loop through runs
    for irun = 1:length(b.runs)
        [b.rundir(irun).seqs, b.rundir(irun).beta] = cellstr(spm_select( 
        
    end % end irun
    
    
    
    
    
end % i (subjects)