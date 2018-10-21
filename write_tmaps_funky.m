function [b] = write_tmaps_funky(b)
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
        % this is ambiguous to parfor 
        clear SPM
%                 

        try
            %run
            spm('defaults','fmri');
            spm_jobman('initcfg');
            spm_jobman('run',matlabbatch);
        catch
            warning('something goofed for %s on %s', b.curSubj, b.runs{irun})
        end
        
        clear matlabbatch

    end % end iseq
end % end i run
end