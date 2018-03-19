﻿#*************************************************************************************************
# Write-Signature
# This must be run in the PowerShell ISE
# Originally written by Jeffrey Hicks, ScriptingGeek.com
#*************************************************************************************************
 
function Write-Signature ()
{
	Set-StrictMode -Version Latest

    $file = $psISE.CurrentFile
    $row = $file.Editor.CaretLine
    $col = $file.Editor.CaretColumn

    # make writable
    if (!$file.IsUntitled)
    {
        if ($file.FullPath -and (Test-Path $file.FullPath))
        {
            Set-ItemProperty $file.FullPath -name IsReadOnly -value $false
        }
    }

	# get the certificate
	$cert = Get-ChildItem -Path Cert:\LocalMachine\Root -CodeSigningCert
	if ($cert)
	{
		# save the file if necessary
		if (!$psISE.CurrentFile.IsSaved)
		{
			$psISE.CurrentFile.Save()
		}

		# if the file is encoded as BigEndian, resave as Unicode
		if ($psISE.CurrentFile.Encoding.EncodingName -match "Big-Endian")
		{
			$psISE.CurrentFile.Save([Text.Encoding]::Unicode) | Out-Null
		}

		# save the filepath for the current file so it can be re-opened later
		$filepath = $psISE.CurrentFile.FullPath

		# sign the file
		try
        {
            $cert = $cert | Select -first 1
		    Set-AuthenticodeSignature -FilePath $filepath -Certificate $cert -errorAction Stop | Out-Null

            $files = $psISE.CurrentPowerShellTab.Files
		    # close the file
		    $files.Remove($psISE.currentfile) | Out-Null

		    # reopen the file
		    $files.Add($filepath) | out-null
            $file = $files.Item($files.Count - 1)
            $files.SetSelectedFile($file)
            $file.Editor.SetCaretPosition($row, $col)
		}
		catch
        {
		    Write-Warning ("Script signing failed. {0}" -f $_.Exception.message)
		}
	}
	else
	{
		Write-Warning "No code signing certificate found."
	}
}

