import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/cards/job_queue_worker_pool_stat_card.dart';

class JobQueueWorkerPoolDetails extends StatelessWidget {
  final Map<String, dynamic> workerPoolStats;

  const JobQueueWorkerPoolDetails({super.key, required this.workerPoolStats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        JobQueueWorkerPoolStatCard(
          title: 'Active Count',
          value: workerPoolStats['activeCount']?.toString() ?? '0',
        ),
        JobQueueWorkerPoolStatCard(
          title: 'Pool Size',
          value: workerPoolStats['poolSize']?.toString() ?? '0',
        ),
        JobQueueWorkerPoolStatCard(
          title: 'Core Pool Size',
          value: workerPoolStats['corePoolSize']?.toString() ?? '0',
        ),
        JobQueueWorkerPoolStatCard(
          title: 'Max Pool Size',
          value: workerPoolStats['maximumPoolSize']?.toString() ?? '0',
        ),
        JobQueueWorkerPoolStatCard(
          title: 'Queue Size',
          value: workerPoolStats['queueSize']?.toString() ?? '0',
        ),
        JobQueueWorkerPoolStatCard(
          title: 'Completed Tasks',
          value: workerPoolStats['completedTaskCount']?.toString() ?? '0',
        ),
      ],
    );
  }
}
