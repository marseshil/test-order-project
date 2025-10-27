# TEST ORDER PROJECT

Небольшое приложение на **FastAPI + PostgreSQL**, упакованное в **Docker**.  
Позволяет запустить проект одной командой без настройки окружения.

---

# Стек технологий

- **Python 3.12**
- **FastAPI**
- **SQLAlchemy**
- **PostgreSQL 16 (через Docker)**
- **Uvicorn** для запуска API

---

# Запуск проекта в Docker

1. **Клонировать репозиторий**

  ```bash
  git clone https://github.com/<your_username>/TEST-ORDER-PROJECT.git
  cd TEST-ORDER-PROJECT

2. **Собрать и запустить контейнеры**

  ```bash
  docker compose up --build

3. **После сборки:**

  База данных создаётся автоматически.

  Скрипт init.sql выполняется при первом запуске.

  Приложение доступно по адресу:
  http://localhost:8000

# Локальный запуск без Docker (опционально)

  **Если хочешь запустить вручную:**

  ```bash
  pip install -r requirements.txt
  uvicorn app.main:app --reload
