# A collection of pipelines for RNASeq analysis
## Pipelines / programs 
1. TopHat/Cufflinks pipeline
### Prequsites
1. TopHat/Cufflinks pipeline <br>
  a) bowtie <br>
  b) tophat <br>
  c) samtools <br>
  d) cufflinks <br>
#### Run command
1. TopHat/Cufflinks pipeline
```
./rnaseq_pipeline_tophat.sh OUTPUT_FOLDER REFERENCE_GENOME INPUT_FILENAME_TEMPLATE NUMBER_OF_CORES LIBRARY_TYPE
```
#### Asumptions
1. TopHat/Cufflinks pipeline <br>
* Each filename is in the format : text_L00N_RM_00X.fastq.gz, where:
  *  N is the LANE number (1-4)
  *  M is the RUN number  (1-2)
  *  X is the re-run number ? 
* There is only one for each lane/run combination in the folder			
