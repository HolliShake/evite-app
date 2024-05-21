

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OrganizersEvent {}

class OrganizerInitialize extends OrganizersEvent {
  final List<dynamic> value; 
  OrganizerInitialize(this.value);
}

class OrganizerBloc extends Bloc<OrganizersEvent, List> {
  OrganizerBloc():super(<dynamic>[]) {
    on<OrganizerInitialize>((event, emit) => emit(event.value));
  }
}

