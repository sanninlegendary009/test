<?php

if(isset($_GET["id"])){
	include "db.php";
	$img = get_img($_GET["id"]);
	if($img!=null){
		del($img->id);
		unlink($img->folder.$img->src);
		print "<h4>Eliminada Exitosamente!</h4>";
	print "<ul><li><a href='./form.php'>Agregar mas</a></li>";
	print "<li><a href='./images.php'>Ver imagenes</a></li>";
	print "<li><a href='./files.php'>Ver Archivos</a></li></ul>";


	}
}


?>