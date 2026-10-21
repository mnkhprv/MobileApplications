# Deutsch Flashcards — Leitner систем бүхий үг цээжлэх апп

Quizlet-тэй төстэй, 100% Jetpack Compose дээр бичсэн Android апп. Герман үг (term) → монгол орчуулга (definition).
Анх нээхэд 3 жишээ багц (Grundwortschatz, Verben, Begrüßungen) автоматаар үүснэ.

## Ажиллуулах
1. Android Studio → **Open** → `FlashcardApp` хавтсыг сонгоно.
2. Gradle sync дуусахыг хүлээнэ (Lab1-тэй ижил: Gradle 9.6, AGP 9.4.1, compileSdk 37).
3. Эмулятор эсвэл утсаа сонгоод ▶ Run.

Технологи: Kotlin 2.3 (AGP built-in), Compose BOM 2024.12, Material 3, Navigation Compose 2.8, Room 2.7 (KSP), ViewModel + StateFlow.

## Бүтэц
```
data/
  Entities.kt            Deck, Card (Room entity), DeckSummary, CardDraft
  Daos.kt                DeckDao, CardDao (SQL, Flow)
  FlashcardDatabase.kt   Room DB + жишээ герман багцууд
  FlashcardRepository.kt UI-д зориулсан цорын ганц өгөгдлийн цэг
  Leitner.kt             Leitner логик, CardStatus, DeckStats
  PronunciationService.kt Герман дуудлага (Android TextToSpeech, Locale.GERMAN)
ui/
  navigation/            Routes + NavHost (слайд анимацтай шилжилт)
  decks/                 Багцын жагсаалт, дэлгэрэнгүй (stats), үүсгэх/засах
  cards/                 Карт засварлагч
  study/                 Flashcards горим, Learn горим, хураангуй
  components/, theme/    Нийтлэг composable, өнгө
AppViewModelProvider.kt  ViewModel factory (repository + SavedStateHandle)
```
UI логик (Screen) ба өгөгдлийн логик (ViewModel → Repository → DAO) салангид.

## Архитектур (MVVM)
```
Composable Screen  ──event (onClick, speak)──▶  ViewModel  ──▶  FlashcardRepository ──▶ Room DAO ──▶ SQLite
        ▲                                          │       └─▶  PronunciationService ──▶ TextToSpeech
        └──────── StateFlow (uiState, speechStatus) ┘
```
- **Screen** зөвхөн төлөв харуулж, үйлдлийг ViewModel руу дамжуулна. Android API-г шууд дууддаггүй.
- **ViewModel** дэлгэцийн төлөвийг (`StateFlow`) барина, Leitner дүрэм болон дуудлагыг дуудна.
- **FlashcardRepository / PronunciationService** нь `FlashcardApplication` дотор нэг удаа үүсч,
  `AppViewModelProvider`-оор ViewModel-уудад дамжина (гар DI).

## Герман дуудлага (аудио)
- Android-ийн суурилагдсан **TextToSpeech** (`Locale.GERMAN`): үнэгүй, нэмэлт сан хэрэггүй, хоолой татсан бол интернетгүй ажиллана.
- 🔊 товч: Flashcards (картын нүүр), Learn, багцын картын жагсаалт, карт засварлагч (бичсэн үгээ сонсох).
- 🐢 **Удаан** товч: 0.5x хурдаар дуудна.
- Flashcards/Learn-д шинэ карт гарахад автоматаар дуудна (Flashcards дээд талын "Авто 🔊" switch-ээр унтраана).
  Энэ логик `SessionViewModel` дотор: одоогийн карт, TTS төлөв, авто тохиргоог `combine` хийж дуудна.
- Дэлгэцээс гарахад `ViewModel.onCleared()` → `pronunciation.stop()`.
- Герман хоолой суулгаагүй бол апп анхааруулга харуулна: *Settings → Text-to-speech → Google TTS → Deutsch* татна.
  Эмулятор дээр Google Play-тэй image ашиглавал хялбар.

## Дэлгэцүүд ба шаардлага
| Шаардлага | Хаана |
|---|---|
| Багцын жагсаалт: LazyColumn, нэр, картын тоо, сүүлд суралцсан, эзэмшлийн %, FAB, empty state | `DeckListScreen` |
| Багц үүсгэх/засах/устгах, карт нэмэх/хасах, нэр хоосон бол алдаа, устгахын өмнө dialog | `DeckEditScreen`, `DeckEditViewModel` |
| Карт засварлагч: term/definition TextField, нэмэх/засах/устгах, хоосон бол хадгалахгүй | `CardEditScreen` |
| Flashcards: тогшиход 3D flip анимац, I knew / To review, 3 / 20 явц, төгсгөлийн хураангуй | `FlashcardsScreen` |
| Learn: term харуулж, орчуулгыг бичүүлнэ; том/жижиг үсэг, зай үл тооно; зөв/буруу feedback | `LearnScreen`, `Leitner.isAnswerCorrect` |
| Basic stats: mastered / learning / to review, Leitner хайрцаг бүрийн тоо, шууд шинэчлэгдэнэ | `DeckDetailScreen` (Room Flow) |
| Хадгалалт: box, needsReview, lastReviewed, lastStudied бүгд Room-д | `Card`, `Deck` |

