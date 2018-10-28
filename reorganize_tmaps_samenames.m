% reorganize tmaps in the same way that betas were reorganized
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
for i = 11:length(subjects)
    
    % Define variables for individual subjects - General
    b.curSubj   = subjects{i};
    b.runs      = runs;
    b.dataDir   = fullfile(dataDir, b.curSubj);
        
    % Define variables for individual subjects - QA General
    b.scriptdir   = scriptdir;
    b.auto_accept = auto_accept;
    b.messages    = sprintf('Messages for subject %s:\n', subjects{i});
    
    % Check whether first level has already been run for a subject
    
    % Initialize diary for saving output
%     diaryname = fullfile(b.dataDir, 'reorganized_tmaps_diary.txt');
%     diary(diaryname);
    
    %%
    % do the stuff
    
    % make a new directory in which to place curSubj's organized betas
    b.betaDir = fullfile(b.dataDir, 'tmap_4_rsa_singletrial');
    mkdir(char(b.betaDir));
    
    % loop through runs
    for irun = 1:length(b.runs)
        
        % run directory
        runDir = fullfile(b.dataDir, b.runs(irun), '/');
       
        % get folder names and paths to betas
        [b.rundir(irun).seqs(1).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'spmT_0001.nii');
        [b.rundir(irun).seqs(2).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'spmT_0002.nii');
        [b.rundir(irun).seqs(3).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'spmT_0003.nii');
       
        
        %% added to get create mean image of each repetition (same item and sequence)
        for ibeta = 1:25
            % images to mean
            tmp_image = {b.rundir(irun).seqs(1).reps(ibeta,:); b.rundir(irun).seqs(2).reps(ibeta,:); b.rundir(irun).seqs(3).reps(ibeta,:) };
            tmp_image = strrep(tmp_image, ' ', '');
            % folder to write mean image into
            dest = fullfile(b.rundir(irun).name(ibeta,:), 'mean_tmap.nii');
            dest = strrep(dest, ' ', '');
            
            % exception for one stinkin missing tmap due to invalid contrast
            % spmT_0002.nii was copied and renamed spmT_3.nii to allow code
            % to run unaffected for remainder of trials, but not that only
            % first two are used and the copied tmap is not used.
            % I addedd a red tag to the duplicate file in finder
            if strcmp(subjects{i},'s016') && strcmp(b.runs{irun},'Rifa_5') && strcmp(dest,'/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/cluster_preproc_native_8_6_18_tmaps/s016/Rifa_5/intact_7_rep1_pos5/mean_tmap.nii')
                spm_imcalc(tmp_image, dest, '(i1 + i2)/2');
            else
                spm_imcalc(tmp_image, dest, '(i1 + i2 + i3)/3');
            end
        end
        
        % get folder names and paths to betas
        [b.rundir(irun).means, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, 'mean_tmap.nii');
        
            
        %%
        for icopy = 1:size(b.rundir(irun).means,1)
            % get file name for source
            [path,name,ext] = fileparts(b.rundir(irun).means(icopy,:));
            % get folder(sequence) name info for the source
            [path2,name2,ext2] = fileparts(b.rundir(irun).name(icopy,:));
            % renove weird spaces at end of name2
            name2 = strrep(name2, ' ', '');
            % move the file and add the folder name into the file name
            copyfile(fullfile(path, [name, '.nii']), fullfile(b.betaDir, [name2,'_run',num2str(irun),'.nii']));
        end % end icopy
    end % end irun
    
    b.unifynames = spm_select('ExtFPListRec', b.betaDir, '.*.nii');
    
    icur = 1;
    
    while icur < 90
        for iseq = 1:6
            for ipos = 1:5
                for irun = 1:3
                    [path,oldname,ext] = fileparts(b.unifynames(icur,:));
                    newname = sprintf('intact_seq%d_pos%d_run%d.nii', iseq,ipos,irun);
                    movefile(fullfile(path, [oldname, '.nii']), fullfile(path, newname));
                    icur = icur + 1;
                end % end irun
            end % end ipos
        end % end iseq     
    end % end while iintact
    
    while icur > 90 && icur < 136
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
    
    while icur > 135 && icur < 226
        for iseq = 1:6
            for ipos = 1:5
                for irun = 1:3
                    [path,oldname,ext] = fileparts(b.unifynames(icur,:));
                    newname = sprintf('scrambled_seq%d_pos%d_run%d.nii', iseq,ipos,irun);
                    movefile(fullfile(path, [oldname, '.nii']), fullfile(path, newname));
                    icur = icur + 1;
                end % end irun
            end % end ipos
        end % end iseq     
    end % end while iintact
    
    b.check = spm_select('ExtFPListRec', b.betaDir, '.*.nii');
    
    if size(b.check,1) ~= 225
        error('Dont have 225 tmaps!!')
    end
    
end % i (subjects)

% might want to include something that programmatically verifies this..
fprintf('Tmaps copied and reorganized!!\n\n')




