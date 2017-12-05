###########################################
#For Running on Oakley                    
#PBS -N trimmingfastqs                    
#PBS -l nodes=1:ppn=12                    
#PBS -m abe                               
#PBS -M jenninec@mail.uc.edu              
#PBS -l walltime=2:00:00                  
#PBS -j oe                                
#PBS -S /bin/bash                         
###########################################
cd /fs/lustre/ucn1320/roachmicro/OSU16 #change to your working directory

module load java/1.8.0_131 #import current java
module load python/3.4.2 #this is unnecessary
module load R/3.2.0 #this is also unnecessary but whatever

export PATH=${PATH}:${HOME}/bin:$HOME/local/src/Trimmomatic-0.36/ #export paths in environment
export PATH=${PATH}:${HOME}/bin:$HOME/local/src/Trimmomatic-0.36/trimmomatic-0.3.6.jar #export paths in environment

f_primer_len=19 #this is the length of your forward primer or how many bases you want to trim from the front of your forward reads
r_primer_len=20 #this is the length of the reverse primer or how many bases you want to trim from the front of your reverse reads
target_len=151 #this is the target length of your reads

for file in /fs/lustre/ucn1320/roachmicro/OSU16/O*_R1.fastq #denoting the read 1 files to work on note that i use O* because i wanted to work on only files beginning with O
do
  filename=$((basename $file)|cut -f 1 -d '.') #making a variable that will be the filename. we will use this later
  java -jar $HOME/local/src/Trimmomatic-0.36/trimmomatic-0.36.jar SE -trimlog $filename.log $file $filename.trim.fastq HEADCROP:$f_primer_len CROP:$target_len #this is the trimmomatic actual command
  #we are running these as single ends because i wanted to process them invidually because we will asses the alignment using mothur

  originalcnt= grep -c '@M' $file #here we are counting how many reads there are in the original file
  newcnt= grep -c '@M' $filename.trim.fastq #counting reads in trimmed file **using @M because it is the first 2 characters of each read name. @ exists in other lines as well so it will count wrong

  if test $originalcnt -eq $newcnt #testing to make sure the number of reads are the same
    then
      echo "no reads lost"
    else
      echo "reads lost"
      exit
  fi
done

for file in /fs/lustre/ucn1320/roachmicro/OSU16/O*_R2.fastq #saying here we are going to do the R2 note that i use O* because i wanted to work on only files beginning with O
do
  filename=$((basename $file)|cut -f 1 -d '.')  #making a variable that will be the filename. we will use this later
  java -jar $HOME/local/src/Trimmomatic-0.36/trimmomatic-0.36.jar SE -trimlog $filename.log $file $filename.trim.fastq HEADCROP:$r_primer_len CROP:$target_len #this is the trimmomatic actual command
#we are running these as single ends because i wanted to process them invidually because we will asses the alignment using mothur

  originalcnt= grep -c '@M' $file #here we are counting how many reads there are in the original file
  newcnt= grep -c '@M' $filename.trim.fastq #counting reads in trimmed file **using @M because it is the first 2 characters of each read name. @ exists in other lines as well so it will count wrong

  if test $originalcnt -eq $newcnt #testing to make sure the number of reads are the same
    then
      echo "no reads lost"
    else
      echo "reads lost"
      exit
  fi
done
