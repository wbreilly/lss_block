% create t maps on cluster
% cretaed by Walter Reilly on 10_21_18 for sms_scan

clear all 
clc

dataDir     = '/home/wbreilly/sms_scan_crick/cluster_preproc_native_8_6_18';
scriptdir   = '/home/wbreilly/sms_scan_crick/cluster_preproc_native_8_6_18/lss_block'; 

subjects    = {'s001' 's002' 's003' 's004' 's007' 's008' 's009' 's010' 's011' 's015' 's016' 's018' 's019'  's020'...
               's022' 's023' 's024' 's025' 's027' 's028' 's029' 's030' 's032' 's033' 's034' 's035' 's036' 's037' ...
               's038' 's039' 's040' 's041' 's042' 's043'};
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  

% spm path
addpath /group/dml/apps/spm12



% pool party
pc = parcluster('big_mem'); %
poolobj = parpool(pc, 34);

    %--Loop over subjects
parfor isub = 1:length(subjects)
    try
        b.scriptdir = scriptdir;
        b.runs      = runs;
        b.curSubj   = subjects{isub};
        b.dataDir   = fullfile(dataDir, b.curSubj);
        
        [b] = write_tmaps_funky(b);      
    catch
        warning('\n\n\n something goofed for isub %d \n\n\n', isub)
    end
end % end isub

delete(gcp('nocreate'))
exit
% run

% initialize
        % add to b
        
% 
% function b = write_tmaps_this_way(b)
% % loop over runs
% for irun = 1:length(b.runs)
%     % get all the full paths to .mat's for the subject and the run
%     trialnames = ls(sprintf('%s/%s/*/SPM.mat',b.dataDir,b.runs{irun}));
%     trialnames = strsplit(trialnames);
% 
% 
%     % loop over sequences
%     for iseq = 1:25
%         % condition file for current sequence and run
% %             cond_file = b.rundir(irun).cond(iseq);
% %             load(char(cond_file), 'names')
% %             trialdir = fullfile(b.dataDir, b.runs(irun), names{1}, 'SPM.mat');
% 
%         % load the spm.mat to get number of regressors for contrast vector
%         load(trialnames{iseq});
% 
%         % 1 reg for each rep of a position in a sequence, one for every other positions and reps in that same sequence, and a final for all other sequences/reps 
%         for irep = 1:3
% 
%             % contrast vector is 1 for rep of interest and 0 for all else
%             con_vec = zeros(1,size(SPM.xX.X,2));
%             con_vec(irep) = 1;
% 
%             % got this from the contrast gui saved as .m
%             matlabbatch{iseq}.spm.stats.con.spmmat = cellstr(trialnames(iseq));
%             matlabbatch{iseq}.spm.stats.con.consess{irep}.tcon.name = 'sameseq_samepos';
%             matlabbatch{iseq}.spm.stats.con.consess{irep}.tcon.weights = con_vec;
%             matlabbatch{iseq}.spm.stats.con.consess{irep}.tcon.sessrep = 'none';
%             matlabbatch{iseq}.spm.stats.con.delete = 1;  
% 
%         end % irep
% 
%         %clear SPM.mat, was only using to get number of regressors
%         % this is ambiguous to parfor 
%         clear SPM
% %                 
% 
%         try
%             %run
%             spm('defaults','fmri');
%             spm_jobman('initcfg');
%             spm_jobman('run',matlabbatch);
%         catch
%             warning('something goofed for %s on %s', b.curSubj, b.runs{irun})
%         end
%         
%         clear matlabbatch
% 
%     end % end iseq
% end % end i run



