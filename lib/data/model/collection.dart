enum Collection { user, plan, task, planInstance, taskInstance, currency, reward, badge }

extension CollectionName on Collection {
  String get name => const {
        Collection.user: 'User',
        Collection.plan: 'Plan',
        Collection.task: 'Task',
        Collection.planInstance: 'PlanInstance',
        Collection.taskInstance: 'TaskInstance',
        Collection.currency: 'Currency',
        Collection.reward: 'Reward',
        Collection.badge: 'Badge'
      }[this];
}
