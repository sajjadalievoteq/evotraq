import 'package:equatable/equatable.dart';

import '../../../data/services/dashboard_service.dart';


abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<RecentEvent> recentEvents;
  final SystemHealthStatus healthStatus;
  final String? ownerEmail;

  const DashboardLoaded({
    required this.stats,
    required this.recentEvents,
    required this.healthStatus,
    this.ownerEmail,
  });

  @override
  List<Object?> get props => [stats, recentEvents, healthStatus, ownerEmail];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
