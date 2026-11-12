import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/services/auth_service.dart';
import 'package:income_expense_tracker/viewmodels/auth_viewmodel.dart';

void main() {
  late AuthViewModel vm;

  setUp(() => vm = AuthViewModel(InMemoryAuthService()));

  test('register then login signs the user in', () async {
    expect(await vm.register(fullName: 'Бат', email: 'bat@mail.mn', password: 'secret1'), isTrue);
    expect(vm.isLoggedIn, isFalse, reason: 'register alone does not log in');

    expect(await vm.login(email: 'BAT@mail.mn', password: 'secret1'), isTrue);
    expect(vm.currentUser?.fullName, 'Бат');
    expect(vm.errorMessage, isNull);
  });

  test('wrong password sets an error', () async {
    await vm.register(fullName: 'Бат', email: 'bat@mail.mn', password: 'secret1');
    expect(await vm.login(email: 'bat@mail.mn', password: 'wrong12'), isFalse);
    expect(vm.isLoggedIn, isFalse);
    expect(vm.errorMessage, 'Имэйл эсвэл нууц үг буруу байна');
  });

  test('duplicate email is rejected', () async {
    await vm.register(fullName: 'Бат', email: 'bat@mail.mn', password: 'secret1');
    expect(await vm.register(fullName: 'Болд', email: 'bat@mail.mn', password: 'secret2'), isFalse);
    expect(vm.errorMessage, 'Энэ имэйлээр бүртгэл үүссэн байна');
  });

  test('isLoading is true while a request runs', () async {
    final future = vm.login(email: 'x@mail.mn', password: 'secret1');
    expect(vm.isLoading, isTrue);
    await future;
    expect(vm.isLoading, isFalse);
  });
}
