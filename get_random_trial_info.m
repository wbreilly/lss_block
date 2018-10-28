% get_random_trial_info
% Walter Reilly
% 
% created 2_18_18 for sms_scan. Adapted from lss_getrialinfo.m to use for
% random verb reordering for same verb, different position analysis
% Need to get the specific verb order for every random repetition
% After running this script i will make the directory structure, labeling,
% and mean across 3 reps within a run in reorganize_betas_random.m

clear all
clc


path = '/Volumes/GoogleDrive/My Drive/grad_school/DML_WBR/Sequences_Exp3/sms_scan_drive/sms_scan_fmri_copy/';
%where to save condition files
savepath = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/random_con_files/';

for isub = [1 2 3 4 7 8 9 10 11 15 16 18 19 20 22 23 24 25 27 28 29 30 32 33 34 35 36 37 38 39 40 41 42 43];
    for irrb = 1:3
        for iblock = 1:3
                load(sprintf('%ss%02d_rrb%d_%d.mat',path,isub,irrb,iblock));

                % get all sequence labels for the run
                nreps = 3;
                allrunseq = [];
                for irep = 1:nreps
                   allrunseq = [allrunseq;RETRIEVAL(irep).sequence(:,2:4)];
                end % end irep

                %% I'm only interested in the random sequences
                randrunseq = [];
                for iall = 1:size(allrunseq,1)
                    if strncmp('random', allrunseq(iall,2),6)
                        randrunseq = [randrunseq; allrunseq(iall,:)];
                    end
                end % end iall
                %%
                
                
                    % save with run naming convention (1-9)
                    % dumb way

                    if irrb == 1
                        if iblock == 1;
                            run = 1;
                        elseif iblock == 2
                            run = 2;
                        else 
                            run = 3;
                        end
                    elseif irrb == 2
                        if iblock == 1;
                            run = 4;
                        elseif iblock == 2
                            run = 5;
                        else 
                            run = 6;
                        end
                    else
                        if iblock == 1;
                            run = 7;
                        elseif iblock == 2
                            run = 8;
                        else 
                            run = 9;
                        end
                    end

                    % save
                    
                    % keyboard because change the file name to something
                    % that doesn't start with condfile
                    save(sprintf('%srandfile_s%03d_Rifa_%d.mat',savepath,isub,run),'randrunseq');

                    clearvars -EXCEPT isub irrb iblock path savepath 
            clear allrunseq
        end % end iblock
    end % end irrb
end % end isub


