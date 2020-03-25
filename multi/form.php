<html>
	<head>
		<title>Subir Multiples Imagenes y/o Archivos - By Evilnapsis</title>
	</head>
	<body>
		<h1>Subir imagenes o archivos</h1>
		<form enctype="multipart/form-data" method="post" action="upload.php">
		<input name="image[]" required="" type="file" multiple />
		<br>
		<input type="submit" value="Upload">
		</form>
	</body>

</html>
