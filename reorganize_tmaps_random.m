% reorganize betas
% Author: Walter Reilly
% Created: 3_22_18

% Takes output from LSS and reorganizes and renames betas to be compatible
% with RSA toolbox in the sms_scan paradigm

clear all
clc

dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/cluster_preproc_native_8_6_18_tmaps';
scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/lss_singletrial'; 

subjects    = {'s001' 's002' 's003' 's004' 's007' 's008' 's009' 's010' 's011' 's015' 's016' 's018' 's019'  's020'...
               's022' 's023' 's024' 's025' 's027' 's028' 's029' 's030' 's032' 's033' 's034' 's035' 's036' 's037' ...
               's038' 's039' 's040' 's041' 's042' 's043'}; 
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  
%
auto_accept = 0;

%-- Clean up

clc
fprintf('Initializing and checking paths.\n')


%-- Check for required functions

% SPM
if exist('spm','file') == 0
    error('SPM must be on the path.')
end

fprintf('You beta reorganize!!\n\n')

%--Loop over subjects
for i = 1:length(subjects)
    
    % Define variables for individual subjects - General
    b.curSubj   = subjects{i};
    b.runs      = runs;
    b.dataDir   = fullfile(dataDir, b.curSubj);
    b.condDir   = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/random_con_files/';
        
    % Define variables for individual subjects - QA General
    b.scriptdir   = scriptdir;
    b.auto_accept = auto_accept;
    b.messages    = sprintf('Messages for subject %s:\n', subjects{i});
    
    % Check whether first level has already been run for a subject
    
    % Initialize diary for saving output
    diaryname = fullfile(b.dataDir, 'reorganize_random_tmaps_diary.txt');
    diary(diaryname);
    
    %%
    
    % make a new directory in which to place curSubj's organized betas
    b.betaDir = fullfile(b.dataDir, 'SVDP_tmaps_4_rsa');
    mkdir(char(b.betaDir));
    
    % loop through runs
    for irun = 1:length(b.runs)
        
        % run directory
        runDir = fullfile(b.dataDir, b.runs(irun), '/');
        
        % load the run appropriate random cond file
        load(sprintf('%srandfile_%s_Rifa_%d.mat',b.condDir,b.curSubj,irun))
        % load intact versions of all sequences
        load(sprintf('%sseq_intact.mat',b.condDir))
        
        %%the tricky part
        % for every rep, sort like idxs  like the intact
        reorder_idx = [];
        for irep = 1:3
            cur_seq_idx = randrunseq{irep,3} - 1; % minus one becuase the seqintact indxs are off by 1
            [a,bidx] = ismember(randrunseq{irep,1}(1:5), seqintact(cur_seq_idx,:));
            % lil check
            if sum(a) < 5
                error('random words shown dont match cur_seq!!')
            end
            %
            base_idx = 1:5;
            reorder_idx = [reorder_idx; base_idx(bidx)];
        end % end irep
        
       
        % get folder names and paths to betas
        [b.rundir(irun).seqs(1).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'spmT_0001.nii');
        [b.rundir(irun).seqs(2).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'spmT_0002.nii');
        [b.rundir(irun).seqs(3).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'spmT_0003.nii');
        
        %% added to get create mean image of each repetition (same item and sequence)
        for ipos = 1:5 % instead of 1:25, because only interested in random
            % this sets the index needed for the char array of all the beta
            % names from spm_select
            rep1_idx = reorder_idx(1,ipos) + 10;
            rep2_idx = reorder_idx(2,ipos) + 10;
            rep3_idx = reorder_idx(3,ipos) + 10;
            
            % grab the 3 betas that are the same verb from each of the 3
            % repetitions
            tmp_image = {b.rundir(irun).seqs(1).reps(rep1_idx,:); b.rundir(irun).seqs(2).reps(rep2_idx,:); b.rundir(irun).seqs(3).reps(rep3_idx,:)};
            tmp_image = strrep(tmp_image, ' ', '');
            % folder to write mean image into
            dest = fullfile(b.rundir(irun).name(ipos + 10,:), 'mean_random_tmap.nii'); % labelled according to poisition not verb. Remember this is position one isn't the actual presentation position, rather after reordering random order into intact order
            dest = strrep(dest, ' ', '');
            spm_imcalc(tmp_image, dest, '(i1 + i2 + i3)/3');
        end
       
        
        % get folder names and paths to betas
        % interestingly this pulls out a folder names for the other
        % sequences
        % causing need for tweak in next section where files are copied
        [b.rundir(irun).means, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'mean_random_tmap.nii');
        
            
        %%
        for icopy = 1:size(b.rundir(irun).means,1)
            % get file name for source
            [path,name,ext] = fileparts(b.rundir(irun).means(icopy,:));
            % get folder(sequence) name info for the source
            % add plus 10 because there are file names I don't want
            [path2,name2,ext2] = fileparts(b.rundir(irun).name(icopy + 10,:));
            % renove weird spaces at end of name2
            name2 = strrep(name2, ' ', '');
            % move the file and add the folder name into the file name
            copyfile(fullfile(path, [name, '.nii']), fullfile(b.betaDir, [name2,'_run',num2str(irun),'.nii']));
        end % end icopy
    end % end irun
    
    b.unifynames = spm_select('ExtFPListRec', b.betaDir, '.*.nii');
    
    icur = 1;
    
%     while icur < 90
%         for iseq = 1:6
%             for ipos = 1:5
%                 for irun = 1:3
%                     [path,oldname,ext] = fileparts(b.unifynames(icur,:));
%                     newname = sprintf('intact_seq%d_pos%d_run%d.nii', iseq,ipos,irun);
%                     movefile(fullfile(path, [oldname, '.nii']), fullfile(path, newname));
%                     icur = icur + 1;
%                 end % end irun
%             end % end ipos
%         end % end iseq     
%     end % end while iintact
    
    while icur < 45 %> 90 && icur < 136
        for iseq = 1:3
            for ipos = 1:5
                for irun = 1:3
                    [path,oldname,ext] = fileparts(b.unifynames(icur,:));
                    newname = sprintf('random_seq%d_pos%d_run%d.nii', iseq,ipos,irun);
                    movefile(fullfile(path, [oldname, '.nii']), fullfile(path, newname));
                    icur = icur + 1;
                end % end irun
            end % end ipos
        end % end iseq     
    end % end while iintact
    
    b.check = spm_select('ExtFPListRec', b.betaDir, '.*.nii');
    
    if size(b.check,1) ~= 45
        error('Dont have 45 random tmaps!!')
    end
    
    
%     while icur > 135 && icur < 226
%         for iseq = 1:6
%             for ipos = 1:5
%                 for irun = 1:3
%                     [path,oldname,ext] = fileparts(b.unifynames(icur,:));
%                     newname = sprintf('scrambled_seq%d_pos%d_run%d.nii', iseq,ipos,irun);
%                     movefile(fullfile(path, [oldname, '.nii']), fullfile(path, newname));
%                     icur = icur + 1;
%                 end % end irun
%             end % end ipos
%         end % end iseq     
%     end % end while iintact
    
end % i (subjects)

% might want to include something that programmatically verifies this..
fprintf('Betas copied and reorganized!!\n\n')




