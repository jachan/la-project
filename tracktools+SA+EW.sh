#!/bin/bash
#should output edge weights of brains that we use for tractography
echo | tee -a ~/status.txt
echo "running tracktools+SA+EW.sh" | tee -a ~/status.txt
for line in $(cat /export/higgs/john.chan/LA_brains/brain_list.txt)
do
X=${line}
echo "starting ${X}" | tee -a ~/status.txt
echo
cd /export/higgs/PriceLabCollaboration/PriceLabReprocess/TKA_sub/Interpolated
#does tractography between ROIs
pre="${X}_pre"
track_tracker -o /export/higgs/john.chan/LA_brains/${pre}/track_${pre}.trk -d ${pre}/MOW/ -sdm ${pre}/DIFF_DATA/${pre}_dwi_merged_ec_brain_mask.nii.gz -sd 5 -fam ${pre}/IMAGERY/${pre}_FA.nii.gz -so
echo "finished track_tracker" | tee -a ~/status.txt
echo
track_network -m pass -save-matching -conn_method C /export/higgs/john.chan/LA_brains/${pre}/track_${pre}.trk /export/higgs/john.chan/LA_brains/${pre}/82ROI_diff.nii.gz /export/higgs/john.chan/LA_brains/${pre}/${pre}_network.csv -r
rm /export/higgs/john.chan/LA_brains/${pre}/track_${pre}.trk
rm /export/higgs/john.chan/LA_brains/${pre}/track_${pre}.trk.seeds
echo "finished track_network" | tee -a ~/status.txt
echo
#finds surface area
cd ~/scripts/surfaceArea/
idl -e "node_surface_area" -args /export/higgs/john.chan/LA_brains/${pre}/82ROI.nii.gz /export/higgs/john.chan/LA_brains/${pre}/surface_area.csv
echo "finished surface area" | tee -a ~/status.txt
echo
#does edge weight calculations
/export/faraday/john.chan/scripts/edge-weighting/edge_weight.sh /export/higgs/john.chan/LA_brains/${pre}/${pre}_network.csv /export/higgs/john.chan/LA_brains/${pre}/surface_area.csv /export/higgs/john.chan/LA_brains/${pre}/${pre}_edgeWeights.csv 1 125
echo "finished edge weights" | tee -a ~/status.txt
echo | tee -a ~/status.txt
done
echo "finished run" | tee -a ~/status.txt
echo | tee -a ~/status.txt
