import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/data/datasources/dashboard_remote_datasource.dart';
import 'package:fundlink_app/data/models/dashboard_model.dart';

abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {}

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel dashboard;
  DashboardLoaded(this.dashboard);
}

class DashboardFailure extends DashboardState {
  final String message;
  DashboardFailure(this.message);
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDatasource _datasource = DashboardRemoteDatasource();

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>((event, emit) async {
      emit(DashboardLoading());
      try {
        final data = await _datasource.getDashboard();
        emit(DashboardLoaded(data));
      } catch (e) {
        emit(DashboardFailure(e.toString()));
      }
    });
  }
}
