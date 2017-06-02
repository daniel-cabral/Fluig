function servicetask9(attempt, message) {
			
		var nomeAprovador = hAPI.getCardValue("APROVADOR");
		log.info('variavel nomeAprovador: ' + nomeAprovador)
		
	var constraintColleague1 = DatasetFactory.createConstraint('mail', nomeAprovador, nomeAprovador, ConstraintType.MUST);
	var colunasColleague = new Array('colleaguePK.colleagueId', 'mail', 'active');
	var datasetColleague = DatasetFactory.getDataset('colleague', colunasColleague, new Array(constraintColleague1), new Array('colleaguePK.colleagueId', 'mail'));
		
		log.info(datasetColleague.getValue(0, "colleaguePK.colleagueId"))
		hAPI.setCardValue('MATAPROVADOR',datasetColleague.getValue(0, "colleaguePK.colleagueId")) ;
		
			
	
}