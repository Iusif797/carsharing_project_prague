# 🚀 Деплой на Railway.app (Бесплатно!)

## Шаг 1: Создайте аккаунт на Railway

1. Перейдите на https://railway.app
2. Нажмите "Start a New Project"
3. Войдите через GitHub

## Шаг 2: Подготовьте проект для GitHub

```bash
cd /Users/macbook/Desktop/carsharing_project_prague-main/carsharing-backend

# Инициализируйте git
git init
git add .
git commit -m "Initial backend commit"

# Создайте репозиторий на GitHub
# Перейдите на github.com → New Repository → prague-carsharing-backend

# Добавьте remote и push
git remote add origin https://github.com/ВАШ_USERNAME/prague-carsharing-backend.git
git branch -M main
git push -u origin main
```

## Шаг 3: Деплой на Railway

1. **В Railway Dashboard:**

   - Нажмите "New Project"
   - Выберите "Deploy from GitHub repo"
   - Выберите ваш репозиторий `prague-carsharing-backend`

2. **Добавьте PostgreSQL:**

   - Нажмите "New" → "Database" → "Add PostgreSQL"
   - Railway автоматически создаст базу данных

3. **Настройте переменные окружения:**
   - Откройте ваш сервис
   - Перейдите в "Variables"
   - Добавьте:

```
JWT_SECRET=ваш-супер-секретный-ключ-смените-это
JWT_EXPIRES_IN=7d
NODE_ENV=production
```

- `DATABASE_URL` уже будет добавлена автоматически Railway

4. **Настройте Start Command:**

   - В Settings → Deploy
   - Start Command: `sh -c "npx prisma migrate deploy && npm start"`

5. **Получите публичный URL:**
   - В Settings → Domains
   - Нажмите "Generate Domain"
   - Скопируйте URL (например: `https://prague-carsharing-production.up.railway.app`)

## Шаг 4: Проверка

Откройте в браузере ваш URL - должен открыться API!

```
https://ваш-домен.up.railway.app
```

## 🎉 Готово!

Ваш API теперь доступен 24/7 по этой ссылке!

### Что дальше?

1. Сохраните этот URL
2. Используйте его в Flutter приложении
3. База данных работает в облаке!

### Просмотр логов:

Railway Dashboard → ваш проект → View Logs

### Просмотр базы данных:

Railway Dashboard → PostgreSQL → Data → Connect

---

## Альтернатива: Render.com (Бесплатно)

1. Перейдите на https://render.com
2. New → Web Service
3. Connect GitHub repository
4. Настройки:
   - Build Command: `npm install && npx prisma generate`
   - Start Command: `sh -c "npx prisma migrate deploy && npm start"`
5. Добавьте PostgreSQL:
   - New → PostgreSQL
   - Скопируйте DATABASE_URL в переменные

---

## Важно! 🔐

После деплоя обязательно:

1. Смените `JWT_SECRET` на случайную строку
2. Смените пароль админа
3. Настройте CORS для вашего домена

---

**Ваша база теперь в облаке и доступна 24/7!** 🌐
