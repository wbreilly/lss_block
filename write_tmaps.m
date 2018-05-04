% create t maps 

% clear all 
clc

dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_native_4_26_18';
scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/lss_singletrial';

subjects    = {'s001' 's002' 's003' 's004' 's007' 's008' 's009' 's010' 's011' 's015' 's016' 's018' 's019' 's020' 's022' 's023' 's024' 's025'}; 
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  

b.scriptdir = scriptdir;
b.runs      = runs;



    %--Loop over subjects
for isub = 10:length(subjects)
    % initialize
    b.curSubj   = subjects{isub};
    b.dataDir   = fullfile(dataDir, b.curSubj);
        
    % loop over runs
    for irun = 1:length(b.runs)
        % get all the full paths to .mat's for the subject and the run
        trialnames = ls(sprintf('%s/%s/*/SPM.mat',b.dataDir,b.runs{irun}));
        trialnames = strsplit(trialnames);
        
        
        % loop over sequences
        for iseq = 1:25
            % condition file for current sequence and run
%             cond_file = b.rundir(irun).cond(iseq);
%             load(char(cond_file), 'names')
%             trialdir = fullfile(b.dataDir, b.runs(irun), names{1}, 'SPM.mat');
            
            % load the spm.mat to get number of regressors for contrast vector
            load(trialnames{iseq});
            
            % 1 reg for each rep of a position in a sequence, one for every other positions and reps in that same sequence, and a final for all other sequences/reps 
            for irep = 1:3
                
                % contrast vector is 1 for rep of interest and 0 for all else
                con_vec = zeros(1,size(SPM.xX.X,2));
                con_vec(irep) = 1;
            
                % got this from the contrast gui saved as .m
                matlabbatch{iseq}.spm.stats.con.spmmat = cellstr(trialnames(iseq));
                matlabbatch{iseq}.spm.stats.con.consess{irep}.tcon.name = 'sameseq_samepos';
                matlabbatch{iseq}.spm.stats.con.consess{irep}.tcon.weights = con_vec;
                matlabbatch{iseq}.spm.stats.con.consess{irep}.tcon.sessrep = 'none';
                matlabbatch{iseq}.spm.stats.con.delete = 1;  
                
            end % irep
            
            %clear SPM.mat, was only using to get number of regressors
            clear SPM
            
            try
                %run
                spm('defaults','fmri');
                spm_jobman('initcfg');
                spm_jobman('run',matlabbatch);
            catch
                warning('Whoops! Something goofed.')
            end
            
        end % end iseq
    end % end i run
end % end isub

% run


