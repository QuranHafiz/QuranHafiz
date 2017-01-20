var current_page = 1;

var aya = -1;
var sura = -1;
//var api_url = 'localhost:8050/quran/api2.php?action=';
var api_url = 'http://128.208.244.180:8050/quran/api2.php?action=';

function load_suras() {
    p = $.ajax({
      url: "json/suras.json",
      dataType: 'json'
    });

    p.done(function(data) {
        str = '';
        for (var i=0; i < data.length ; i++) {
            sura = data[i];
            str += '<tr id="sura_link_'+ sura.id +'">';
            str += '<td>' + (i+1) + '</td>';
            str += '<td> <a class="sura_link" href="" ';
            str += 'data-page="' + sura.page +'" >';
            str += sura.name + '</a></td>';
            str += '<td>' + sura.page + '</td>';
            str += '<td>' + sura.ayas + '</td>';
            str += '</tr>';
        } 
        $('#suras tbody').html(str);
    });
}


function sura_clicked(event) {
    event.preventDefault();
    event.stopPropagation();
    el = event.target;
    page = $(el).data('page');
    // console.log('Sura Clicked!' + page);
    load_page(page);
}

function load_page(page) {
    if (page < 1) page = 1;
    if (page > 604) page = 604;
    current_page = page;
    $("#page_num").html('صفحة:'+current_page);

    $page = $('#page');
    $page.html('');
    $taf = $('#tafseer');
    $taf.html('');

    if (page<10) {
        page_str = '00'+page;
    } else if (page<100) {
        page_str = '0'+page;
    } else {
        page_str = ''+page;
    }
    $page.css('background-image', 'url(img/'+page_str+'.jpg)');

    // aya segments
    p = $.ajax({
      url: "json/page_" +page+".json",
      dataType: 'json'
    });

    p.fail(function(data) {
        console.log('Failed to load page map!');
    });

    p.done(function(data) {
        // Clear selected
        $('#suras tr').removeClass('active');
        for (var i=0; i < data.length ; i++) {
            aya = data[i];
            // console.log('Sura:' + aya.sura_id+' Aya:'+aya.aya_id);
            // Activate Sura 
            $('#sura_link_'+aya.sura_id).addClass('active');

            $a = $('<a>')
            $a.attr('href', '#'+aya.aya_id);
            $a.data('sura', aya.sura_id);
            $a.data('aya', aya.aya_id);
            $a.addClass('aya_link');
            for (var j=0; j < aya.segs.length ; j++) {
                seg = aya.segs[j];
                if (seg.w !=0 && seg.w < 15) continue;
                if (seg.x < 15) {
                    seg.w += seg.x;
                    seg.x = 0;
                }
                $d = $('<div>')
                .css('top', seg.y+'px')
                .css('left', seg.x+'px')
                .css('width', seg.w+'px')
                .css('height', seg.h+'px');
                $a.append($d);
                // console.log('Segment:'+aya.sura_id+' Aya '+aya.aya_id);
            }
            $page.append($a);
        } 
    });

}

function aya_clicked(event) {
    event.preventDefault();
    event.stopPropagation();
    el = $(event.target).closest('a');
    sura = el.data('sura');
    aya = el.data('aya');
    $('a.aya_link').removeClass('active');
    el.addClass('active');
    console.log('Aya Clicked!' + sura + ' ' + aya);	
	if (sura !=-1 && aya != -1)  load_aya(sura, aya);
}

