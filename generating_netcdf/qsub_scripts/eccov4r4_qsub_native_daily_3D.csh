#PBS -S /bin/tcsh
#PBS -W group_list=g26113

### DEVEL
##PBS -l select=1:ncpus=12:model=bro
##PBS -l walltime=02:00:00
##PBS -q devel
##PBS -j oe

### NORMAL
#PBS -q normal
#PBS -l walltime=08:00:00

## 2D
##PBS -l select=26:ncpus=12:model=bro

## 3D
#PBS -l select=78:ncpus=4:model=bro

echo "cd into workdir"
cd $PBS_O_WORKDIR

#https://www.nas.nasa.gov/hecc/resources/pleiades.html

#rm -fr run_*

echo "set cpus"

# total number of cpus. 
# for 2D fields totcpus = 312 (26x12)
# for 3D fields totcpus = 312 (78X4)
set totcpus = 312
#set totcpus = 12
#set totcpus = 240 

echo "Total CPUS ${totcpus}"

# 28 maximum possible cpus per node on Broadwell
# for 2D fields cpuspernode = 12
# for 3D fields cpuspernode = 4
#set cpuspernode = 12
set cpuspernode = 4
echo "CPUS per node ${cpuspernode}"


# NATIVE GRID groupings

# ---- 2D
# 0 dynamic sea surface height and model sea level anomaly
# 1 ocean bottom pressure and model ocean bottom pressure anomaly
# 2 ocean and sea-ice surface freshwater fluxes
# 3 ocean and sea-ice surface heat fluxes
# 4 atmosphere surface temperature, humidity, wind, and pressure
# 5 ocean mixed layer depth
# 6 ocean and sea-ice surface stress
# 7 sea-ice and snow concentration and thickness
# 8 sea-ice velocity
# 9 sea-ice and snow horizontal volume fluxes

# ---- 3D
# 10 Gent-McWilliams ocean bolus transport streamfunction
# 11 ocean three-dimensional volume fluxes
# 12 ocean three-dimensional potential temperature fluxes
# 13 ocean three-dimensional salinity fluxes
# 14 sea-ice salt plume fluxes
# 15 ocean potential temperature and salinity
# 16 ocean density, stratification, and hydrostatic pressure
# 17 ocean velocity
# 18 Gent-McWilliams ocean bolus velocity
# 19 ocean three-dimensional momentum tendency

rm pbs_nodefile
cat "$PBS_NODEFILE" > pbs_nodefile

# latlon fields have 13 groups
# 0..8 are 2D
# 9..12 are 13

set first_grouping  = 10 
echo "first_grouping ${first_grouping}"

# end grouping (if one grouping, 1+cur_grouping)
set last_grouping = 19 
echo "last_grouping ${last_grouping}"

set cpu_start = 0
echo "cpu_start ${cpu_start}"

set cpu_end = `expr $totcpus - 1`
echo "cpu_end ${cpu_end}"

set ecco_access_dir = '/home5/ifenty/git_repos_others/ECCO-GROUP/ECCO-ACCESS/generating_netcdf'
set output_dir = '/nobackupp2/ifenty/podaac_20201216'
set output_freq_code = 'AVG_DAY'
set product_type = 'native'

echo "output_dir ${output_dir}"
echo "output_freq_code ${output_freq_code}"
echo "product_type ${product_type}"

mkdir -p ${output_dir}

# order of arguments to invoke_python_podaac.csh

#set numjobs  = `printf "%05d" $1`
#set job_id   = `printf "%05d" $2`
#set gid      = `printf "%05d" $3`
#set product_type = $4
#set output_freq_code = $5
#set output_dir = $6

set cur_grouping = ${first_grouping}
while ($cur_grouping <= $last_grouping)
	echo "Current Grouping : ${cur_grouping}"
		
	seq ${cpu_start} ${cpu_end} | parallel -j ${cpuspernode} -u --sshloginfile "$PBS_NODEFILE" \
		"cd $PWD; /bin/tcsh ${ecco_access_dir}/invoke_python_podaac.csh ${totcpus} {} ${cur_grouping} ${product_type} ${output_freq_code} ${output_dir}"
	
	set cur_grouping = `expr $cur_grouping + 1`
        echo "incremented cur_grouping ${cur_grouping}"
end
