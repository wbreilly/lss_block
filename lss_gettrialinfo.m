% lss_gettrialinfo
% Walter Reilly
% 
% created 9_27_17 for sms_scan to create condition files for lss single trial. For
% every subject, create a condition file for every item in every sequence in a run wherein
% there are separate regressors for each repetition (same verb), a fourth
% regressor for other verbs in the same sequence, a 5th regressor for other
% intact, 6th for other s-f, and 6th for s-r
clear all
clc


path = '/Users/WBR/drive/grad_school/DML_WBR/Sequences_Exp3/sms_scan_drive/sms_scan_fmri_copy/';
%where to save condition files
savepath = '/Users/WBR/walter/fmri/sms_scan_analyses/rsa_singletrial/';

for isub = [1 2 3 4 7 8 9 10]
    for irrb = 1:3
        for iblock = 1:3
            for iseq = 1:5
                load(sprintf('%ss%02d_rrb%d_%d.mat',path,isub,irrb,iblock));

                % get all sequence labels for the run
                nreps = 3;
                allrunseq = [];
                for irep = 1:nreps
                   allrunseq = [allrunseq;RETRIEVAL(irep).sequence(:,3:4)];
                end % end irep

                
                % 25 TR for boxcar function for entire sequence 
                nreg = 5;
                for idur = 1:nreg
                    durations{idur} = 5;
                end % end ireg


                % identify which order within the run of each condition 
                cur_seq_tmp = [];
                otherseq_tmp = [];

                % if it's the same sequence, note the order position to
                % later grab onset, otherwise it's going on reg2 (all other
                % trials)
                for irow = 1:length(allrunseq)
                    if allrunseq{irow,2} == allrunseq{iseq,2}
                        cur_seq_tmp = [cur_seq_tmp; irow];
                    else
                        otherseq_tmp = [otherseq_tmp; irow];
                    end % end if
                end % end irow

                %% loop through each position
                for iverb = 1:5
                    % cell array of condition names
                    names = {sprintf('%s_%d_rep1_pos%d',allrunseq{iseq,1}, allrunseq{iseq,2}, iverb),...
                            sprintf('%s_%d_rep2_pos%d',allrunseq{iseq,1}, allrunseq{iseq,2}, iverb),...
                            sprintf('%s_%d_rep3_pos%d',allrunseq{iseq,1}, allrunseq{iseq,2}, iverb),...
                            'same_seq', 'other_seq'};
                    
                    % convert the idx's of sequence order into onsets for each condition
                    % 7 dummy TR's at beginning so everything is +
                    onsets = {};
                    onsets_tmp = [];

                    % write onsets for each condition
                    % onsets_tmp will contain onsets for the current
                    % seqeunce
                    for icond = 1:length(cur_seq_tmp)
                        if cur_seq_tmp(icond) == 1
                            onsets_tmp(1,icond) = 8;
                        else
                            onsets_tmp(1,icond) = (cur_seq_tmp(icond)-1) *25 + 8;
                        end % end if  
                    end % end icond

                    % add onsets for each repetiton of iverb, adjusting for
                    % verb position in seq
                    if iverb == 1
                        onsets{1} = onsets_tmp(1);
                        onsets{2} = onsets_tmp(2);
                        onsets{3} = onsets_tmp(3);
                    else
                        onsets{1} = onsets_tmp(1) + (iverb-1)*5;
                        onsets{2} = onsets_tmp(2) + (iverb-1)*5;
                        onsets{3} = onsets_tmp(3) + (iverb-1)*5;
                    end
                    
                    % now get the onsets for the other verbs in the same
                    % sequence
                    % start with onsets for every position
                    addn = 5;
                    onsets{4} = [];
                    for ions = 1:3
                        onsets{4} = [onsets{4} onsets_tmp(ions) onsets_tmp(ions)+addn onsets_tmp(ions)+addn*2 onsets_tmp(ions)+addn*3 onsets_tmp(ions)+addn*4];
                    end % end ions 
                    
                    % now delete onsets associated with iverb
                    % create idx for onsets to keep
                    onsets{4}(iverb) = [];
                    onsets{4}(iverb+4) = [];
                    onsets{4}(iverb+8) = [];
                    
                    
                    %clear onsets_tmp
                    onsets_tmp = [];

                    % now get all non cur_seq sequence onsets
                    for icond = 1:length(otherseq_tmp)
                        if otherseq_tmp(icond) == 1
                            onsets_tmp(1,icond) = 8;
                        else
                            onsets_tmp(1,icond) = (otherseq_tmp(icond)-1) *25 + 8;
                        end % end if  
                    end % end icond

                    % turn sequence onsets into each verb onset
                    onsets{5} = [];
                    for ions = 1:size(onsets_tmp,2)
                        onsets{5} = [onsets{5} onsets_tmp(ions) onsets_tmp(ions)+addn onsets_tmp(ions)+addn*2 onsets_tmp(ions)+addn*3 onsets_tmp(ions)+addn*4];
                    end % end ions 
                    
                    %clear for good measure
                    onsets_tmp = [];

                    %where to save condition files
                    savepath = '/Users/WBR/walter/fmri/sms_scan_analyses/rsa_singletrial/';

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
                    save(sprintf('%scondfile_s%03d_Rifa_%d_%s_%d_pos%d.mat',savepath,isub,run,allrunseq{iseq,1}, allrunseq{iseq,2}, iverb),'names', 'durations', 'onsets');

                    clearvars -EXCEPT isub irrb iblock iseq path savepath iverb allrunseq cur_seq_tmp otherseq_tmp durations
                end % end iverb
            end % end iseq
            clear allrunseq
        end % end iblock
    end % end irrb
end % end isub


