%% Demo: fMRI searchlights SVM classifier
%
%To run MVPA with SVM classifier, crossvalidation method
%
% #   For CoSMoMVPA's copyright information and license terms,   #
% #   see the COPYING file distributed with CoSMoMVPA.           #


clear all;
% % 
% % %PILOT
% % 
% % sub(1).id      =    'CON_OliC';
% % sub(1).Nrun    =    '2';
% % sub(1).folder  =    '4D_files';

clear all;


sub(1).id      =    'sub-001';
sub(1).Nrun    =    '18';

sub(2).id      =    'sub-002' ;
sub(2).Nrun    =    '18';

sub(3).id      =    'sub-003' ;
sub(3).Nrun    =    '18';

sub(4).id      =    'sub-004' ;
sub(4).Nrun    =    '18';

sub(5).id      =    'sub-005' ;
sub(5).Nrun    =    '18';

sub(6).id      =    'sub-006' ;
sub(6).Nrun    =    '18';

sub(7).id      =    'sub-007' ;
sub(7).Nrun    =    '18';

sub(8).id      =    'sub-008';
sub(8).Nrun    =    '18'

sub(9).id      =    'sub-009' ;
sub(9).Nrun    =    '18';

sub(10).id      =    'sub-010' ;
sub(10).Nrun    =    '18';

sub(11).id      =    'sub-011' ;
sub(11).Nrun    =    '18';

sub(12).id      =    'sub-012' ;
sub(12).Nrun    =    '18';

sub(13).id      =    'sub-013' ;
sub(13).Nrun    =    '18';

sub(14).id      =    'sub-014' ;
sub(14).Nrun    =    '18';

sub(15).id      =    'sub-015' ;
sub(15).Nrun    =    '18';

sub(16).id      =    'sub-016' ;
sub(16).Nrun    =    '18';

sub(17).id      =    'sub-017' ;
sub(17).Nrun    =    '18';

sub(18).id      =    'sub-018' ;
sub(18).Nrun    =    '18';

sub(19).id      =    'sub-019' ;
sub(19).Nrun    =    '18';

sub(20).id      =    'sub-020' ;
sub(20).Nrun    =    '18';

sub(21).id      =    'sub-021' ;
sub(21).Nrun    =    '18';

sub(22).id      =    'sub-022' ;
sub(22).Nrun    =    '18';

sub(23).id      =    'sub-023' ;
sub(23).Nrun    =    '18';

sub(24).id      =    'sub-024' ;
sub(24).Nrun    =    '18';


no_sub= [2:12];


%% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define modality
Modality=1; % ==Visual;
%Modality=2; %==Auditory;
%Modality=3; %==Bimodal; %Audio-Visual



%% Define data
%config=cosmo_config();
study_path='/data/gent/473/vsc47358/CombiEmo';

masks_path = fullfile(cd,'masks');

%select the correct mask based on the experiment modality
if Modality==1
    mask_fn=fullfile(masks_path,'rMean_VisualMask.nii');% whole brain mask
elseif Modality==2
    mask_fn=fullfile(masks_path,'rMean_AuditoryMask.nii');% whole brain mask
elseif Modality==3
    mask_fn=fullfile(masks_path,'rMean_BimodalMask.nii');% whole brain mask
end
    

%% Set data paths
if Modality==1
    output_path='/data/gent/473/vsc47358/CombiEmo/results/Within_Visual';
elseif Modality==2
    output_path='/data/gent/473/vsc47358/CombiEmo/results/Within_Auditory';
elseif Modality==3
    output_path='/data/gent/473/vsc47358/CombiEmo/results/Within_Bimodal';
end

% reset citation list
%cosmo_check_external('-tic');

%% SVM classifier searchlight analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This analysis identified brain regions where the categories can be
% distinguished using an odd-even partitioning scheme and a Linear
% Discriminant Analysis (LDA) classifier.
for isub = no_sub
     
    sub_name=(sub(isub).id);
    
    if Modality==1
        data_fn=fullfile(study_path,'Decoding_4Dfiles','Visual',sub_name,'4D_beta_2.nii');
    elseif Modality==2
        data_fn=fullfile(study_path,'Decoding_4Dfiles','Auditory',sub_name,'4D_beta_2.nii');
    elseif Modality==3
        data_fn=fullfile(study_path,'Decoding_4Dfiles','Bimodal',sub_name,'4D_beta_2.nii');
    end
%      %targets for 5 categories/18 runs    
    targets=repmat(1:5,1,1)'; 
    targets=repmat(targets,str2num(sub(isub).Nrun),1);
    targets= sort(targets);
     
%%chuncks (correspond to the number of runs==18 per modality)
  chunks=repmat(1:str2num(sub(isub).Nrun),1,5)'; %chuncks is number of runs, 18== numeber of values per runs
 
ds_per_run = cosmo_fmri_dataset(data_fn, 'mask', mask_fn,...
                                'targets',targets,'chunks',chunks);

 % remove constant features (due to liberal masking)
ds_per_run=cosmo_remove_useless_data(ds_per_run);

% print dataset
fprintf('Dataset input:\n');
cosmo_disp(ds_per_run);


% Use the cosmo_cross_validation_measure and set its parameters
% (classifier and partitions) in a measure_args struct.
measure = @cosmo_crossvalidation_measure;
measure_args = struct();

% Define which classifier to use, using a function handle.
% Alternatives are @cosmo_classify_{svm,matlabsvm,libsvm,nn,naive_bayes}
%measure_args.classifier = @cosmo_classify_lda;
measure_args.classifier = @cosmo_classify_svm;
% Set partition scheme. odd_even is fast; for publication-quality analysis
% nfold_partitioner is recommended.
% Alternatives are:
% - cosmo_nfold_partitioner    (take-one-chunk-out crossvalidation)
% - cosmo_nchoosek_partitioner (take-K-chunks-out  "             ").
% measure_args.partitions = cosmo_oddeven_partitioner(ds_per_run);
measure_args.partitions = cosmo_nfold_partitioner(ds_per_run);
measure_args.normalization = 'zscore';
% print measure and arguments
fprintf('Searchlight measure:\n');
cosmo_disp(measure);
fprintf('Searchlight measure arguments:\n');
cosmo_disp(measure_args);

% Define a neighborhood with approximately 100 voxels in each searchlight.
nvoxels_per_searchlight=100;
nbrhood=cosmo_spherical_neighborhood(ds_per_run,...
                        'count',nvoxels_per_searchlight);


% Run the searchlight
svm_results = cosmo_searchlight(ds_per_run,nbrhood,measure,measure_args);

%% print output dataset
%fprintf('Dataset output:\n');
%cosmo_disp(svm_results);

%% Plot the output
%cosmo_plot_slices(svm_results);

% Define output location
%output_fn=fullfile(output_path,'lda_searchlight+orig');
output_fn=fullfile(output_path,strcat(sub_name,'_svm_searchlight_DecodingWithinModality_CombiEmo.nii'));
% Store results to disc
cosmo_map2fmri(svm_results, output_fn);

% % Show citation information
% cosmo_check_external('-cite');
end


