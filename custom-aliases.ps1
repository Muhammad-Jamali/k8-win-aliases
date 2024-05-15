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
	param ([Parameter(Position = 0)] [string]$Domain, [Alias("w")] [switch]$Watch = $false, [Alias("t")] [string]$TimeOut = 2) 
	while ($Watch) {
		clear
		nslookup $Domain
		Start-Sleep -Seconds $TimeOut
	}
	nslookup $Domain
}
function kspo {
    param (
        [Parameter(Position = 0)]
        [string]$Keyword = "",

        [Alias("w")]
        [switch]$Watch = $false,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$AdditionalParams
    )
    
    while ($Watch) {
        Clear-Host
        kspo $Keyword @AdditionalParams
        Start-Sleep -Seconds 3
    }
    if ($Keyword -ne ""){
       & kubectl get pods @AdditionalParams | Select-String $Keyword
	return
    }
   & kubectl get pods @AdditionalParams
}


function ksdpo {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Keyword,
        
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$AdditionalParams
    )

    $filteredResults = kubectl get pods @AdditionalParams | Select-String $Keyword
    if ($filteredResults) {
        $pod = $filteredResults -Split "\s+" | Select-Object -First 1
        if ($pod) {
            kdpo $pod @AdditionalParams
        } else {
            Write-Output "No valid pod data found."
        }
    } else {
        Write-Output "No pods match the keyword '$Keyword'."
    }
}



function ksrmpo {
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$Keyword,
		
		[Alias("r")]
		[switch]$Recursive = $false,
	        
		[Parameter(ValueFromRemainingArguments = $true)]
        	[string[]]$AdditionalParams
	)

	$pods = (kubectl get pods @AdditionalParams | Select-String $Keyword) -Split "\n"
	$pods | ForEach-Object {
		$podName = ($_ -Split "\s+")[0]
		if ($podName -ne "NAME") {
			krmpo $podName $AdditionalParams
		  if (-not $Recursive) {
				return
	          }
		}
	}
}

function kslo {
	param (
		[Parameter(Position = 0, Mandatory = $true)] 
		[string]$Keyword,
		[Parameter(Mandatory = $true)] 
		[string]$Container,
		[Parameter(ValueFromRemainingArguments = $true)]
        	[string[]]$AdditionalParams
	)
	$filteredResults = kubectl get pods @AdditionalParams | Select-String $Keyword
	if ($filteredResults) {
        	$pod = $filteredResults -Split "\s+" | Select-Object -First 1
        	if ($pod) {
	            klo $pod -c $Container @AdditionalParams
        	} else {
	            Write-Output "No valid pod data found."
        	}
         } else {
      	  Write-Output "No pods match the keyword '$Keyword'."
	 }
}

function ksex {
	param (
		[Parameter(Position = 0, Mandatory = $true)] 
		[string]$Keyword,
		[Parameter(Mandatory = $true)] 
		[string]$Container,
		[Parameter(ValueFromRemainingArguments = $true)]
        	[string[]]$AdditionalParams
	)
	$filteredResults = kubectl get pods @AdditionalParams | Select-String $Keyword
	if ($filteredResults) {
        	$pod = $filteredResults -Split "\s+" | Select-Object -First 1
        	if ($pod) {
	            kex $pod -c $Container @AdditionalParams -- bash
        	} else {
	            Write-Output "No valid pod data found."
        	}
         } else {
      	  Write-Output "No pods match the keyword '$Keyword'."
	 }
}



function .. {
	cd ..
}
