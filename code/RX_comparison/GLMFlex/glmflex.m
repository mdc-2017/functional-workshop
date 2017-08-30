% This script runs 2x2x3 within subject repeated measures ANOVA using GLMFlex
% However, we do not advise that you use this tool as the results are likely invalid
% https://groups.google.com/forum/#!searchin/fmri_matlab_tools/linear$20contrast/fmri_matlab_tools/iB5f4fhIw70/fb7XVtZi6QQJ

%% Define variables 
basedir='/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data';
subjectIDs={
's005'
's016'
's018'
's019'
's022'
's023'
's024'
's029'
's030'
's032'
's035'
's038'
's040'
's042'
's045'
's058'
's064'
's065'
's072'
's073'
's081'
's089'};

waves={
't1'
't2'
't3'};

fxdir='FX_models';

cons={
'con_0001.nii'
'con_0002.nii'
'con_0003.nii'
'con_0004.nii'};

selfOtherCondNames={'Self', 'Self', 'Other', 'Other'};
socAcadCondNames={'Academic','Social','Academic','Social'};

clear dat
dati=1;
%get an index of the cons we actually want
for subji = 1:numel(subjectIDs)
    for wavei = 1:numel(waves)
        for coni = 1:numel(cons)
             condNum = regexp(cons{coni}, 'con_000([0-9])','tokens');
                          
             dat.fn{dati,1} = fullfile(basedir,subjectIDs{subji},waves{wavei},fxdir,cons{coni});
             dat.SS{dati,1} = subjectIDs{subji};
             dat.Run{dati,1} = waves{wavei};
             dat.SelfOther{dati,1} = selfOtherCondNames{str2num(condNum{1}{1})};
             dat.SocialAcademic{dati,1} = socAcadCondNames{str2num(condNum{1}{1})};
             dati=dati+1;
        end
    end
end

clear I;
I.Scans = dat.fn;
I.Model = 'Run*SelfOther*SocialAcademic + random(SS|Run*SelfOther*SocialAcademic)';
I.Data = dat;
I.OutputDir = '/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/GLMFlex';
I.RemoveOutliers = 0;
I.DoOnlyAll = 1;
I.estSmooth = 1;
I.Mask = '/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/RX_mask/groupAverage_opt.nii';
I.PostHocs = {'SelfOther$Self | Run$t1 # SelfOther$Self | Run$t2' 't1t2Self';
              'SelfOther$Self | Run$t2 # SelfOther$Self | Run$t3' 't2t3Self';
              'SelfOther$Self | Run$t1 # SelfOther$Self | Run$t3' 't1t3Self'};

GLM_Flex_Fast2(I);