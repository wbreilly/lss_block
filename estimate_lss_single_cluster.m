function[b] = estimate_lss_single(b)
% estimate first level for every sequence and subject
% 
% dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_native_10_20_17';
% scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/lss_singeltrial';
% 
% subjects    = ['s001' 's002' 's003' 's004' 's007' 's008' 's009' 's010' 's011' 's015' 's016' 's018' 's019' 's020' 's022' 's023' 's024' 's025'};
% runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  
% 
% b.scriptdir = scriptdir;
% b.runs      = runs;



    %--Loop over subjects
% for isub = 1:length(subjects)
% initialize
% b.curSubj   = subjects{isub};
% b.dataDir   = fullfile(dataDir, b.curSubj);

%% get condition files from saved .mat
cond_dir = '/home/wbreilly/sms_scan_crick/cluster_preproc_native_8_6_18/cond_files';
for i = 1:length(b.runs)
    b.rundir(i).cond = cellstr(spm_select('FPList', cond_dir, [ '^cond.*' b.curSubj sprintf('.*%s.*.mat', b.runs{i})]));
end % end i b.runs
%%    

% loop over runs
for irun = 1:length(b.runs)
    % loop over sequences
    for iseq = 1:25
        % condition file for current sequence and run
        trialnames = ls(sprintf('%s/%s/*/SPM.mat',b.dataDir,b.runs{irun}));
        trialnames = strsplit(trialnames);

        matlabbatch{iseq}.spm.stats.fmri_est.spmmat = cellstr(trialnames(iseq));
        % I **THINK** ResMS.nii is written and kept by defualt,
        % changing this to 1 keeps res for every TR.. not what I need
        % for t-maps
        matlabbatch{iseq}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{iseq}.spm.stats.fmri_est.method.Classical = 1;

    end % end iseq
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end % end i run
% end % end isub

end 


