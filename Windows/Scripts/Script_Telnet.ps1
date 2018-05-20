#https://community.spiceworks.com/scripts/show/1887-get-telnet-telnet-to-a-device-and-issue-commands
Param (
        [Parameter(ValueFromPipeline=$true)]
        [String[]]$Commands = @("username","password","AT*DATE?","AT*RSSI?"),
        [string]$RemoteHost = "HostnameOrIPAddress",
        [string]$Port = "2332",
        [int]$WaitTime = 1000,
        #[string]$OutputPath = "\\server\share\switchbackup.txt"
    )
    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Writer->AutoFlush = true;
        $Buffer = New-Object System.Byte[] 1024 
        $Encoding = New-Object System.Text.Utf8Encoding

        #Now start issuing the commands
        ForEach ($Command in $Commands)
        {   
            #Add date to prefix each command
            if ($Command -match '.*AT.*') {
                $Writer.WriteLine("AT*DATE?") 
                $Writer.Flush()
                Start-Sleep -Milliseconds $WaitTime
            } Else{}
            $Writer.WriteLine($Command) 
            $Writer.Flush()
            Start-Sleep -Milliseconds $WaitTime
        }
        #All commands issued, but since the last command is usually going to be
        #the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        $Result = ""
        #Save all the results
        While($Stream.DataAvailable) 
        {   
            $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
    
}Else     
    {   $Result = "Unable to connect to host: $($RemoteHost):$Port"
    }
    #Done, now save the results to a file
    #$Result | Out-File -Encoding "UTF8" $OutputPath
    $Result

#Examples
#Edit the seconds below to fit your needs
#Extreme Network Switch
#Get-Telnet -RemoteHost "192.168.1.2" -Commands "username","password","disable clipaging","sh config" -OutputPath "\\server\share\hqswitches.txt"
#Dell Switch
#Get-Telnet -RemoteHost "10.10.10.2" -Commands "admin","password","terminal datadump","show run" -OutputPath "\\server\share\DellHQswitches.txt" -WaitTime 2000
#Cisco ASA
#Get-Telnet -RemoteHost "192.168.10.1" -Commands "admin","password","terminal pager 0","show run" -OutputPath "\\server\share\CiscoFirewall.txt"
#Use a command file
#Get-Telnet -Commands (Get-Content "c:\scripts\commands.txt") -RemoteHost "192.168.10.1" -OutputPath "\\server\share\ciscoswitch.txt" -WaitTime 1500

#.\telnet.ps1 -RemoteHost sentinelbus.eairlink.com -Commands " ", "user", "password", "AT*NETIP?", "AT*NETSTATE?", "AT*NETRSSI?", "AT*CELLINFO?"

#props.conf
#[telnet]
#BREAK_ONLY_BEFORE = AT\*DATE\?
#disabled = false
#EXTRACT-key,value,status = (AT\*DATE\?)?\n*.*(?P<key>^AT[\w\d*?!]*)\n+(?P<value>.*)\n+(?P<status>.*)
