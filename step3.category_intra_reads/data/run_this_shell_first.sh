gzip -d *gz
cat hg19.integrated.PC5UTR.bed hg19.integrated.PCCDS.bed hg19.integrated.PCIntron.bed hg19.integrated.PC3UTR.bed hg19.integrated.NCExon.bed hg19.integrated.NCIntron.bed > hg19.integrated.gene_element.bed
rm -rf hg19.integrated.PC5UTR.bed hg19.integrated.PCCDS.bed hg19.integrated.PCIntron.bed hg19.integrated.PC3UTR.bed hg19.integrated.NCExon.bed hg19.integrated.NCIntron.bed 
