enum DBTable {
	USER, PLAN, TASK, PLAN_INSTANCE, TASK_INSTANCE, CURRENCY, REWARD, BADGE
}

extension DBTableName on DBTable {
	String get name => const {
		DBTable.USER: 'User',
		DBTable.PLAN: 'Plan',
		DBTable.TASK: 'Task',
		DBTable.PLAN_INSTANCE: 'PlanInstance',
		DBTable.TASK_INSTANCE: 'TaskInstance',
		DBTable.CURRENCY: 'Currency',
		DBTable.REWARD: 'Reward',
		DBTable.BADGE: 'Badge'
	}[this];
}
