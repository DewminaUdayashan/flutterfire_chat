import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatty_chat/models/user_model.dart';
import 'package:chatty_chat/services/firestore_services.dart';
import 'package:equatable/equatable.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final FirestoreServices _firestoreServices;
  UsersCubit(this._firestoreServices) : super(UsersNotLoaded());

  late StreamSubscription _subscription;

  Future<void> loadUsers(String myId) async {
    final result = await _firestoreServices.getAllUsers(myId);

    result.open(
      (users) {
        if (users != null) {
          _subscription = users.listen((snapshot) {
            final List<UserModel> users = List<UserModel>.empty(growable: true);
            if (snapshot.docs.isNotEmpty) {
              for (var doc in snapshot.docs) {
                users.add(UserModel.fromMap(doc.data(), id: doc.id));
              }
            }
            emit(UsersLoaded(users));
          });
        }
      },
      (onError) => emit(
        UsersLoadingFailed(
          onError ?? Exception('Something went wrong!'),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
