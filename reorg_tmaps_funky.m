function [b] = reorg_tmaps_funky(b)
    
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
        if strcmp(b.curSubj,'s016') && strcmp(b.runs{irun},'Rifa_5') && strcmp(dest,'/home/wbreilly/sms_scan_crick/cluster_preproc_native_8_6_18/s016/Rifa_5/intact_7_rep1_pos5/mean_tmap.nii')
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
    warning('Dont have 225 tmaps!!')
end
end