import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart' show User, UserRoleEnum;
import 'package:modern_pos_mobile/app.dart';
import 'package:modern_pos_mobile/core/providers.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';

class _FakeAuthController extends AuthController {
  _FakeAuthController(this.session);

  final AuthSession? session;

  @override
  Future<AuthSession?> build() async => session;
}

void main() {
  testWidgets('shows the sign-in screen when there is no session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuthController(null)),
        ],
        child: const ModernPosApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cashier sign in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('renders the cashier shell for an authenticated session', (
    tester,
  ) async {
    final session = AuthSession(
      accessToken: 'access-token',
      user: User(
        id: '00000000-0000-4000-8000-000000000004',
        email: 'cashier@example.test',
        role: UserRoleEnum.CASHIER,
        outletIds: const ['00000000-0000-4000-8000-000000000002'],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuthController(session),
          ),
          apiHealthProvider.overrideWith((ref) async => 'ok'),
        ],
        child: const ModernPosApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Modern POS'), findsOneWidget);
    expect(find.text('Cashier shell'), findsOneWidget);
  });
}
