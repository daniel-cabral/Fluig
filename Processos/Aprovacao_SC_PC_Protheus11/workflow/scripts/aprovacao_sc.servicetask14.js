function servicetask14(attempt, message) {
	
	var nomeAprovador = hAPI.getCardValue("C1_NOMAPRO");
	log.info('variavel nomeAprovador: ' + nomeAprovador)
	
	var i = 0;
	while(true) {
		var constraintColleague1 = DatasetFactory.createConstraint('mail', nomeAprovador, nomeAprovador, ConstraintType.MUST);
		var colunasColleague = new Array('colleaguePK.colleagueId', 'mail', 'active');
		var datasetColleague = DatasetFactory.getDataset('colleague', colunasColleague, new Array(constraintColleague1), new Array('colleaguePK.colleagueId', 'mail'));
	
		if(datasetColleague.rowsCount == 0) {
			if(i < 5) {
				i ++;
				log.info("Tentativa de buscar matricula " + i);
				sleep(1000);
				continue;
			}
			
			throw "Falha ao atribuir aprovador!";
		}
	
		var matAprov = datasetColleague.getValue(0, "colleaguePK.colleagueId");
		break;
	}
	log.info('matricula do aprovador: ' + matAprov);
	hAPI.setCardValue('C1_MATAPRO',matAprov) ;
	
		
}