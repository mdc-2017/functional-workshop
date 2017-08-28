%Get all the files we want (and more)
%Scans=subdir(fullfile('/Volumes/psych-cog/dsnlab/SFIC_Self3/analysis/rx/LME_FX/','con_000*.nii'));
%% Define variables 
basedir='/Volumes/psych-cog/dsnlab/SFIC_Self3/subjects/';
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

fxdir='fx/fx_2017';

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
I.OutputDir = '/Volumes/psych-cog/dsnlab/SFIC_Self3/rx/MDC/MDC_glm_flex';
I.RemoveOutliers = 0;
I.DoOnlyAll = 1;
I.estSmooth = 1;
I.Mask = '/Volumes/psych-cog/dsnlab/SFIC_Self3/masks/groupAverage_opt.nii';
I.PostHocs = {'SelfOther$Self | Run$t1 # SelfOther$Self | Run$t2' 't1t2Self';
    'SelfOther$Self | Run$t2 # SelfOther$Self | Run$t3' 't2t3Self'};

GLM_Flex_Fast2(I);


%%
% Use corrections for covariance

anotherI=I;
anotherI.OutputDir='/Volumes/psych-cog/dsnlab/SFIC_Self3/rx/glm_flex_covcorrect';
anotherI.covCorrect=1;
anotherI.PostHocs=[];
GLM_Flex_Fast4(anotherI);

IforICC=I;
IforICC.Model = 'Run + random(SS|Run)';
IforICC.PostHocs=[];
IforICC.OutputDir='/Volumes/psych-cog/dsnlab/SFIC_Self3/rx/glm_flex_ICC';
GLM_Flex_Fast2(IforICC);
