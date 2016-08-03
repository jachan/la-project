#!/bin/bash
#should output the volume of leukoaraiosis in the tractography of the brain between our ROIs
for line in $(cat /export/higgs/john.chan/LA_brains/brain_list.txt)
do
X=${line}
pre="${X}_pre"
echo "${pre}"

#does skull extraction
/usr/local/fsl/bin/bet /export/higgs/john.chan/ref_brains/${pre} /export/higgs/john.chan/ref_brains/${pre}_brain -R -f 0.25 -g 0 -m

#flirt + xfm_apply
/usr/local/fsl/bin/flirt -in /export/higgs/john.chan/ref_brains/${pre}_brain.nii.gz -ref /export/higgs/PriceLabCollaboration/PriceLabReprocess/TKA_sub/Interpolated/${pre}/IMAGERY/${pre}_FA.nii.gz -out /export/higgs/john.chan/ref_brains/${pre}_brain_diff.nii.gz -omat /export/higgs/john.chan/ref_brains/${pre}_brain_diff.mat -bins 256 -cost normmi -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear
/usr/local/fsl/bin/flirt -in /export/higgs/john.chan/LA_brains/${pre}/LA_mask.nii -applyxfm -init /export/higgs/john.chan/ref_brains/${pre}_brain_diff.mat -out /export/higgs/john.chan/LA_brains/${pre}/LA_mask_diff.nii -paddingsize 0.0 -interp nearestneighbour -ref /export/higgs/john.chan/LA_brains/${pre}/brain.nii.gz

cd /export/higgs/john.chan/LA_brains/${pre}/
#create density mask
track_density_mask ${pre}_network.csv.trk /export/higgs/PriceLabCollaboration/PriceLabReprocess/TKA_sub/Interpolated/${pre}/IMAGERY/${pre}_FA.nii.gz ${pre}_networkDenMask.nii

#binarize LA_mask and density mask
fslmaths ${pre}_networkDenMask.nii -bin ${pre}_networkDenMask_bin.nii
rm ${pre}_networkDenMask.nii

#multiply masks together to get intersection
fslmaths ${pre}_networkDenMask_bin.nii -mul LA_mask_diff.nii ${pre}_LA_intersect.nii
rm ${pre}_networkDenMask_bin.nii.gz

#calculate volume of intersection
fslstats ${pre}_LA_intersect.nii -V
echo
done
