<?php
include "db.php";
$images = get_imgs();
?>
<html>
	<head>
		<title>Subir Multiples Imagenes y/o Archivos - By Evilnapsis</title>
	</head>
	<body>
		<h1>Imagenes</h1>
		<a href="./form.php">Agregar mas</a> - <a href="./files.php">Archivos</a>
		<?php if(count($images)>0):?>
			<ul>
			<?php foreach($images as $img):?>
				<li><img src="<?php echo $img->folder.$img->src; ?>" style="width:240px;">
				<br>
				<a href="Controlador/download.php?id=<?php echo $img->id; ?>">Descargar</a> 
				<a href="./delete.php?id=<?php echo $img->id; ?>">Eliminar</a>
				</li>
			<?php endforeach;?>
			</ul>
		<?php else:?>
			<h4>No hay imagenes!</h4>
		<?php endif; ?>

	</body>

</html>
