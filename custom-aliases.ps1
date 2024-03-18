function _old_prompt { "" }
copy-item function:prompt function:_old_prompt
function prompt {
	$K8sContext = $(Get-Content ~/.kube/config | Select-String -Pattern "current-context: (.*)")
	$exclude = @("gke_arcane-transit-357411_us-east1_")
	If ($K8sContext) {
		$ctx = $K8sContext.Matches[0].Groups[1].Value
		foreach ($excludedValue in $exclude) {
			$ctx = $ctx -replace $excludedValue
		}
		# Set the prompt to include the cluster name
		Write-Host -NoNewline -ForegroundColor Green "[$ctx] "
	}
	_old_prompt
}
function certgen {
	param ([Parameter(Position = 0)] [string]$Dns, [Alias("d")] [string]$Dir) 
	$notAfter = [datetime]::Today.AddYears(2)
	$thumb = (sudo New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName $Dns -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint
	$pwd = '123'
	$SSpwd = ConvertTo-SecureString -String $pwd -Force -AsPlainText
	Export-PfxCertificate -cert "cert:\localmachine\my\$thumb" -FilePath $Dir/test.pfx -Password $SSpwd
}
function nsl {
	param ([Parameter(Position = 0)] [string]$Domain, [Alias("w")] [switch]$Watch = $false) 
	while ($Watch) {
		clear
		nslookup $Domain
		Start-Sleep -Seconds 2
	}
	nslookup $Domain
}
function kspo { 
	param ([Parameter(Position = 0)] [string]$Keyword, [Alias("w")] [switch]$Watch = $false) 
	while ($Watch) {
		clear
		kspo $Keyword
		Start-Sleep -Seconds 3
	}
	echo $args
	echo $Keyword
	if ($Keyword -eq "") {
		kgpo
		return
	}
	kgpo | Select-String $Keyword
}


function ksdpo {
	param ([Parameter(Position = 0, Mandatory = $true)] [string]$Keyword, [Alias("c")] [string]$Container = "")
	$pod = $((kgpo | Select-String $Keyword) -Split "\s+")[0]
	if ($Container -eq "") {
		kdpo $pod
		return
	}
	kdpo $pod -c $Container
}


function ksrmpo {
	param (
		[Parameter(Position = 0, Mandatory = $true)]
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

function kslo {
	param ([Parameter(Position = 0, Mandatory = $true)] [string]$Keyword, [Alias("c")] [string]$Container = "")
	$pod = $((kgpo | Select-String $Keyword) -Split "\s+")[0]
	if ($Container -eq "") {
		klo $pod
		return
	}
	klo $pod -c $Container
}

function ksex {
	param ([Parameter(Position = 0, Mandatory = $true)] [string]$Keyword, [Alias("c")] [string]$Container = "")
	$pod = $((kgpo | Select-String $Keyword) -Split "\s+")[0]
	if ($Container -eq "") {
		kex $pod -- bash
		return
	}
	kex $pod -c $Container -- bash
}



function .. {
	cd ..
}
