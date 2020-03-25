<?php
include "db.php";
$files = get_imgs();
?>
<html>
	<head>
		<title>Subir Multiples Imagenes y/o Archivos - By Evilnapsis</title>
	</head>
	<body>
		<h1>Archivos</h1>
		<a href="./form.php">Agregar mas</a> - <a href="./images.php">Imagenes</a>
		<?php if(count($files)>0):?>
			<br><table border="1">
			<?php foreach($files as $f):?>
				<tr>
				<td><?php echo $f->folder;?></td>
				<td><?php echo $f->src;?></td>
				<td><a href="./download.php?id=<?php echo $f->id; ?>">Descargar</a></td>
				<td><a href="./delete.php?id=<?php echo $f->id; ?>">Eliminar</a></td>
				</tr>
			<?php endforeach;?>
			</table>
		<?php else:?>
			<h4>No hay imagenes!</h4>
		<?php endif; ?>

	</body>

</html>
