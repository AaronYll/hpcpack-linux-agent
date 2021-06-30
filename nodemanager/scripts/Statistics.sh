#!/bin/bash
# collect the statistics of the cgroup

. common.sh

[ -z "$1" ] && echo "task id not specified" && exit 202
[ -z "$2" ] && echo "task folder not specified" && exit 202

taskId=$1
taskFolder=$2

isDockerTask=$(CheckDockerEnvFileExist $taskFolder)

userTime10Ms=0
kernelTime10Ms=0
processes=""
workingSetBytes=0

function GetCpuStatFile
{
	local groupName=$1
	GetGroupFile "$groupName" cpuacct cpuacct.stat
}

function GetCpusetTasksFile
{
	local groupName=$1
	GetGroupFile "$groupName" cpuset tasks
}

function GetMemoryMaxusageFile
{
	local groupName=$1
	GetGroupFile "$groupName" memory memory.max_usage_in_bytes
}

cgDisabled=$(CheckCgroupDisabledInFlagFile $taskFolder)
if $CGInstalled && ! $cgDisabled; then
	if $isDockerTask; then
		containerId=$(GetContainerId $taskFolder)
		groupName=$(GetCGroupNameOfDockerTask $containerId)
	else
		groupName=$(GetCGroupName "$taskId")
	fi
	
	statFile=$(GetCpuStatFile "$groupName")
	workingSetFile=$(GetMemoryMaxusageFile "$groupName")
	tasksFile=$(GetCpusetTasksFile "$groupName")

	cut -d" " -f2 "$statFile"
	cat "$workingSetFile"
	tr "\\n" " " < "$tasksFile"

	echo
else
    echo $userTime10Ms
    echo $kernelTime10Ms
    echo $workingSetBytes
    echo $processes
    echo
fi
