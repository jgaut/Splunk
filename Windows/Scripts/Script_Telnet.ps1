#https://community.spiceworks.com/scripts/show/1887-get-telnet-telnet-to-a-device-and-issue-commands
Param (
        [Parameter(ValueFromPipeline=$true)]
        [String[]]$Commands = @("username","password","AT*DATE?","AT*RSSI?"),
        [string]$RemoteHost = "HostnameOrIPAddress",
        [string]$Port = "2332",
        [int]$WaitTime = 1000
    )

    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        #$Writer->AutoFlush = true
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
#.\telnet.ps1 -RemoteHost sentinelbus.eairlink.com -Commands " ", "user", "password", "AT*NETIP?", "AT*NETSTATE?", "AT*NETRSSI?", "AT*CELLINFO?"

#props.conf
#[telnet]
#BREAK_ONLY_BEFORE = AT\*DATE\?
#disabled = false
#EXTRACT-key,value,status = (AT\*DATE\?)?\n*.*(?P<key>^AT[\w\d*?!]*)\n+(?P<value>.*)\n+(?P<status>.*)
