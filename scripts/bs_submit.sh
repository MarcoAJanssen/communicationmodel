#!/bin/bash                                                                     
#SBATCH --ntasks=40
#SBATCH --cpus-per-task=1
#SBATCH -J test2                                                                
#SBATCH -o %x-%j.out                                                           
#SBATCH -e %x-%j.err                                                           
#SBATCH -t 0-04:00:00                                                           
#SBATCH --mail-type=ALL                                                      
#SBATCH --mail-user=mvanega1@asu.edu                                            
                                                                                
                                                                                
~/NetLogo-6.1.1/app/behaviorsearch/behaviorsearch_headless.sh -p results/tokenharvests/tokensharvests.searchConfig.xml -o results/behsearch/                                                                  
