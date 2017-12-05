###########################################
#For Running on Oakley                    #
#PBS -N trimmingfastqs                    #
#PBS -l nodes=1:ppn=12                    #
#PBS -m abe                               #
#PBS -M jenninec@mail.uc.edu              #
#PBS -l walltime=2:00:00                  #
#PBS -j oe                                #
#PBS -S /bin/bash                         #
###########################################
cd /fs/lustre/ucn1320/roachmicro/OSU16

module load java/1.8.0_131
module load python/3.4.2
module load R/3.2.0

export PATH=${PATH}:${HOME}/bin:$HOME/local/src/Trimmomatic-0.36/
export PATH=${PATH}:${HOME}/bin:$HOME/local/src/Trimmomatic-0.36/trimmomatic-0.3.6.jar

f_primer_len=19
r_primer_len=20
target_len=151

for file in /fs/lustre/ucn1320/roachmicro/OSU16/O*_R1.fastq
do
  filename=$((basename $file)|cut -f 1 -d '.')
  java -jar $HOME/local/src/Trimmomatic-0.36/trimmomatic-0.36.jar SE -trimlog $filename.log $file $filename.trim.fastq HEADCROP:$f_primer_len CROP:$target_len

  originalcnt= grep -c '@' $file
  newcnt= grep -c '@' $filename.trim.fastq

  if test "$originalcnt" = "$newcnt"
    then
      echo "no reads lost"
    else
      echo "reads lost"
      exit
  fi
done

for file in /fs/lustre/ucn1320/roachmicro/OSU16/O*_R2.fastq
do
  filename=$((basename $file)|cut -f 1 -d '.')
  java -jar $HOME/local/src/Trimmomatic-0.36/trimmomatic-0.36.jar SE -trimlog $filename.log $file $filename.trim.fastq HEADCROP:$r_primer_len CROP:$target_len

  originalcnt= grep -c '@' $file
  newcnt= grep -c '@' $filename.trim.fastq

  if test "$originalcnt" = "$newcnt"
    then
      echo "no reads lost"
    else
      echo "reads lost"
      exit
  fi
done