# SIG # Begin signature block
# MIINIQYJKoZIhvcNAQcCoIINEjCCDQ4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUA0Q6kui3+eh7WqrBT7hd/EXA
# jnWgggpWMIIE9TCCA92gAwIBAgIQJNJNfU2gAP3HGaji2H4jXTANBgkqhkiG9w0B
# AQsFADB/MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRp
# b24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxMDAuBgNVBAMTJ1N5
# bWFudGVjIENsYXNzIDMgU0hBMjU2IENvZGUgU2lnbmluZyBDQTAeFw0xNTA2MjQw
# MDAwMDBaFw0xODA3MjMyMzU5NTlaMIGHMQswCQYDVQQGEwJVUzEWMBQGA1UECBMN
# TWFzc2FjaHVzZXR0czEQMA4GA1UEBxMHTWlsZm9yZDEbMBkGA1UEChQSV2F0ZXJz
# IENvcnBvcmF0aW9uMRQwEgYDVQQLFAtJbmZvcm1hdGljczEbMBkGA1UEAxQSV2F0
# ZXJzIENvcnBvcmF0aW9uMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# s00KvxoIZfX/ueMwE9AS1gx+VrG8n4raLJA4QPXnSW+4Ae3gOPoiHwjYD+RW7+Db
# 5y5PMADShoLkJWcsoOB9egN/tUnV2Zlz2/3L0f5KAN5XUvym2vjJBXbK484BMnd8
# LyOR9U0jAiY3tFJZvQBh8NVmBFvTZR20osM1r1Z2cGadeiUkKxGO0JETiWZBK4au
# mlHe7PXiWhkyhi+hLZdnXhLQPydAzd5X6vcQum3C3rCDE4PPD8/1UQz1A2G8BuzI
# oT5Ha6ES0x113qTW4sMBOfwxnhv60SiICHxZwltbEt26HPw44q65r5LncBbHEiTd
# 7lGEl/hyPq1+1vJxoiLW3wIDAQABo4IBYjCCAV4wCQYDVR0TBAIwADAOBgNVHQ8B
# Af8EBAMCB4AwKwYDVR0fBCQwIjAgoB6gHIYaaHR0cDovL3N2LnN5bWNiLmNvbS9z
# di5jcmwwZgYDVR0gBF8wXTBbBgtghkgBhvhFAQcXAzBMMCMGCCsGAQUFBwIBFhdo
# dHRwczovL2Quc3ltY2IuY29tL2NwczAlBggrBgEFBQcCAjAZDBdodHRwczovL2Qu
# c3ltY2IuY29tL3JwYTATBgNVHSUEDDAKBggrBgEFBQcDAzBXBggrBgEFBQcBAQRL
# MEkwHwYIKwYBBQUHMAGGE2h0dHA6Ly9zdi5zeW1jZC5jb20wJgYIKwYBBQUHMAKG
# Gmh0dHA6Ly9zdi5zeW1jYi5jb20vc3YuY3J0MB8GA1UdIwQYMBaAFJY7U/B5M5ev
# fYPvLivMyreGHnJmMB0GA1UdDgQWBBTqEzkwwDqoq15Zc9xJrYV6VUbw+zANBgkq
# hkiG9w0BAQsFAAOCAQEAdgdVLBPA0mAxL3onwAkQcY0j+9i05R+aIaeFOhuzFyTI
# /CQMx9Oec2irX9ZjMS/MADj3G2XQTV/RImB6/viZjZ520iF8wlfEaMprmCYJjfJi
# OHjym9z16Na9ruqJ4t4+GDldnMvYdVSmhg2v+Ff6q3CYziMhi+7ggV9Q+6TbALxn
# u2T6cLHmHyF0DTmCApos9CgTHncyJIPhYCl91CdFdpgO4raV5ZACIa17Elt18/zl
# oZB4Yz2Qokh6ZuRGv2PsvkDjL9ASeR/y3i74sVYecqUPqdl+eMyfh8QM1ebJM1iA
# CI7XqBhGwbSs7+4QJGfeG0K44csQegxFRlBTj29rIjCCBVkwggRBoAMCAQICED14
# 1/l2SWCyYX308B7KhiowDQYJKoZIhvcNAQELBQAwgcoxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3Qg
# TmV0d29yazE6MDgGA1UECxMxKGMpIDIwMDYgVmVyaVNpZ24sIEluYy4gLSBGb3Ig
# YXV0aG9yaXplZCB1c2Ugb25seTFFMEMGA1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQ
# dWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEc1MB4XDTEz
# MTIxMDAwMDAwMFoXDTIzMTIwOTIzNTk1OVowfzELMAkGA1UEBhMCVVMxHTAbBgNV
# BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVz
# dCBOZXR3b3JrMTAwLgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2Rl
# IFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCXgx4A
# Fq8ssdIIxNdok1FgHnH24ke021hNI2JqtL9aG1H3ow0Yd2i72DarLyFQ2p7z518n
# TgvCl8gJcJOp2lwNTqQNkaC07BTOkXJULs6j20TpUhs/QTzKSuSqwOg5q1PMIdDM
# z3+b5sLMWGqCFe49Ns8cxZcHJI7xe74xLT1u3LWZQp9LYZVfHHDuF33bi+VhiXjH
# aBuvEXgamK7EVUdT2bMy1qEORkDFl5KK0VOnmVuFNVfT6pNiYSAKxzB3JBFNYoO2
# untogjHuZcrf+dWNsjXcjCtvanJcYISc8gyUXsBWUgBIzNP4pX3eL9cT5DiohNVG
# uBOGwhud6lo43ZvbAgMBAAGjggGDMIIBfzAvBggrBgEFBQcBAQQjMCEwHwYIKwYB
# BQUHMAGGE2h0dHA6Ly9zMi5zeW1jYi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBs
# BgNVHSAEZTBjMGEGC2CGSAGG+EUBBxcDMFIwJgYIKwYBBQUHAgEWGmh0dHA6Ly93
# d3cuc3ltYXV0aC5jb20vY3BzMCgGCCsGAQUFBwICMBwaGmh0dHA6Ly93d3cuc3lt
# YXV0aC5jb20vcnBhMDAGA1UdHwQpMCcwJaAjoCGGH2h0dHA6Ly9zMS5zeW1jYi5j
# b20vcGNhMy1nNS5jcmwwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMDMA4G
# A1UdDwEB/wQEAwIBBjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRU3ltYW50ZWNQ
# S0ktMS01NjcwHQYDVR0OBBYEFJY7U/B5M5evfYPvLivMyreGHnJmMB8GA1UdIwQY
# MBaAFH/TZafC3ey78DAJ80M5+gKvMzEzMA0GCSqGSIb3DQEBCwUAA4IBAQAThRoe
# aak396C9pK9+HWFT/p2MXgymdR54FyPd/ewaA1U5+3GVx2Vap44w0kRaYdtwb9oh
# BcIuc7pJ8dGT/l3JzV4D4ImeP3Qe1/c4i6nWz7s1LzNYqJJW0chNO4LmeYQW/Ciw
# sUfzHaI+7ofZpn+kVqU/rYQuKd58vKiqoz0EAeq6k6IOUCIpF0yH5DoRX9akJYmb
# BWsvtMkBTCd7C6wZBSKgYBU/2sn7TUyP+3Jnd/0nlMe6NQ6ISf6N/SivShK9DbOX
# Bd5EDBX6NisD3MFQAfGhEV0U5eK9J0tUviuEXg+mw3QFCu+Xw4kisR93873NQ9Tx
# TKk/tYuEr2Ty0BQhMYICNTCCAjECAQEwgZMwfzELMAkGA1UEBhMCVVMxHTAbBgNV
# BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVz
# dCBOZXR3b3JrMTAwLgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2Rl
# IFNpZ25pbmcgQ0ECECTSTX1NoAD9xxmo4th+I10wCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFB5M
# OVDq2guPpfPQbIjC9wyTW1O6MA0GCSqGSIb3DQEBAQUABIIBABduHJhoOgdYgdXv
# Rtzyl5qgzi7k5noejBTwStpZj0Uk1jLFZ8ln/oowOkD7wExdf6G/bcecI1E4J5qv
# Ox/cODdl+dXK6o1Dg+KwkhvPeQyXhTkslt30+gp/KpSXjI9YT9wfKxipuZwOlrH9
# q3TsntZKyQOGYJAC9ybNrvz1A3+uUysKJU7mBHtiM7yZyJraPqqtmSXCZQmuC3Ri
# aGqa2ZOzpSWrlxoTNTW0tjcmHmWxdfvb1byFkr6ugIgVumYCGzgNRTuxil8QFNSe
# QlxlHjfXQ7pVmNK5GpmigCgVUm7xVMU2kCFeQwqZYDITq96T0ORzCB+Hw4ijJIua
# 3GkSKFc=
# SIG # End signature block
