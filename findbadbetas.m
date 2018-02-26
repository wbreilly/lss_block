function findbadbetas(sublist)
% Takes either a string or cell array of strings of subject IDs - e.g. 
% 'shopcon_101' or {'shopcon_101' 'shopcon_102'}.

% add some paths
% addpath(genpath('/data2/Scripts'),genpath('/data/mritchey/Scripts/spm8'))

% select project directory
pdir='/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_native_10_20_17_copy';

% select single trial directory
odir='betas_4_rsa_singletrial/';

% select threshold
thresh=1.1;

% select showhist
showhist=1;

% parse subject input
if ischar(sublist)
    sublist={sublist};
end

% loop through subjects
for s=1:length(sublist)
    
    % get subject name
    subject=sublist{s};
    sdir=[pdir '/' subject '/'];
    fprintf('Finding bad trials for %s...\n',subject);
    
    % load mask
    maskimg=load_nii([sdir 'reslice_allgray.nii']);
    mask=maskimg.img;
    
    % loop through conditions
    ldir=[sdir odir];
     % find bad trials
    betas = load_nii([ldir 'all_singletrial.nii']);
    
    bad=betascrub(betas.img,mask, 'threshold',thresh,'showhist',showhist);
        
        % write bad trial numbers to text file 
    dlmwrite([ldir '1.1_bad_fullsample.txt'],bad);
end %subject
end % end function