function load_aya(sura, aya) {
    var tafseer_name = Array('المتشابهات');
    $taf = $('#tafseer');

	var sent1 = $("#sent1_output").val(); 
	var sent2 =  $("#sent2_output").val();
	var connect1 = $("#connect1_output").val();
	var connect2 = $("#connect2_output").val();
	var orderness =  $("#orderness_output").val();
	var lol = api_url+'getAyahSimilarity&surah_number='+sura+'&ayah_number='+aya+'&sentence1_percentage='+sent1+'&sentence2_percentage='+sent2+'&connectedness1='+connect1+'&connectedness2='+connect2+'&orderness='+orderness;
	console.log(lol);
    $taf.html('');

	 p = $.ajax({
	  type: "GET",
		url: api_url+'getAyahSimilarity&surah_number='+sura+'&ayah_number='+aya+'&sentence1_percentage='+sent1+'&sentence2_percentage='+sent2+'&connectedness1='+connect1+'&connectedness2='+connect2+'&orderness='+orderness,
	  success: function (data)
	  {
		  var ayahs = data.ayahs;
		  var numberOfAyahs = ayahs.length;
		  console.log(data.ayahs.length);
		  if (numberOfAyahs == 1)
		  {
			  if (typeof ayahs[0].status != 'undefined' )
			  {
				  if (ayahs[0].status.indexOf("ERR:2002") > -1)
				  {
					  return;
				  }
			  }		  
		  }
		}})		      
	
    p.fail(function(data) {
        console.log('Failed to load Motshabhat!');
    });

	console.log("p"+p);
    p.done(function(data) {
		console.log (data.ayahs.length);
        str = '';
		taf = data[0];
		if ( data.ayahs.length == 1) return;
		for (var i = 0; i < data.ayahs.length; i++)
			{
			  var SurahName = data.ayahs[i].SurahName;
			  var AyahNoWithinSurah = data.ayahs[i].AyahNoWithinSurah;
			  var Ayah = data.ayahs[i].Ayah;
			  //console.log(SurahName + " ["+ AyahNoWithinSurah +"] Ayah: "+ Ayah );
			  str += SurahName + " ["+ AyahNoWithinSurah +"]"+ Ayah;
			  console.log(str);
			  str += "<br />";
			}

		
        $taf.html(str);
    });
}

function page_change(event) {
    event.preventDefault();
    event.stopPropagation();
    el = $(event.target);
    offset = el.data('offset');
    console.log('Offset:'+ offset);
    page =  parseInt(current_page) + offset;
    load_page(page);
}



$(function () {

	load_suras();
    load_page(1);
	$("#sent1_output").text($("#sent1_perc").val());
	$("#sent2_output").text($("#sent2_perc").val());
	$("#connect1_output").text($("#connect1").val());
	$("#connect2_output").text($("#connect2").val());
	$("#orderness_output").text($("#orderness").val());

        var $document = $(document);
        function valueSent1Output(element) {
            var value = element.value;
			$("#sent1_output").text(value);
        }
        function valueSent2Output(element) {
            var value = element.value;
			$("#sent2_output").text(value);
        }
        function valueConnect1Output(element) {
            var value = element.value;
			$("#connect1_output").text(value);
        }
        function valueConnect2Output(element) {
            var value = element.value;
			$("#connect2_output").text(value);
        }
		function valueOrdernessOutput(element) {
            var value = element.value;
			$("#orderness_output").text(value);
        }


		
        $document.on('input', '#sent1_perc' , function(e) {
			load_aya(sura, aya);
			valueSent1Output(e.target);
        });

        $document.on('input', '#sent2_perc' , function(e) {
			load_aya(sura, aya);
			valueSent2Output(e.target);
        });

        $document.on('input', '#connect1' , function(e) {
			load_aya(sura, aya);
			valueConnect1Output(e.target);
        });

        $document.on('input', '#connect2' , function(e) {
			load_aya(sura, aya);
			valueConnect2Output(e.target);
        });

        $document.on('input', '#orderness' , function(e) {
			load_aya(sura, aya);
			valueOrdernessOutput(e.target);
        });

	
	
    $(document).on('click', 'a.sura_link', sura_clicked);
    $(document).on('click', 'a.aya_link', aya_clicked);

    $('.page-change').click(page_change);

    // Hotkeys 
    //$(document).bind('keydown', 'right', function() { p = parseInt(current_page) -1; document.location='#?page='+ p; }  );
    //$(document).bind('keydown', 'left', function() { p = parseInt(current_page) +1; document.location='#?page='+ p; }  );
    $(document).bind('keydown', 'right', function() { p = parseInt(current_page) -1; load_page(p); }  );
    $(document).bind('keydown', 'left', function() { p = parseInt(current_page) +1; load_page(p); }  );



});
