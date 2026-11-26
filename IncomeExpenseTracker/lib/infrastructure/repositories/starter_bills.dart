import '../../domain/domain.dart';

/// Bills every new account starts with, due over the next few weeks.
/// Used by the in-memory seed and by the Firebase adapter on registration.
List<Bill> starterBills(DateTime now) {
  DateTime inDays(int d) => DateTime(now.year, now.month, now.day + d);
  return [
    Bill(
      id: 'bill-youtube',
      title: 'Youtube Premium',
      amount: 11.99,
      fee: 1.99,
      dueDate: inDays(3),
      iconAsset: 'assets/images/bills/youtube.png',
      iconSize: 35,
    ),
    Bill(
      id: 'bill-electricity',
      title: 'Цахилгаан',
      amount: 45,
      fee: 0.5,
      dueDate: inDays(10),
      iconAsset: 'assets/svg/wallet/lightning.svg',
      iconSize: 28,
    ),
    Bill(
      id: 'bill-rent',
      title: 'Байрны түрээс',
      amount: 600,
      dueDate: inDays(13),
      iconAsset: 'assets/svg/wallet/house.svg',
      iconSize: 30,
    ),
    Bill(
      id: 'bill-spotify',
      title: 'Spotify',
      amount: 9.99,
      fee: 0.99,
      dueDate: inDays(17),
      iconAsset: 'assets/images/bills/spotify.png',
      iconSize: 30,
    ),
  ];
}
