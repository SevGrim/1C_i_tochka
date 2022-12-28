$НаборПроцессов = Get-CimInstance -ClassName Win32_Process  -Filter 'name = "kdiff3.exe"' | Select-Object -Property ProcessId, CommandLine 
ForEach ($ТекСтрока in $НаборПроцессов){
    $ИдентификаторЗависшегоПроцесса = $ТекСтрока.ProcessId;
	$КоманднаяСтрокаЗапущенногоПроцесса = $ТекСтрока.CommandLine.Replace(".exe"" ","☺").Split("☺");
	$ПутьКПрограмме = $КоманднаяСтрокаЗапущенногоПроцесса[0].Insert($КоманднаяСтрокаЗапущенногоПроцесса[0].Length,".exe""");
	$ПараметрыЗапуска = [string]::Concat("'",$КоманднаяСтрокаЗапущенногоПроцесса[1],"'");
	$ДублирующийПроцесс = Start-Process -FilePath $ПутьКПрограмме -ArgumentList $КоманднаяСтрокаЗапущенногоПроцесса[1] -PassThru;
	$ИдентификаторДублирующегоПроцесса = $ДублирующийПроцесс.ID;
	Start-Sleep -Seconds 3;
	Stop-Process $ИдентификаторЗависшегоПроцесса;
	Start-Sleep -Seconds 3
	Stop-Process $ИдентификаторДублирующегоПроцесса;	
}