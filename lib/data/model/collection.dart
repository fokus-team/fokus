enum Collection { USER, PLAN, TASK, PLAN_INSTANCE, TASK_INSTANCE, CURRENCY, REWARD, BADGE }

extension CollectionName on Collection {
  String get name => const {
        Collection.USER: 'User',
        Collection.PLAN: 'Plan',
        Collection.TASK: 'Task',
        Collection.PLAN_INSTANCE: 'PlanInstance',
        Collection.TASK_INSTANCE: 'TaskInstance',
        Collection.CURRENCY: 'Currency',
        Collection.REWARD: 'Reward',
        Collection.BADGE: 'Badge'
      }[this];
}
