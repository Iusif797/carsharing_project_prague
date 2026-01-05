# Firebase Setup Instructions

## 🔥 Настройка Firebase для Prague Carsharing

### Шаг 1: Создайте проект Firebase

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Нажмите "Add project" (Добавить проект)
3. Введите название: `prague-carsharing`
4. Отключите Google Analytics (можно включить позже)
5. Нажмите "Create project"

### Шаг 2: Добавьте iOS приложение

1. В Firebase Console выберите ваш проект
2. Нажмите на иконку iOS
3. Введите Bundle ID: `com.yusif.prague` (или ваш из Xcode)
4. Скачайте файл `GoogleService-Info.plist`
5. Добавьте файл в Xcode:
   - Откройте `Runner.xcworkspace` в Xcode
   - Перетащите `GoogleService-Info.plist` в папку `Runner`
   - Убедитесь, что Target выбран "Runner"

### Шаг 3: Включите Firestore Database

1. В Firebase Console → Build → Firestore Database
2. Нажмите "Create database"
3. Выберите режим: **Start in test mode** (для разработки)
4. Выберите регион: `europe-west` (ближайший к Праге)
5. Нажмите "Enable"

### Шаг 4: Включите Authentication

1. В Firebase Console → Build → Authentication
2. Нажмите "Get started"
3. Выберите "Email/Password"
4. Включите "Email/Password"
5. Сохраните

### Шаг 5: Настройте правила безопасности Firestore

Перейдите в Firestore Database → Rules и вставьте:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    match /vehicles/{vehicleId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /bookings/{bookingId} {
      allow read: if request.auth != null &&
                    resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                       resource.data.userId == request.auth.uid;
    }

    match /trips/{tripId} {
      allow read: if request.auth != null &&
                    resource.data.userId == request.auth.uid;
      allow write: if request.auth != null &&
                      resource.data.userId == request.auth.uid;
    }

    match /reviews/{reviewId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Шаг 6: Обновите main.dart

Убедитесь, что Firebase инициализирован в `lib/main.dart`.

### Шаг 7: Запустите приложение

```bash
cd /Users/macbook/Desktop/carsharing_project_prague-main
flutter pub get
flutter run
```

## 📊 Структура базы данных

### Collections:

**users/** - Пользователи

- uid (string)
- email (string)
- name (string)
- phoneNumber (string)
- totalTrips (number)
- totalSpent (number)
- memberSince (timestamp)

**vehicles/** - Машины

- id (string)
- name (string)
- brand (string)
- model (string)
- city (string)
- latitude (number)
- longitude (number)
- status (string): available | booked | maintenance
- pricePerMinute (number)
- pricePerHour (number)
- pricePerDay (number)
- pricePerWeek (number)
- batteryLevel (number)
- rating (number)

**bookings/** - Бронирования

- userId (string)
- vehicleId (string)
- pricingPlan (string): minute | hourly | daily | weekly
- price (number)
- status (string): active | completed | cancelled
- startTime (timestamp)
- endTime (timestamp)

**trips/** - История поездок

- userId (string)
- vehicleId (string)
- startTime (timestamp)
- endTime (timestamp)
- distance (number)
- cost (number)

**reviews/** - Отзывы

- userId (string)
- vehicleId (string)
- rating (number)
- comment (string)
- createdAt (timestamp)

## ✅ Готово!

После выполнения всех шагов у вас будет полноценная база данных с:

- ✅ Аутентификацией пользователей
- ✅ Реалтайм обновлением машин
- ✅ Системой бронирования
- ✅ Историей поездок
- ✅ Отзывами и рейтингами

Данные будут сохраняться в облаке и синхронизироваться между устройствами!
