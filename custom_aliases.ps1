function kspo { 
	param ([Parameter(Position=0)] [string]$Keyword, [Alias("w")] [switch]$Watch = $false) 

	if($Watch){
		while($true){
			clear
			kgpo
			Start-Sleep -Seconds 3
		}
	}

	if($Keyword -eq ""){
		kgpo
		return
	}
	kgpo | Select-String $Keyword
}

function ksrmpo {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Keyword,
	[Alias("r")]
        [switch]$Recursive = $false
    )

    $pods = (kgpo | Select-String $Keyword) -Split "\n"

    $pods | ForEach-Object {
       $podName = ($_ -Split "\s+")[0]
       if ($podName -ne "NAME") {
          krmpo $podName
	  if (-not $Recursive) {
                return
            }
       }
    }
}

function kslpo {
	param ([Parameter(Position=0, Mandatory=$true)] [string]$Keyword, [Alias("c")] [string]$Container = "")
	$pod=$((kgpo | Select-String $Keyword) -Split "\s+")[0]
	if($Container -eq ""){
		klo $pod
		return
	}
	klo $pod -c $Container
}


function _OLD_PROMPT {""}
copy-item function:prompt function:_OLD_PROMPT
function prompt {
	$K8sContext=$(Get-Content ~/.kube/config | Select-String -Pattern "current-context: (.*)")
	$exclude = @("gke_arcane-transit-357411_us-east1_")
	If ($K8sContext) {
		$ctx=$K8sContext.Matches[0].Groups[1].Value
		foreach ($excludedValue in $exclude) {
                	$ctx = $ctx -replace $excludedValue
            	}
		# Set the prompt to include the cluster name
		Write-Host -NoNewline -ForegroundColor Green "[$ctx] "
	}
	_OLD_PROMPT
}

function .. {
	cd ..
}

function ksdpo {
	param ([Parameter(Position=0, Mandatory=$true)] [string]$Keyword, [Alias("c")] [string]$Container = "")
	$pod=$((kgpo | Select-String $Keyword) -Split "\s+")[0]
	if($Container -eq ""){
		kdpo $pod
		return
	}
	kdpo $pod -c $Container
}

