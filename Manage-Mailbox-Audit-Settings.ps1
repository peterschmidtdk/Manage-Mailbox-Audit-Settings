<#	
	.NOTES
	===========================================================================
	Title:		      Manage-Mailbox-Audit-Settings
	Created by:   	Peter Schmidt (peter@msdigest.net) 
  Blog:           www.msdigest.net
	Organization: 	Globeteam
	===========================================================================
	.DESCRIPTION
        - A small tool to get an overview of Exchange Audit.
        - And can be used to Manage Exchange Mailbox Audit and setting a maximum audit level on all mailboxes.

	.CHANGE LOG
		v1.0 22nd Mar 2018	Initial version (PSC)
    v1.1 14th Apr 2018	Updated with minor tweaks (PSC)
#>

#Set a dynamic script location based on where script is executed from
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

#Who are you
$who = $env:USERNAME

#Start verbose log capture
Start-Transcript -path ("$ScriptDir\$who.Transcript"+(get-date -Format ddMMyyyy)+".log") -append

#Function to load CSV file
Function Get-FileName($initialDirectory)
{
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.filter = "CSV (*.csv)| *.csv"
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.filename
}

#MENU Function
function menu
{cls
    Write-Host -Backgroundcolor Gray -Foregroundcolor red "                                            "
	Write-Host -Backgroundcolor Gray -Foregroundcolor red "                                            "
	Write-Host -Backgroundcolor Gray -Foregroundcolor red " Exchange Audit Settings Toolbox            "
    Write-Host -Backgroundcolor Gray -Foregroundcolor red "                                            "
    Write-Host -Backgroundcolor Gray -Foregroundcolor red "                                            "
    Write-Host ""
    Write-Host "Version 1"

    Write-Host ""
    Write-Host " Audit overview"
    Write-Host "  1.  Show The Count of All Mailboxes with Audit-Enabled"
    Write-Host "  2.  Show The Count of All Mailboxes without Audit-Enabled"
    Write-Host "  3.  List All Mailboxes without Audit-Enabled"

    Write-Host ""
    	
    Write-Host ""
    Write-Host " Enable Audit"
    Write-Host "  4.  Enable Audit for All Mailboxes"
    Write-Host ""

       
    Write-Host ""
    Write-Host " 99. Exit"
	
    Write-Host ""
	Write-Host -NoNewline -BackgroundColor Yellow -ForegroundColor DarkRed 'Please make a selection:'
    $answer = Read-Host	



    If ($answer -eq 1)
    {
        Write-Host ""
        Write-Host "This will take some time, please be patience..."
        (Get-mailbox -ResultSize unlimited | where {$_.AuditEnabled -eq $True}).count
        Write-Host "This is the number of mailboxes with Audit Enabled."
        Write-Host -NoNewLine 'Press any key to continue...';
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		MENU
    }


    If ($answer -eq 2)
    {
        Write-Host ""
        Write-Host "This will take some time, please be patience..."
        (Get-mailbox -ResultSize unlimited | where {$_.AuditEnabled -ne $True}).count
        Write-Host "This is the number of mailboxes with Audit Disabled."
        Write-Host -NoNewLine 'Press any key to continue...';
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		MENU
    }
    

    If ($answer -eq 3)
    {
        Write-Host ""
        Write-Host "This will take some time, here is a listing of all Mailboxes with Audit Enabled:"
        Get-mailbox -ResultSize unlimited | where {$_.AuditEnabled -eq $True}
        Write-Host ""
        Write-Host -NoNewLine 'Press any key to continue...';
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		MENU
    }


    If ($answer -eq 4)
    {
        #Setting Exchange Audit to Maximum Level
        $AuditAdmin="Create,FolderBind,MessageBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,Copy,MoveToDeletedItems"
        $AuditDelegate="Create,FolderBind,SendAs,SendOnBehalf,SoftDelete,HardDelete,Update,Move,MoveToDeletedItems"
        $AuditOwner="Create,SoftDelete,HardDelete,Update,Move,MoveToDeletedItems,MailboxLogin"

        #Set Audit Logging Days
        $AuditDays=90

        #Get all Mailboxes that has Not been Enabled for Audit
        $MBX=Get-mailbox -ResultSize unlimited | where {$_.AuditEnabled -ne $True}
        
        Write-Host ""
        Write-Host "This will take some time, please be patience..."
        
        #Setting the Audit Level for the Mailboxes
        $MBX | Set-Mailbox -AuditAdmin $AuditAdmin -AuditDelegate $AuditDelegate -AuditOwner $AuditOwner -AuditEnabled:$true -AuditLogAgeLimit $AuditDays
        
        Write-Host "All Mailboxes has now been set to Audit Enabled."
        Write-Host -NoNewLine 'Press any key to continue...';
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		MENU
    }

        
    If ($answer -eq 99) { exit }
	
	else
	{
		write-host -ForegroundColor red "Invalid Selection"
		sleep 1
		menu
	}
}

MENU

#End the log capture
$slut=get-date
($start)-($slut)
Stop-Transcript
