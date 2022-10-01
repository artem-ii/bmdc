#! /bin/zsh

cd /Volumes/artemii-4tb/data/chipseq/bmdc/data/


# You need to organize resulting sample-names.txt into two files containing AC and ME samples respectively

cd /Volumes/artemii-4tb/data/chipseq/bmdc/

# Merge replicate bam files to improve sensitivity of peak calling

mkdir data/bam-files/merged-bam

parallel -a config/merge-bam.txt --max-procs=8 --colsep '\t' 'samtools merge data/bam-files/merged-bam/{1}.bam data/bam-files/{2}*.bam data/bam-files/{3}*.bam data/bam-files/{4}*.bam'

ls data/bam-files/merged-bam/ | parallel  --max-procs=32 samtools index data/bam-files/merged-bam/{}


find data/bam-files/merged-bam -name 'h3k27ac*.bam' | sed s'/data\/bam-files\/merged-bam\///' | parallel  --max-procs=32 'macs2 callpeak -t data/bam-files/merged-bam/{} -f BAMPE -c data/bam-files/BMDC-INPUT_S35.sorted.mrkdup.bam -g mm -n {}-peaks -q 0.01 --outdir data/macs2-files/'
find data/bam-files/merged-bam -name 'h3k27me3*.bam' | sed s'/data\/bam-files\/merged-bam\///' | parallel  --max-procs=8 'macs2 callpeak -t data/bam-files/merged-bam/{} -f BAMPE --broad -c data/bam-files/BMDC-INPUT_S35.sorted.mrkdup.bam -g mm -n {}-peaks -q 0.01 --outdir data/macs2-files'



# ls bam-files > bam-files.txt
# grep .bam$ bam-files.txt | sed "s/.sorted.mrkdup.bam//" | sed "s/BMDC-INPUT_S35//" > sample-names.txt
# while read -r merge_bam rep1 rep2 rep3; do; samtools merge data/bam-files/merged-bam/$merge_bam.bam data/bam-files/$rep1*.bam data/bam-files/$rep2*.bam data/bam-files/$rep3*.bam; done <  config/merge-bam.txt


# I use narrow peaks for AC (H3K27Ac) samples
# cat config/sample-names-AC.txt | parallel --max-procs=8 'macs2 callpeak -t data/bam-files/{}.sorted.mrkdup.bam -c data/bam-files/BMDC-INPUT_S35.sorted.mrkdup.bam -g mm -n {}-peaks -q 0.01 --outdir data/bed-files'

# and broad peaks for ME (H3K27me3) samples
#cat config/sample-names-ME.txt | parallel --max-procs=8 'macs2 callpeak -t data/bam-files/{}.sorted.mrkdup.bam -c data/bam-files/BMDC-INPUT_S35.sorted.mrkdup.bam --broad -g mm -n {}-peaks -q 0.01 --outdir data/bed-files'


## I will relax the q value treshold just to see what happens

find data/bam-files/merged-bam -name 'h3k27ac*.bam' | sed s'/data\/bam-files\/merged-bam\///' | parallel  --max-procs=8 'macs2 callpeak -t data/bam-files/merged-bam/{} -f BAMPE -c data/bam-files/BMDC-INPUT_S35.sorted.mrkdup.bam -g mm -n {}-peaks -q 0.06 --outdir data/macs2-files-0-05/'

## ! TODO do the same for me3??
