var doc = new jsPDF();
var specialElementHandlers = {
    '#editor': function (element, renderer) {
        return true;
    }
};

$('#btGerarPDF').click(function () {
    doc.fromHTML($('#conteudo').html(), 15, 15, {
        'width': 170,
            'elementHandlers': specialElementHandlers
    });
    doc.save('exemplo-pdf.pdf');
});