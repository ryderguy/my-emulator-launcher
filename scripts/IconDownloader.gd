extends Node
class_name IconDownloader

signal progress(text: String)
signal finished

# Downloads system["icon_url"] -> res://art/<short_name>.png for every system
# that has a URL set and doesn't already have a local file.
func download_all(systems: Array) -> void:
	for system in systems:
		var url: String = system.get("icon_url", "")
		if url == "":
			continue

		var short_name: String = system.get("short_name", "unknown")
		var dest := "res://art/%s.png" % short_name

		if FileAccess.file_exists(dest):
			progress.emit("Skipping %s (already have it)" % system["name"])
			continue

		progress.emit("Downloading %s..." % system["name"])

		var http := HTTPRequest.new()
		add_child(http)
		var err := http.request(url)
		if err != OK:
			progress.emit("Could not start download for %s (error %d)" % [system["name"], err])
			http.queue_free()
			continue

		var result: Array = await http.request_completed
		var response_code: int = result[1]
		var body: PackedByteArray = result[3]

		if response_code == 200 and body.size() > 0:
			var f := FileAccess.open(dest, FileAccess.WRITE)
			f.store_buffer(body)
			f.close()
			progress.emit("Saved %s.png" % short_name)
		else:
			progress.emit("Failed (HTTP %d) for %s" % [response_code, system["name"]])

		http.queue_free()

	finished.emit()
