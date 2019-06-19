        $pathService = "D:\suresh\ECMHealthPSScript\"
        $serverdataArray = import-csv ($pathService + "ECMServices.csv")
 $serverdataArray
        $servers = @()
        $LiveserverArray = @()
        $driveArray=@()
        $processJavaArray=@()
        $dataArrayToExport=@()
        $processInterfaceArray =@()
        $serviceArray =@()
        $dbserviceArray=@()
        $URLMonitoringArray=@()
        
        $DatabaseName = "pranlsdb"
        $port = 50001
        $username = "icmadmin"
        $password = "cp@gl0be"
        $schema = "icmadmin"
        $provider="IBMDADB2"
        $dbhostname = "jsy-ecmcmsla02"
        $connectionString = ("Provider=" + $provider + ";Database=" + $DatabaseName + ";HostName=" + $dbhostname + ";Protocol=TCPIP;Port=" + $port + ";Uid=" + $username + ";Pwd=" + $password + ";CurrentSchema=" + $schema )
                

        # Find Unique Server Name from ServerData Array
         foreach ($row in $serverdataArray){
                    $flag = $servers -Contains($row.ServerName) 
                        If ( $flag -ne $True ) {                            
                                $servers += $row.ServerName
                     }
         #Closed : Find Unique Server Name from ServerData Array
         }           
         
         
         
         # Check Wheather Server is up and running
         foreach ($hostname in $servers){
         
                            # Write-output "The remote computer " $hostname " is Online"
                            
                             $refObject = New-Object -TypeName psobject 
                             $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $hostname
                             $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "Server Availibility"
                             $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value "Server ping and reply Status"
                             
                             
                                IF (Test-Connection -BufferSize 32 -Count 1 -ComputerName $hostname -Quiet){
                                    $refObject | Add-Member -MemberType NoteProperty -Name Status -Value ($hostname + " Server is Available")
                                    $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Green"
                                    $LiveserverArray += $hostname
                            
                                }else{
                                    $refObject | Add-Member -MemberType NoteProperty -Name Status -Value ($hostname + " Server is UnAvailable/ Down")
                                    $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Red"
                                }

                     
                           $dataArrayToExport +=$refObject
                           $refObject = $null                      
                   
         
         #Closed : Check Wheather Server is up and running
         }
         
         
         # Fill Service Array for Live Servers only
         foreach ($row in $serverdataArray){
        
                    $flag = $LiveserverArray -Contains($row.ServerName) 
                        
                        If ( $flag -eq $True ) {                            
                                
                
                                if ($row.HealthCheckUpType -eq "Drive") {
                                $driveArray += $row
                                }
                    
                                if ($row.HealthCheckUpType -eq "Process_JavaAppsOn_Interfaces") {
                                $processJavaArray += $row
                                }
        
        
                                if ($row.HealthCheckUpType -eq "Process_Interface") {
                                $processInterfaceArray += $row
                                }
        
                                if ($row.HealthCheckUpType -eq "Service") {
                                $serviceArray += $row
                                }
                                
                                
                                if ($row.HealthCheckUpType -eq "RMOfflineFlag" ){
                                $dbserviceArray += $row
                                }
        
                                if ($row.HealthCheckUpType -eq "URLMonitoring" ){
                                $URLMonitoringArray += $row
                                }
        
                        }
        #Closed :Fill Service Array for Live Servers only
        }           
                



                
                   #Opening of Drive Function
                    
                    foreach ($row in $driveArray){
                    
                                
                                $deviceID = $row.service.substring(0,2)
                                $deviceID = "DeviceID='" + $deviceID + "'"
                                $driveList = Get-WMIObject Win32_MappedLogicalDisk -computername $row.ServerName  -Filter $deviceID  | Select Name , ProviderName , FileSystem, Size, FreeSpace
                                
                                $refObject = New-Object -TypeName psobject 
                				$refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $row.ServerName 
                                $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "Drive"
                				$refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value $row.service 
                			    
                                
                                if ($driveList -eq $null){
                                                             $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Stopped"
                                                             $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Drive is not mapped. Kindly map the drive."  
                              
                                }
                                else{
                                							 $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Running"
                                                             $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Green"
                                
                                }
                                
                                $dataArrayToExport +=$refObject
                                $refObject = $null
                                        
                    #Close of Drive Function           
                    }

        
        
        
        
                    #Open of Java PRocess - Interfaces
                    foreach ($row in $processJavaArray) {
                    
                                       $command = "CommandLine like '%" +  $row.service + "%'"
                            

									   $processDetais = Get-WmiObject Win32_Process -ComputerName $row.ServerName -Filter $command  | Select-Object CommandLine, Caption
		                                     $refObject = New-Object -TypeName psobject 
											 $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $row.ServerName
                                             $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "Process_JavaAppsOn_Interfaces"
											 $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value $row.service
                                             
															
										if ( $processDetais -ne $null ) {
											 $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Running"
											 $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Green"
										}
										else
										{
											$refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Stopped"
											$refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Failed: Service is in Stopped Status. Please check the service."
										}
						   
										$dataArrayToExport += $refObject
										$refObject = $null
						   
							        
                   #Closed of Java PRocess - Interfaces 
                    }
        
        
        
                    #Open of Interfaces
                    foreach ($row in $processInterfaceArray) {
                    
                    
                    
                                        $command = "CommandLine like '%" +  $row.service + "%'"
                            

									   $processDetais = Get-WmiObject Win32_Process -ComputerName $row.ServerName -Filter $command  | Select-Object CommandLine, Caption
		
                                             $refObject = New-Object -TypeName psobject 
											 $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $row.ServerName
                                             $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "Process_Interface"
											 $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value $row.service
															
										if ( $processDetais -ne $null ) {
											 
											 $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Running"
											 $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Green"
										}
										else
										{
											
                                            $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Stopped"
											$refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Failed: Service is in Stopped Status. Please check the service"
										}
						   
										$dataArrayToExport += $refObject
										$refObject = $null
						   
							        
                   #Closed of Interfaces 
                    }
        
        
        
                   #Open Service 
                   foreach  ($row in $serviceArray){
                   
                                    $Service = get-service -ComputerName $row.ServerName -Name $row.service
                                    
                                             $refObject = New-Object -TypeName psobject 
											 $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $row.ServerName
                                             $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "Service"
											 $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value $service.DisplayName
							                 $refObject | Add-Member -MemberType NoteProperty -Name Status -Value $Service.Status                                
                                    
                                    
                                    #check if a service is hung 
										if ($Service.status -eq "StopPending") 
										{ 
											$servicePID = (gwmi win32_Service | where { $_.Name -eq $srv}).ProcessID 
											# Stop-Process $ServicePID 
											#Start-Service -InputObject (get-Service -ComputerName $hostname -Name $srv) 
											$refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Failed: Service is in Stop-Pending Status. Please check the service."
										} 
										# check if a service is stopped 
										elseif ($Service.status -eq "Stopped") 
										{ 
												  
											$refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Failed: Service is in Stopped Status. Please check the service."
											#automatically restart the service. 
											# Start-Service -InputObject (get-Service -ComputerName $hostname -Name $srv) 
										} 
										
										elseif ($Service.status -eq "Running") 
										{ 
										
											$refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Green"
											#automatically restart the service. 
											# Start-Service -InputObject (get-Service -ComputerName $hostname -Name $srv) 
										}
									
                                        $dataArrayToExport += $refObject
										$refObject = $null
                   
                   #Closed of Interfaces 
                   }
        
        
        
                    #Check Database RM Flag
                    
                    try{
                    
                                $connection = new-object system.data.OleDb.OleDbConnection($connectionString);
                                
                                     foreach ($servername in $dbserviceArray){
                                
                                                    $ds = new-object "System.Data.DataSet"
                                                    $QuerySQL = "Select RMFLAGS , INETADDR from ICMSTResourceMgr where INETADDR ='" + $servername  + "'"
                                                    $da= new-object System.Data.OleDb.OleDbDataAdapter($QuerySQL,$connection)
                                                    $da.fill($ds)
                                                    [int] $rmflag =  $ds.tables[0].rows.RMFLAGS
                                                    
                                                     $refObject = New-Object -TypeName psobject 
                                                     $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $servername.service
                                                     $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "RMOfflineFlag"
                                                     
                                                     $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value "RMFlag Status"
                                                    
                                                    if ( $rmflag -eq 0 ) {
                                                                 
                                                        	      $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Running"
                                                                  $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Green"
                                                                  
                                                    }else{
                                                        		  $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Stopped"
                                                                  $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value ("Red - " + $row.service  + " Seems to be Offline")
                                                     }
                                                     $dataArrayToExport += $refObject
										             $refObject = $null                                           
                                
                                    }
                                
                                
                        }catch {
                        
                                                     $refObject = New-Object -TypeName psobject 
                                                     $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $dbhostname
                                                     $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "RMOfflineFlag"
                                                     
                                                     $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value "RMFlag Status"
                                                     $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Stopped"
                                                     $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value ("Red: + " + $_.Exception.Message) 
                                                     $dataArrayToExport += $refObject
										             $refObject = $null 
                        #Check Database RM Flag Closed
                        }
                                
                                
                                
        
        
        
                    #Open for URLMonitoring - Primary RM Server, Standby RM Server and MTR Email Servlet
                    
                    foreach ($row in $URLMonitoringArray){
                    
                          try{
                                     $HTTP_Request = [System.Net.WebRequest]::Create($row.service)
                                                
                                      # Get a response from the site.
                                      $HTTP_Response = $HTTP_Request.GetResponse()
                                      # We then get the HTTP code as an integer.
                                      $HTTP_Status = [int]$HTTP_Response.StatusCode
                                      
                                                     $refObject = New-Object -TypeName psobject 
                                                     $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $row.ServerName
                                                     $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "URLMonitoring"
                                                     $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value $row.service
                                                     
                                      If ( ($HTTP_Status -eq 200) -or ($HTTP_Status -eq 214)) {

                                                     $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Running"
                                                     $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Green"
                                      }
                                      else{
                                                     $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Stopped"
                                                     $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value "Red. Check the Web-Service or Server status"
                                      }
                    
                                      $dataArrayToExport += $refObject
								      $refObject = $null 
                                      # Finally, we clean up the http request by closing it.
                                      $HTTP_Response.Close()
                                      
                               }catch{
                                                     $refObject = New-Object -TypeName psobject 
                                                     $refObject | Add-Member -MemberType NoteProperty -Name MachineName -Value $row.ServerName
                                                     $refObject | Add-Member -MemberType NoteProperty -Name HealthCheckUpType -Value "URLMonitoring"
                                                     $refObject | Add-Member -MemberType NoteProperty -Name ServiceName -Value $row.service
                                                     $refObject | Add-Member -MemberType NoteProperty -Name Status -Value "Stopped"
                                                     $refObject | Add-Member -MemberType NoteProperty -Name Comment -Value ("Red. Check the Web-Service or Server status." + $_.Exception.Message) 
                                                     $dataArrayToExport += $refObject
								                     $refObject = $null 
                               }  
                    
                      #Closed for URLMonitoring - Primary RM Server, Standby RM Server and MTR Email Servlet
                    }
                    
   
   
    $date= Get-DAte -format "dd-MM-yyyy"
    $day = $date.substring(0,2)
    $month = $date.substring(3,2)
    $year = $date.substring(6,4)
   
   $path="d:\suresh\ECMHealthStatus_"  + $day + "_" + $month + "_" + $year +  ".csv"

   $dataArrayToExport | Export-csv -Path $path -NoTypeInformation
   
   
   #Copy File to Primary ECM DB Server
   
   $copycommand = ("d:\putty\pscp.exe -pw jrsyr00t " + $path +  " root@jsy-ecmcmsla02:/opt/logicalis/ecmhealth/")
   
   Invoke-Expression $copycommand
   
   #Execute Process command to verify java Process on Standby ECM AIX Server and create a new file
   
   
   $pscommand = "d:\putty\putty.exe -ssh root@jsy-ecmcmsla01 -pw itexr00t -m D:\suresh\ECMHealthPSScript\JSY-ECMCMSLA01JavaProcess.bat"
   
   Invoke-Expression $pscommand
   
   Start-Sleep -s 15
   
   
   $pscommand = "d:\putty\putty.exe -ssh root@jsy-ecmcmsla02 -pw jrsyr00t -m D:\suresh\ECMHealthPSScript\JSY-ECMCMSLA02ECMHealthScript.bat"
   
   Invoke-Expression $pscommand
   #Copy File to Primary ECM DB Server
   
   
   