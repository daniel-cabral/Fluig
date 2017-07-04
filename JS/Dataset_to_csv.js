// Monta o 'corpo' do arquivo CSV
function geraCSV(objArray) {
    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
    var str = '';
	for (var i = 0; i < array.length; i++) {
        var line = '';
        for (var index in array[i]) {
            if (line != '') line += ','

            line += array[i][index];
        }

        str += line + '\r\n';
    }
	return str;
}

// Consulta o dataset e gera um link para download do arquivo CSV montado pela geraCSV
// Parametros
// el: Elemento (div) onde será apendado o link para download.
// txt: Texto do link para download
function exportCSV(el, txt){
    var ds = DatasetFactory.getDataset("colleague",null,null,null);

    var a         = document.createElement('a');
    a.href        = 'data:attachment/csv,' +  encodeURIComponent(geraCSV( ds.values ) );
    a.target      = '_blank';
    a.innerText   = txt;
    a.download    = 'meuDataset.csv';
    $( el ).append(a);

    return true;

}
