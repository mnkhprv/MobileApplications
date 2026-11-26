import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/business/services/login_service.dart';
import 'package:income_expense_tracker/business/services/register_service.dart';
import 'package:income_expense_tracker/infrastructure/repositories/in_memory/in_memory_repos.dart';
import 'package:income_expense_tracker/presentation/viewmodels/auth_viewmodel.dart';

void main() {
  late AuthViewModel vm;

  late InMemoryAuthRepo auth;

  setUp(() {
    auth = InMemoryAuthRepo();
    vm = AuthViewModel(RegisterService(auth), LoginService(auth));
  });

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

  test('register checks name and password length before calling the backend', () async {
    expect(await vm.register(fullName: ' ', email: 'a@mail.mn', password: 'secret1'), isFalse);
    expect(vm.errorMessage, 'Нэрээ оруулна уу');
    expect(await vm.register(fullName: 'Бат', email: 'a@mail.mn', password: '123'), isFalse);
    expect(vm.errorMessage, 'Нууц үг хамгийн багадаа 6 тэмдэгт');
  });

  test('logout ends the session; a remembered session is picked up at start', () async {
    await vm.register(fullName: 'Бат', email: 'bat@mail.mn', password: 'secret1');
    await vm.login(email: 'bat@mail.mn', password: 'secret1');
    expect(AuthViewModel(RegisterService(auth), LoginService(auth)).isLoggedIn, isTrue);
    await vm.logout();
    expect(vm.isLoggedIn, isFalse);
    expect(auth.currentUser, isNull);
  });

  test('isLoading is true while a request runs', () async {
    final future = vm.login(email: 'x@mail.mn', password: 'secret1');
    expect(vm.isLoading, isTrue);
    await future;
    expect(vm.isLoading, isFalse);
  });
}
