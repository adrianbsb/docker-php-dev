<?php

if( isset($_GET['phpinfo']) and $_GET['phpinfo'] ) {
	phpinfo(); 
	exit;
}

$sshPublicKey = ( $k = @file_get_contents('/var/local/id_rsa.pub') ) ? $k : NULL;
$boxType 	  = ( $e = getenv('PHP_BUILD_CONFIG') ) ? $e : 'default';

$nginxVersion = str_replace('nginx/', '', $_SERVER['SERVER_SOFTWARE']);
$phpVersion	  = phpversion();

?>
<html>
	<head>
		<title>Welcome</title>
		<link href="https://fonts.googleapis.com/css?family=Fira+Sans" rel="stylesheet">
		<style type="text/css">
			html, body{
				background: #fafafa;
				color: #000;
				font-family: "Fira Sans", "Georgia", Arial, Helvetica, sans-serif;
				text-align: left;
				font-size: 1.2em;
				font-weight: normal;
			}
			
			.details{
				background: #fdfdfd;
				width: 480px;
				height: auto;
				margin: 20px auto;
				padding: 15px 25px;
				box-shadow: 2px 2px 8px rgba(0, 0, 0, .2);
				border-radius: 4px;
			}
			
			pre{
			    word-wrap: break-word;
				white-space: pre-wrap;
			    overflow: auto;
			    padding: 10px;
			    border: 1px solid #e3e3e3;
			    border-radius: 5px;
			    background: #f4f4f4;
			    height: auto;
			    box-shadow: inset 0px 0px 11px rgba(0, 0, 0, 0.3);
			}
		</style>
	</head>
	<body>
	
			
		<div class="details">
			<h1>&#x1F354; Welcome!</h2>
			<h3>Your <?php echo $boxType; ?> box is running</h4>
			<p>
				<span style="color:green;">&#x25C9;</span>
				Nginx v<?php echo $nginxVersion; ?>
			</p>
			<p>
				<span style="color:green;">&#x25C9;</span>
				PHP v<?php echo $phpVersion; ?>	
			</p>
			
			<?php if ( $sshPublicKey ): ?>
				<h4>SSH Public Key</h4>
			
				<pre><?php echo $sshPublicKey; ?></pre>
			<?php else: ?>
				<p>
					&#x2716; Could not retrieve ssh public key! 
					If you want to run a customized version with a key pair, 
					please customize your base image using template 
					<a href="https://github.com/adrian7/docker-nginx-fpm/blob/master/custom/example/Dockerfile" target="_blank">
						here
					</a>.
				</p>
				<p style="color: #E73A38;">
					<em>
						&#x26A0; Note that, images with a key pair should not be pushed 
						to public repositories.
					</em>
				</p>
			<?php endif; ?>
			
			<p>&nbsp;</p>
			<p style="font-size: .7em; text-align: center;">
				<a href="?phpinfo=1">PHP Info</a> | 
				<a href="https://github.com/adrian7/docker-nginx-fpm" target="_blank">Image repository</a> | 
				<a href="https://store.docker.com/images/php" target="_blank">PHP image repository</a> | 
				<a href="https://www.docker.com" target="_blank">Docker</a>
			</p>	
		</div>		
		
	</body>
</html>