extends Control
var path = ''
var tools_path = ""
var update_path
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Updating...")
	$status.text = "Downloading file..."
	$bar.value = 20
	$Downloader.download_file = (OS.get_executable_path().get_base_dir()+"/pmc/update.zip")
	print(OS.get_executable_path().get_base_dir()+"/pmc/update.zip")
	$Downloader.request(GlobalVariables.update_url)




	


func _on_downloader_request_completed(result, response_code, headers, body):
	print("Download complete")
	$bar.value = 50
	$status.text = "Extracting..."
	var reader = ZIPReader.new()
	reader.open(OS.get_executable_path().get_base_dir()+"/pmc/update.zip")
	var file = reader.read_file("MetalGearDesperadoModdingUtility.exe")
	var output = FileAccess.open(OS.get_executable_path().get_base_dir()+"/pmc/output.exe", FileAccess.WRITE)
	output.store_buffer(file)
	reader.close()
	output.close()
	$bar.value = 70
	$status.text = "Replacing EXE..."
	OS.execute(OS.get_executable_path().get_base_dir()+"/updater.bat", [])
	get_tree().quit()
