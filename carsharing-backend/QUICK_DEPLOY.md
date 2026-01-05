# 🚀 Быстрый деплой на Railway.app (5 минут!)

## Шаг 1: Подготовьте код для GitHub

```bash
cd /Users/macbook/Desktop/carsharing_project_prague-main/carsharing-backend

# Инициализируйте Git
git init
git add .
git commit -m "Backend ready for deployment"
```

## Шаг 2: Создайте репозиторий на GitHub

1. Перейдите на https://github.com/new
2. Название: `prague-carsharing-backend`
3. Описание: `Backend API for Prague Carsharing`
4. Выберите: **Private** (приватный репозиторий)
5. Нажмите "Create repository"

## Шаг 3: Загрузите код на GitHub

GitHub покажет команды, выполните их:

```bash
git remote add origin https://github.com/ВАШ_USERNAME/prague-carsharing-backend.git
git branch -M main
git push -u origin main
```

## Шаг 4: Деплой на Railway.app

1. **Создайте аккаунт:**

   - Перейдите на https://railway.app
   - Нажмите "Login" → "Login with GitHub"
   - Авторизуйтесь

2. **Создайте проект:**

   - Нажмите "New Project"
   - Выберите "Deploy from GitHub repo"
   - Найдите `prague-carsharing-backend`
   - Нажмите "Deploy Now"

3. **Добавьте базу данных:**

   - В вашем проекте нажмите "New"
   - Выберите "Database"
   - Выберите "Add PostgreSQL"
   - Railway автоматически создаст и подключит БД

4. **Настройте переменные окружения:**

   - Откройте ваш сервис (не PostgreSQL)
   - Перейдите в "Variables"
   - Добавьте:
     ```
     JWT_SECRET=prague-carsharing-production-secret-2024
     JWT_EXPIRES_IN=7d
     NODE_ENV=production
     ```
   - `DATABASE_URL` уже добавлена автоматически!

5. **Настройте команду запуска:**

   - Перейдите в "Settings"
   - Найдите "Deploy"
   - В "Start Command" введите:
     ```
     sh -c "npx prisma migrate deploy && npm start"
     ```

6. **Получите публичный URL:**
   - Перейдите в "Settings" → "Domains"
   - Нажмите "Generate Domain"
   - Скопируйте URL (например: `https://prague-carsharing-production.up.railway.app`)

## Шаг 5: Наполните базу данных

В Railway Dashboard:

- Откройте ваш сервис
- Перейдите в "Deployments"
- Нажмите на последний деплой
- Нажмите "View Logs"

Должны увидеть что сервер запустился!

Теперь наполните БД через API:

```bash
# В браузере откройте
https://ваш-url.railway.app

# Должен открыться JSON с информацией об API
```

## Шаг 6: Подключите Flutter

В файле `lib/services/api_service.dart` измените:

```dart
static const String baseUrl = 'https://ваш-url.railway.app/api';
```

## 🎉 Готово!

Ваша база данных теперь работает 24/7 в облаке!

### Чтобы добавить начальные данные:

Используйте Postman или curl:

```bash
# Регистрация админа
curl -X POST https://ваш-url.railway.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@praguecarsharing.com",
    "password": "admin123",
    "name": "Admin"
  }'
```

### Просмотр логов:

Railway Dashboard → ваш проект → Deployments → View Logs

### Просмотр базы данных:

Railway Dashboard → PostgreSQL → Data

---

## 💡 Совет:

Railway дает **$5 бесплатно каждый месяц** - этого хватит для разработки!  
Когда будете готовы к production - можете апгрейднуть план.

---

**Ваш backend будет доступен по ссылке 24/7!** 🌐
