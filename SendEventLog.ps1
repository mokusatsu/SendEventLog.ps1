# SendEventLog.ps1
# Author: Keiji Okamoto


#Configration From Here
#==============================================================================

#Sender mail address / メールの送信者
$EmailFrom = "testuser@gmail.com"

#Recipient mail address / メールの宛先
$EmailTo = "testuser@gmail.com" 

#SMTP server setting / SMTPサーバの設定
$SmtpServer = "smtp.gmail.com" #server address
$SmtpPort = 587 #server port
$SmtpSsl = $true #SSL connection is needed or not: write "$true" or "$false"

#SMTP server authentification / SMTPサーバの認証
$AuthRequired = $true #authentification is needed or not: write "$true" or "$false"
$AuthUser = "testuser" #user id
$AuthPass = "testpassword" #user password

#Logs to search / 検索対象のログ
# 1=Error 2=Warning 3=Info 4=Verbose 5=Debug
$LogTypes = "Application", "System"
$LogLevels = 1,2

#Search number of minutes before
$LogSearchMinutes = 60

#Exclude filter for ProviderName and Id
$Filters = @{ ProviderName="Microsoft-Windows-DNS-Client"; Id=1014; }, @{ ProviderName="NotifEventLogSecond"; Id=202; }

#Exclude filter for message body
$MessageFilters = "some text1", "some text2"

#==============================================================================

$Events = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{ LogName=$LogTypes; Level=$LogLevels; } -MaxEvents 1000 | Where-Object { $_.TimeCreated -ge (get-date).AddMinutes(- $LogSearchMinutes).DateTime }

#Filter
foreach($Filter in $Filters) {
    $Events = $Events | Where-Object { -not ($_.ProviderName -eq $Filter.ProviderName -and $_.Id -eq $Filter.Id) }
}

foreach($MessageFilter in $MessageFilters) {
    $Events = $Events | Where-Object { -not ($_.Body -like $MessageFilter) }
}

#Finalize
$Events = $Events | Sort-Object -Property TimeCreated

$Body = ""
foreach($line in $Events) {
    $Body += "TimeCreated: "
    $Body += $line.TimeCreated
    $Body += "`n"

    $Body += "LevelDisplayName: "
    $Body += $line.LevelDisplayName
    $Body += "`n"

    $Body += "ProviderName: "
    $Body += $line.ProviderName
    $Body += "`n"

    $Body += "LogName: "
    $Body += $line.LogName
    $Body += "`n"

    $Body += "Id: "
    $Body += $line.Id
    $Body += "`n"

    $Body += "Task: "
    $Body += $line.Task
    $Body += "`n"

<#
    $Body += "KeywordsDisplayNames: "
    $Body += $line.KeywordsDisplayNames | ConvertTo-Csv
    $Body += "`n"
#>

    $Body += "UserId: "
    $Body += $line.UserId.Value
    $Body += "`n"

    $Body += "MachineName: "
    $Body += $line.MachineName
    $Body += "`n"

    $Body += "OpcodeDisplayName: "
    $Body += $line.OpcodeDisplayName
    $Body += "`n"

    $Body += "Body:`n"
    $Body += $line.Message
    $Body += "`n"

<#
    $Body += "Version: "
    $Body += $line.Version
    $Body += "`n"

    $Body += "ContainerLog: "
    $Body += $line.ContainerLog
    $Body += "`n"
#>


    $Body += "`n"
    $Body += "`n"
}

# Mailing procedure describes as below
# http://stackoverflow.com/questions/1252335/send-mail-via-gmail-with-powershell-v2s-send-mailmessage
$Subject = [System.Environment]::MachineName + " EVENTLOG REPORT" 

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SmtpPort) 
$SMTPClient.EnableSsl = $SmtpSsl

if($AuthRequired) {
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($AuthUser, $AuthPass) 
}

$MailMessage = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
#$MailMessage.IsBodyHtml = $true

if($Events.Count -ne 0) {
    $SMTPClient.Send($MailMessage)
}
