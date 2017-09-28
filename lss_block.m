function [b] = lss_block(b)

% Block lss one subject and run at a time. Creates one spm.mat for each
% sequence (5 consecutive trials) and across 3 repetitions (3 chunks of 5
% trials). One Beta image for all 15 of those trials. After estimation
% beta images will be passed to RSA toolbox. 
% Author: Walter Reilly

% Usage:
%
%	b = lss_block(b)
%   
%   input arguments:
%
%	b = memolab qa batch structure containing the fields:
%
%       b.dataDir     = fullpath string to the directory where the functional MRI data
%                       is being stored
%
%       b.runs        = cellstring with IDs for each functional time series
%
%       b.auto_accept = a true/false variable denoting whether or not the 
%                       user wants to be prompted
%
%       b.rundir      = a 1 x n structure array, where n is the number of
%                       runs, with the fields:
%
%       b.rundir.rp = motion regressors
% 
%       b.rundir.smfiles  = smoothed volumes

%% get motion regressor rp file names 
% remember to change batch to specify rp if change back to rp from spike
% reg e
% for i = 1:length(b.runs)
%     b.rundir(i).rp     = spm_select('FPListRec', b.dataDir, ['^rp.*' b.runs{i} '.*bold\.txt']);
%     fprintf('%02d:   %s\n', i, b.rundir(i).rp)
% end

%% get spike regressor file names
for i = 1:length(b.runs)
    b.rundir(i).spike     = spm_select('FPListRec', b.dataDir, ['^spike.*' b.runs{i} '.*\.txt']);
    fprintf('%02d:   %s\n', i, b.rundir(i).spike)
end

%% get smoothed nii names
for i = 1:length(b.runs)
    % print success
    b.rundir(i).smfiles = spm_select('ExtFPListRec', b.dataDir, ['^smooth.*'  b.runs{i} '.*bold\.nii']);
    fprintf('%02d:   %0.0f smoothed files found.\n', i, length(b.rundir(i).smfiles))
end % end i b.runs


%% get condition files from saved .mat
cond_dir = '/Users/wbr/walter/fmri/sms_scan_analyses/seq_block_rsa/';

for i = 1:length(b.runs)
    b.rundir(i).cond = cellstr(spm_select('FPList', cond_dir, [ '^cond.*' b.curSubj sprintf('.*%s.*.mat', b.runs{i})]));
end % end i b.runs

%% Da business
clear matlabbatch

% creating an SPM.mat for every sequence, so need to loop through both runs
% and sequences, create dir to not overwrite, and grab the correct
% condition file for each

for irun = 1:length(b.runs)
    for iseq = 1:5
        
        % condition file for current sequence and run
        cond_file = b.rundir(irun).cond(iseq);
        
        load(char(cond_file), 'names')
        trialdir = fullfile(b.dataDir, b.runs(irun), names{1});
        mkdir(char(trialdir));
        clear names 
        
        %%
        %initiate
        matlabbatch{iseq}.spm.stats.fmri_spec.dir = cellstr(trialdir);
        matlabbatch{iseq}.spm.stats.fmri_spec.timing.units = 'scans';
        matlabbatch{iseq}.spm.stats.fmri_spec.timing.RT = 1.22;
        matlabbatch{iseq}.spm.stats.fmri_spec.timing.fmri_t = 38;
        matlabbatch{iseq}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
        
        matlabbatch{iseq}.spm.stats.fmri_spec.sess(1).scans = cellstr(b.rundir(irun).smfiles);
    
        %%
        matlabbatch{iseq}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        matlabbatch{iseq}.spm.stats.fmri_spec.sess(1).multi = cond_file;
        matlabbatch{iseq}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
        matlabbatch{iseq}.spm.stats.fmri_spec.sess(1).multi_reg = cellstr(b.rundir(irun).spike);
        matlabbatch{iseq}.spm.stats.fmri_spec.sess(1).hpf = 128;
        
        matlabbatch{iseq}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{iseq}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{iseq}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{iseq}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{iseq}.spm.stats.fmri_spec.mthresh = 0.8;
        matlabbatch{iseq}.spm.stats.fmri_spec.mask = {''};
        matlabbatch{iseq}.spm.stats.fmri_spec.cvi = 'AR(1)';


    end % end iseq
    
    % run
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end % end irun
end % end function
