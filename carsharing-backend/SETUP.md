# 🎯 Установка Backend - Пошаговая инструкция

## Шаг 1: Установите Docker

### macOS:

1. Скачайте Docker Desktop: https://www.docker.com/products/docker-desktop
2. Установите и запустите Docker Desktop
3. Убедитесь что Docker работает: `docker --version`

## Шаг 2: Подготовка

```bash
cd /Users/macbook/Desktop/carsharing_project_prague-main/carsharing-backend

# Создайте .env файл
cp .env.example .env
```

## Шаг 3: Запуск базы данных и API

```bash
# Запустить все сервисы
docker-compose up -d

# Дождитесь запуска (30-60 секунд)
docker-compose logs -f
```

## Шаг 4: Настройка базы данных

```bash
# Применить миграции
docker-compose exec api npx prisma migrate deploy

# Наполнить базу данными
docker-compose exec api npm run db:seed
```

## Шаг 5: Проверка

Откройте в браузере:
**http://localhost:3000**

Вы должны увидеть:

```json
{
  "message": "Prague Carsharing API",
  "version": "1.0.0",
  ...
}
```

## 🎉 Готово!

### Админ доступ:

```
Email: admin@praguecarsharing.com
Password: admin123
```

### API доступен на:

```
http://localhost:3000
```

### Просмотр базы данных:

```bash
# Запустить Prisma Studio
docker-compose exec api npx prisma studio
# Откроется на http://localhost:5555
```

## 🔧 Полезные команды

```bash
# Просмотр логов
docker-compose logs -f api

# Перезапуск
docker-compose restart

# Остановка
docker-compose down

# Полная переустановка
docker-compose down -v
docker-compose up -d
```

## ❓ Проблемы?

### Порт 3000 занят:

```bash
# Найдите процесс
lsof -i :3000

# Остановите его
kill -9 PID
```

### Порт 5432 занят (PostgreSQL):

Измените порт в `docker-compose.yml`:

```yaml
ports:
  - "5433:5432" # Используйте 5433 вместо 5432
```

### База данных не запускается:

```bash
# Проверьте статус
docker-compose ps

# Пересоздайте
docker-compose down -v
docker-compose up -d
```

## 📊 Следующие шаги

1. Измените пароль администратора
2. Добавьте свои машины через API
3. Подключите Flutter приложение к `http://localhost:3000`

Удачи! 🚀
