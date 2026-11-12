# Орлого, зарлагын бүртгэл (Flutter)

Хувь хүний орлого, зарлагыг хянах апп — Figma загварын дагуу.

## Дэлгэцүүд

| # | Дэлгэц | Файл |
|---|--------|------|
| 1 | Splash ("Сайн уу?") | `lib/views/screens/splash_screen.dart` |
| 2 | Onboarding ("Ухаалаг зарцуулж илүү хэмнэе") | `lib/views/screens/onboarding_screen.dart` |
| 3 | Бүртгүүлэх | `lib/views/screens/register_screen.dart` |
| 4 | Нэвтрэх | `lib/views/screens/login_screen.dart` |
| 5 | Нүүр (үлдэгдэл, гүйлгээний түүх) | `lib/views/screens/home_screen.dart` |

Урсгал: Splash (2 сек) → Onboarding → «Эхлэх» → Бүртгүүлэх ↔ Нэвтрэх → Нүүр.
Нүүр дэлгэцийн үлдэгдэл, орлого, зарлагыг гүйлгээнүүдээс тооцоолно (`TransactionViewModel`).
Бүртгэл, нэвтрэх хэсэг талбаруудыг шалгана (хоосон, имэйл формат, нууц үг ≥ 6, давтан нууц үг таарах).

Дэлгэцийн зургууд: `submission/`.

## Архитектур: MVVM + Provider

```
lib/
├── main.dart                 → MultiProvider (ViewModel-уудыг үүсгэнэ), routes
├── core/                     → theme (өнгө, фонт), validators, formatters
├── models/                   → Model: өгөгдөл (User, Transaction)
├── services/                 → Өгөгдөл хадгалах (AuthService, TransactionService; одоо санах ойд)
├── viewmodels/               → ViewModel: төлөв + логик (AuthViewModel, TransactionViewModel)
└── views/
    ├── screens/              → View: зөвхөн UI (Splash, Onboarding, Register, Login, Home)
    └── widgets/              → Дахин ашиглагдах UI хэсгүүд
```

- **View** товч дарахад `context.read<AuthViewModel>().login(...)` дуудна.
- **ViewModel** логикоо гүйцэтгээд `notifyListeners()` дуудна.
- **View** `context.select / watch`-аар өөрчлөлтийг сонсож дахин зурна (жишээ нь ачаалж буй spinner).
- **Service** нь interface тул дараа нь өгөгдлийн сан (sqflite, Firebase) руу дэлгэц өөрчлөхгүйгээр шилжиж болно.

## Ажиллуулах

```bash
flutter pub get
flutter run          # Android утас / emulator эсвэл Linux desktop
flutter test
```

Фонт: Inter, Poppins (SIL Open Font License — `assets/fonts/OFL-*.txt`).
