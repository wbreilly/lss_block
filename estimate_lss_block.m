% estimate first level for every sequence and subject

dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_9_21_17';
scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/seq_block_rsa/lss_block';

subjects    = {'s001' 's002' 's003' 's004' 's007' 's008'};
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  

b.scriptdir = scriptdir;
b.runs      = runs;



    %--Loop over subjects
for isub = 1:length(subjects)
    % initialize
    b.curSubj   = subjects{isub};
    b.dataDir   = fullfile(dataDir, b.curSubj);
    
    %% get condition files from saved .mat
    cond_dir = '/Users/wbr/walter/fmri/sms_scan_analyses/seq_block_rsa/';
    for i = 1:length(b.runs)
        b.rundir(i).cond = cellstr(spm_select('FPList', cond_dir, [ '^cond.*' b.curSubj sprintf('.*%s.*.mat', b.runs{i})]));
    end % end i b.runs
    %%    
    
    % loop over runs
    for irun = 1:length(b.runs)
        % loop over sequences
        for iseq = 1:5
            % condition file for current sequence and run
            cond_file = b.rundir(irun).cond(iseq);
            load(char(cond_file), 'names')
            trialdir = fullfile(b.dataDir, b.runs(irun), names{1}, 'SPM.mat');
            
            matlabbatch{iseq}.spm.stats.fmri_est.spmmat = cellstr(trialdir);
            matlabbatch{iseq}.spm.stats.fmri_est.write_residuals = 0;
            matlabbatch{iseq}.spm.stats.fmri_est.method.Classical = 1;
        
        end % end iseq
        spm('defaults','fmri');
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch);
    end % end i run
end % end isub

% run


