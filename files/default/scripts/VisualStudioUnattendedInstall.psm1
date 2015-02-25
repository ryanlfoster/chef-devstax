﻿function Install-VisualStudio {
    
    [CmdletBinding()]
    PARAM(
		[Parameter(Mandatory=$true)]
		[string] $ImagePath,
		[Parameter(Mandatory=$true)]
		[string] $AdminFile
	)

    Mount-DiskImage -ImagePath $ImagePath

    $driveLetter = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter

    $setup = $driveLetter + ":\vs_ultimate.exe"
    Write-Verbose "Setup is $setup"
    $exitCode = (Start-Process -FilePath $setup -ArgumentList "/AdminFile $AdminFile /Quiet /NoRestart /NoRefresh" -Wait -PassThru).ExitCode
    if($exitCode -ne 3010) {
        Write-Error "Visual Studio Setup exit code [$exitCode]"
    }
    else {
        Write-Verbose "Successful installation"
    }

    Dismount-DiskImage -ImagePath $ImagePath
}
