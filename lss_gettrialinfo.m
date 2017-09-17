% lss_gettrialinfo
% Walter Reilly
% created 9_16_17 for sms_scan to create condition files for lss block. For
% every subject, create a condition file for every sequence in a run where
% the sequence of interest is one condition with 15 onsets and the second
% condition has onsets for every other sequence in the run.

path = '/Users/WBR/drive/grad_school/DML_WBR/Sequences_Exp3/sms_scan_drive/sms_scan_fmri_copy/';

for isub = [1 2 3 4 7]
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
                
                % cell array of condition names
                names = {sprintf('%s_%d',allrunseq{iseq,1}, allrunseq{iseq,2}) , 'reg2'};
                % 25 TR for boxcar function for entire sequence 
                durations{1} = 25;
                durations{2} = 25;

                % identify which order within the run of each condition 
                cur_seq_tmp = [];
                reg2_tmp = [];
               
                % if it's the same sequence, note the order position to
                % later grab onset, otherwise it's going on reg2 (all other
                % trials)
                for irow = 1:length(allrunseq)
                    if allrunseq{irow,2} == allrunseq{iseq,2}
                        cur_seq_tmp = [cur_seq_tmp; irow];
                    else
                        reg2_tmp = [reg2_tmp; irow];
                    end % end if
                end % end irow

                % convert the idx's of sequence order into onsets for each condition
                % 7 dummy TR's at beginning so everything is +
                onsets = {};
                onsets_tmp = [];

                % write onsets for each condition
                for icond = 1:length(cur_seq_tmp)
                    if cur_seq_tmp(icond) == 1
                        onsets_tmp(1,icond) = 8;
                    else
                        onsets_tmp(1,icond) = (cur_seq_tmp(icond)-1) *25 + 8;
                    end % end if  
                end % end icond

                onsets{1} = onsets_tmp;
                onsets_tmp = [];

                for icond = 1:length(reg2_tmp)
                    if reg2_tmp(icond) == 1
                        onsets_tmp(1,icond) = 8;
                    else
                        onsets_tmp(1,icond) = (reg2_tmp(icond)-1) *25 + 8;
                    end % end if  
                end % end icond

                onsets{2} = onsets_tmp;
                onsets_tmp = [];



                %where to save condition files
                savepath = '/Users/WBR/walter/fmri/sms_scan_analyses/seq_block_rsa/';

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
                save(sprintf('%scondfile_s%03d_Rifa_%d_%s_%d.mat',savepath,isub,run,allrunseq{iseq,1}, allrunseq{iseq,2}),'names', 'durations', 'onsets');

                clearvars -EXCEPT isub irrb iblock iseq path
            end % end iseq
        end % end iblock
    end % end irrb
end % end isub


