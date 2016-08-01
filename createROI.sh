#!/bin/bash
for line in $(cat /export/higgs/john.chan/LA_brains/brain_list.txt)
do
X=${line}
printf "\nstarting ${X}"
echo
pre="${X}_pre"

#changes format of brains
mri_convert /export/higgs/john.chan/LA_brains/${pre}/wmparc.mgz /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz
echo
mri_convert /export/higgs/john.chan/LA_brains/${pre}/brain.mgz /export/higgs/john.chan/LA_brains/${pre}/brain.nii.gz

#creates ROI by thresholding
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 9.5 -uthr 13.5 /export/higgs/john.chan/LA_brains/${pre}/Set1.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 16.5 -uthr 18.5 /export/higgs/john.chan/LA_brains/${pre}/Set2.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 25.5 -uthr 26.5 /export/higgs/john.chan/LA_brains/${pre}/Set3.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 48.5 -uthr 54.5 /export/higgs/john.chan/LA_brains/${pre}/Set4.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 57.5 -uthr 58.5 /export/higgs/john.chan/LA_brains/${pre}/Set5.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 1000.5 -uthr 1003.5 /export/higgs/john.chan/LA_brains/${pre}/Set6.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 1004.5 -uthr 1035.5 /export/higgs/john.chan/LA_brains/${pre}/Set7.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 2000.5 -uthr 2003.5 /export/higgs/john.chan/LA_brains/${pre}/Set8.nii.gz
fslmaths /export/higgs/john.chan/LA_brains/${pre}/wmparc.nii.gz -thr 2004.5 -uthr 2035.5 /export/higgs/john.chan/LA_brains/${pre}/Set9.nii.gz

fslmaths /export/higgs/john.chan/LA_brains/${pre}/Set2.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set1.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set3.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set4.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set5.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set6.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set7.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set8.nii.gz -add /export/higgs/john.chan/LA_brains/${pre}/Set9.nii.gz /export/higgs/john.chan/LA_brains/${pre}/82ROI.nii.gz

rm /export/higgs/john.chan/LA_brains/${pre}/Set1.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set2.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set3.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set4.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set5.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set6.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set7.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set8.nii.gz
rm /export/higgs/john.chan/LA_brains/${pre}/Set9.nii.gz

#transforms ROIs from native space to diffusion space
/usr/local/fsl/bin/flirt -in /export/higgs/john.chan/LA_brains/${pre}/brain.nii.gz -ref /export/higgs/PriceLabCollaboration/PriceLabReprocess/TKA_sub/Interpolated/${pre}/IMAGERY/${pre}_FA.nii.gz -out /export/higgs/john.chan/LA_brains/${pre}/NAT2DIF_check -omat /export/higgs/john.chan/LA_brains/${pre}/NAT2DIF.mat -bins 256 -cost corratio -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12  -interp trilinear
/usr/local/fsl/bin/flirt -in /export/higgs/john.chan/LA_brains/${pre}/82ROI.nii.gz -applyxfm -init /export/higgs/john.chan/LA_brains/${pre}/NAT2DIF.mat -out /export/higgs/john.chan/LA_brains/${pre}/82ROI_diff.nii.gz -paddingsize 0.0 -interp nearestneighbour -ref /export/higgs/PriceLabCollaboration/PriceLabReprocess/TKA_sub/Interpolated/${pre}/IMAGERY/${pre}_FA.nii.gz

done
