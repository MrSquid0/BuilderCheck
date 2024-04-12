import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      // Hardcoded login logic
      if (event.email == 'gonzalo' && event.password == 'tfg') {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(error: 'Invalid username or password'));
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }
  }
}