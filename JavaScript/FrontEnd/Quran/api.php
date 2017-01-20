<?php
header("content-type: text/html; charset=utf-8");
$connection = mysqli_connect("localhost", "root", "1234", "quran");
mysqli_query($connection,"SET NAMES utf8;") or die("Query fail: " . mysqli_error());

function utf8ize($d)
{
    if (is_array($d)) {
        foreach ($d as $k => $v) {
            $d[$k] = utf8ize($v);
        }
    } else if (is_string($d)) {
        return utf8_encode($d);
    }
    return $d;
}


function getAyahSimilarity($surahNumber,$ayahNumber,$sentence1Percentage,$sentence2Percentage,$connectedness1,$connectedness2,$orderness)
{
	global $connection;		
	$query = "CALL getAyahSimilarity(".$surahNumber.",".$ayahNumber.",".$sentence1Percentage.",".$sentence2Percentage.",".$connectedness1.",".$connectedness2.",".$orderness.")";
	$result = mysqli_query($connection, $query) or die("Query fail: " . mysqli_error($connection));	
  	
  	while ($row = mysqli_fetch_array($result))
  	{     	
  		$ayahs[] = array("SurahName" => $row[0], "AyahNoWithinSurah" => $row[1], "Ayah" => $row[2]);
  	}
  	if (empty($ayahs))
	{
    	$ayahs[] = array("status" => "[ERR:2002] - No More Results.");
	} 		
  $ayahs = array("ayahs" => $ayahs);
  return $ayahs; 
}
$possible_url = array("help"=> "Displays available actions",
					  "getAyahSimilarity" => "Displays similiar ayahs; SurahName, AyahNoWithinSurah, Ayah. It takes 7 parameters <b>surah_number(int)</b>, <b>ayah_number(int)</b>,<b>sentence1_percentage(int)</b>, <b>sentence2_percentage(int)</b>,<b>connectedness1(int)</b>, <b>Connectedness2(int)</b> and <b>orderness(int)</b>");

$value = array("status" =>"[ERR:999] - Missing (or) Wrong action");

$action =  addslashes(($_GET["action"]));

if($action == '')
{
	$action = addslashes(($_POST["action"]));
}

if ((isset($_GET["action"])||isset($_POST["action"])) && array_key_exists($action, $possible_url))
{
	
  switch ($action)
    {
		case "getAyahSimilarity":
			if (isset($_GET["surah_number"]) && isset($_GET["ayah_number"]))
			{
				$surahNumber = $_GET["surah_number"];
				$ayahNumber = $_GET["ayah_number"];
				$sentence1Percentage = $_GET["sentence1_percentage"];
				$sentence2Percentage = $_GET["sentence2_percentage"];
				$connectedness1 = $_GET["connectedness1"];
				$connectedness2 = $_GET["connectedness2"];
				$orderness = $_GET["orderness"];
				$value = getAyahSimilarity($surahNumber,$ayahNumber,$sentence1Percentage,$sentence2Percentage,$connectedness1,$connectedness2,$orderness);							
			}
			else
			{
				$value =  array("status" =>"[ERR:1000] - Argument is missing");
			}
			break;	
		case "help":
		 
		 	$counter = 1;
		 	
		 	$html = "<html><head></head><body>" ; 
		 	$html .= "<H1>Available Actions</H1><br/><table border='1' cellspacing='4' cellpadding='4'><tr><th></th><th>Action</th> <th>Description</th></tr>";
		 	
		 	foreach($possible_url as $k=>$v)
		 	{
		 		$html .= "<tr><td>" . $counter . "</td><td>" . $k. "</td><td>" . $v . "</td></tr>";
		 		
		 		$counter++;
			}
			
		 	$html .= "</table></body></html>";
			
			header('content-type: text/html; charset=utf-8');
			//return HTML array
			exit($html);
			break;
    }
}

header('content-type: application/json; charset=utf-8');
//return JSON array
exit(json_encode(($value) , JSON_UNESCAPED_UNICODE));
?>