## Leitner систем (Зураг 2)
- 5 хайрцаг. Шинэ карт → **1-р хайрцаг**.
- **I knew** / Learn-д зөв → дараагийн хайрцаг (`box + 1`, дээд хязгаар 5), needsReview арилна.
- **To review** / Learn-д буруу → **1-р хайрцаг**, `needsReview = true`.
- **5-р хайрцаг = mastered.**
- Давтах завсар: 1-р хайрцаг — суралцах бүрд, 2 — 1 өдөр, 3 — 3 өдөр, 4 — 7 өдөр, 5 — 14 өдөр.
  Карт `isDue` бол (needsReview, хэзээ ч давтаагүй, эсвэл завсар өнгөрсөн) сурах хэсэгт орно.
- Дараалал: **needsReview эхэнд → бага дугаартай хайрцаг → удаан давтаагүй нь** (`Leitner.studyOrder`).
  Тиймээс мэдэхгүй карт ойр ойрхон, сайн мэддэг карт ховор гарна.
- Давтах карт байхгүй бол "Бүх картыг үзэх", хураангуйд "Давтах картуудаа дахин үзэх" сонголттой.

Логикийн unit test: `app/src/test/.../LeitnerTest.kt` (Android Studio-д баруун товч → Run).

## Даалгаврын баримттай тулгалт (үнэлгээний шалгуур)
| # | Шалгуур (оноо) | Төлөв | Хаана / тайлбар |
|---|---|---|---|
| 1 | Багцын жагсаалт, CRUD (5) | ✅ | LazyColumn: нэр, картын тоо, сүүлд суралцсан, эзэмшсэн/давтах. FAB, empty state, нэр хоосон бол алдаа, устгах dialog |
| 2 | Картын CRUD, Card editor (3) | ✅ | Хоёр TextField, нэмэх/засах/устгах, хоосон term/definition хадгалахгүй |
| 3 | Flashcards горим (4) | ✅ | Flip анимац, I knew / To review, "3 / 20" явц, хураангуй |
| 4 | Learn горим (4) | ✅ | Term → орчуулга бичих, case/зай үл тооно, feedback + зөв хариулт, буруу бол needs review |
| 5 | Leitner (5) | ✅ | 5 хайрцаг, зөв → +1, буруу → 1 + needs review, дараалал/давтамж `Leitner.kt`, unit test |
| 6 | Basic stats (2) | ✅ | Жагсаалт + дэлгэрэнгүйд mastered / to review, Room Flow-оор шууд шинэчлэгдэнэ |
| 7 | Өгөгдөл, ахиц хадгалалт (2) | ✅ | Room: Deck(lastStudied), Card(box, needsReview, lastReviewed) |
| 8 | Compose, UI/UX, навигац (5) | ✅ | 100% Compose + Material 3, XML layout/Fragment байхгүй, Navigation Compose |

Даалгавраас илүү хийсэн: герман дуудлага (TTS, удаан горим, авто дуудлага), хайлт, Leitner хайрцгийн тоо, жишээ багцууд, "Давтах картуудаа дахин үзэх".
Анхаарах: Leitner-ийн дагуу 2+ хайрцгийн карт завсар нь өнгөрөөгүй бол тухайн өдөр гарахгүй. Энэ нь зөв ажиллагаа. Хамгаалалт дээр "Бүх картыг үзэх" товчоор бүгдийг харуулж болно.

## Хамгаалалтад гарч болох асуултууд
- **Recomposition хэрхэн явагддаг вэ?** ViewModel-ийн `StateFlow`/`mutableStateOf` өөрчлөгдөхөд түүнийг уншдаг composable л дахин зурагдана.
- **Яагаад ViewModel?** Дэлгэц эргэхэд (configuration change) төлөв алдагдахгүй, UI-аас логикийг салгана.
- **Статистик яаж шууд шинэчлэгддэг вэ?** DAO нь `Flow` буцаадаг тул картын хүснэгт өөрчлөгдөх бүрт Room шинэ утга илгээнэ.
- **Навигацад өгөгдөл яаж дамжуулдаг вэ?** Route-д `deckId` аргумент (`deck/{deckId}`), ViewModel үүнийг `SavedStateHandle`-ээс уншина.
- **Flip анимац?** `animateFloatAsState`-ээр 0°→180° `rotationY`; 90°-аас хойш ар талыг харуулж, текстийг толин тусгал болохгүйн тулд дахин 180° эргүүлнэ.
- **Багц устахад картууд?** `ForeignKey(onDelete = CASCADE)`.
- **Дуудлага яагаад ViewModel-оор дамждаг вэ?** UI-г Android TTS-ээс салгаж, авто дуудлагын логикийг тест хийх боломжтой, дэлгэц эргэхэд дахин эхлэхгүй болгоно.
