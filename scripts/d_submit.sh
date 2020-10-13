#!/bin/bash                                                                     
#SBATCH --ntasks=28
#SBATCH --cpus-per-task=1                   
#SBATCH -J test1                                                                
#SBATCH -o %x-%j.out                                                           
#SBATCH -e %x-%j.err                                                           
#SBATCH -t 0-00:15:00                                                           
#SBATCH --mail-type=ALL                                                      
#SBATCH --mail-user=mvanega1@asu.edu                                            
                                                                                
                                                                                
~/NetLogo-6.1.1/netlogo-headless.sh --model ~/communicationmodel/src/model9rounds-v2.nlogo --experiment test1 --threads 28                                                                
